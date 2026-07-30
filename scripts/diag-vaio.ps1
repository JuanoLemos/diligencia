# diag-vaio.ps1 - Diagnostico READ-ONLY del estado VAIO post-fix v3.9.0
# Solucion R79.1: confirma que no hay tasks IA residuales, sesiones limpias,
# saldo DeepSeek real, watchdog activo.
#
# Uso:
#   .\scripts\diag-vaio.ps1                     # Diagnostico completo
#   .\scripts\diag-vaio.ps1 -Json              # Output en JSON
#   .\scripts\diag-vaio.ps1 -ShowBalance       # Incluir consulta a DeepSeek
#
# NO modifica archivos. NO invoca LLM. 0 tokens consumidos.

param(
    [switch]$Json,
    [switch]$ShowBalance,
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia",
    [int]$Port = 4096,
    [int]$ChamberPort = 57125
)

$ErrorActionPreference = "Continue"

$projectId = "path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE"
$apiChamber = "http://localhost:$ChamberPort/api/projects/$projectId/scheduled-tasks"

# Auth
$username = "diligencia"
$password = $env:OPENCODE_SERVER_PASSWORD
if (-not $password) { $password = "diligencia-vaio-2026" }
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($username + ":" + $password)))
$headers = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "application/json" }

# Resultados
$results = @{
    timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    opencode_serve = @{ online = $false; data = $null }
    sessions = @{ total = 0; cheap = 0; expensive = 0; list = @() }
    chamber_tasks = @{ total = 0; ai_tasks = 0; list = @() }
    deepseek_balance = $null
    processes = @()
    git = @{ branch = $null; clean = $true; ahead = 0; behind = 0; head = $null }
}

# Paso 1-2: opencode serve health + sessions
try {
    $health = Invoke-RestMethod -Uri ("http://localhost:$Port/global/health") -Headers $headers -TimeoutSec 5
    $results.opencode_serve.online = $true
    $results.opencode_serve.data = $health
} catch {
    $results.opencode_serve.online = $false
    $results.opencode_serve.error = $_.Exception.Message
}

if ($results.opencode_serve.online) {
    try {
        $sessions = Invoke-RestMethod -Uri ("http://localhost:$Port/session") -Headers $headers -TimeoutSec 10
        if ($sessions) {
            $results.sessions.total = $sessions.Count
            foreach ($s in $sessions) {
                $model = $s.info.modelID
                $isExpensive = $model -match "pro|claude|sonnet|opus|gpt-4|gemini-pro"
                if ($isExpensive) { $results.sessions.expensive++ } else { $results.sessions.cheap++ }
                $results.sessions.list += @{
                    id = $s.id.Substring(0, [Math]::Min(12, $s.id.Length))
                    model = $model
                    cost = $s.cost
                    status = $s.info.status
                    expensive = $isExpensive
                }
            }
        }
    } catch {
        $results.opencode_serve.sessions_error = $_.Exception.Message
    }
}

# Paso 3: tasks en Chamber
try {
    $chamberResp = Invoke-RestMethod -Uri $apiChamber -TimeoutSec 5
    if ($chamberResp -and $chamberResp.tasks) {
        $results.chamber_tasks.total = $chamberResp.tasks.Count
        foreach ($t in $chamberResp.tasks) {
            $hasAIModel = $false
            if ($t.execution -and $t.execution.modelID) {
                $hasAIModel = $true
                $results.chamber_tasks.ai_tasks++
            }
            $results.chamber_tasks.list += @{
                name = $t.name
                enabled = $t.enabled
                model = if ($t.execution) { $t.execution.modelID } else { $null }
                ai_task = $hasAIModel
                cron = if ($t.schedule) { $t.schedule.cron } else { $null }
            }
        }
    }
} catch {
    $results.chamber_tasks.error = $_.Exception.Message
}

# Paso 4: balance DeepSeek (opcional)
if ($ShowBalance -or $env:DEEPSEEK_API_KEY) {
    try {
        $key = $env:DEEPSEEK_API_KEY
        if ($key) {
            $hdrDS = @{ "Authorization" = "Bearer $key"; "Content-Type" = "application/json" }
            $bal = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" -Headers $hdrDS -TimeoutSec 10
            if ($bal.balance_infos -and $bal.balance_infos.Count -gt 0) {
                $results.deepseek_balance = @{
                    balance_usd = [double]$bal.balance_infos[0].balance
                    granted = [double]$bal.balance_infos[0].granted
                    topped_up = [double]$bal.balance_infos[0].topped_up
                }
            }
        }
    } catch {
        $results.deepseek_balance_error = $_.Exception.Message
    }
}

# Paso 5: procesos
try {
    $procs = Get-Process -Name "opencode", "powershell" -ErrorAction SilentlyContinue
    foreach ($p in $procs) {
        $results.processes += @{
            name = $p.ProcessName
            pid = $p.Id
            started = $p.StartTime.ToString("yyyy-MM-dd HH:mm:ss")
            uptime_min = [math]::Round(((Get-Date) - $p.StartTime).TotalMinutes, 1)
        }
    }
} catch {
    $results.processes_error = $_.Exception.Message
}

# Paso 6-8: git state
try {
    Push-Location $DiligenciaDir
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    $head = git rev-parse --short HEAD 2>$null
    $status = git status --short --branch 2>$null
    $ahead = 0
    $behind = 0
    if ($status -match '\[ahead (\d+)') { $ahead = [int]$matches[1] }
    if ($status -match 'behind (\d+)') { $behind = [int]$matches[1] }
    $results.git = @{
        branch = if ($branch) { $branch.Trim() } else { $null }
        head = if ($head) { $head.Trim() } else { $null }
        clean = [bool](-not ($status -match '\sm\s|\?\s'))
        ahead = $ahead
        behind = $behind
        status_line = $status.Trim()
    }
} catch {
    $results.git_error = $_.Exception.Message
} finally {
    Pop-Location
}

# Output
if ($Json) {
    $results | ConvertTo-Json -Depth 10
    exit 0
}

# Humanized
Write-Host ""
Write-Host "=== DIAG VAIO post-fix v3.9.0 ===" -ForegroundColor Cyan
Write-Host ("Timestamp: {0}" -f $results.timestamp)
Write-Host ""

# 1. opencode serve
$icon = if ($results.opencode_serve.online) { "[OK]" } else { "[FAIL]" }
Write-Host ("1. opencode serve :{0} {1}" -f $Port, $icon)
if ($results.opencode_serve.online) {
    Write-Host ("   Health: {0}" -f ($results.opencode_serve.data | ConvertTo-Json -Compress))
} else {
    Write-Host ("   Error: {0}" -f $results.opencode_serve.error) -ForegroundColor Red
}
Write-Host ""

# 2. Sesiones
$sicon = if ($results.sessions.expensive -gt 0) { "[WARN]" } else { "[OK]" }
Write-Host ("2. Sesiones activas :{0} {1}" -f $Port, $sicon)
Write-Host ("   Total: {0} | Flash: {1} | Caras (pro/claude/etc): {2}" -f $results.sessions.total, $results.sessions.cheap, $results.sessions.expensive)
if ($results.sessions.expensive -gt 0) {
    Write-Host "   SESIONES CARAS DETECTADAS:" -ForegroundColor Red
    foreach ($s in $results.sessions.list | Where-Object { $_.expensive }) {
        Write-Host ("     - {0} | {1} | cost={2}" -f $s.id, $s.model, $s.cost) -ForegroundColor Red
    }
}
Write-Host ""

# 3. Chamber tasks
$ticon = if ($results.chamber_tasks.ai_tasks -gt 0) { "[WARN]" } else { "[OK]" }
Write-Host ("3. Scheduled tasks Chamber :{0} {1}" -f $ChamberPort, $ticon)
Write-Host ("   Total: {0} | Con modelo IA: {1}" -f $results.chamber_tasks.total, $results.chamber_tasks.ai_tasks)
if ($results.chamber_tasks.ai_tasks -gt 0) {
    Write-Host "   TASKS IA DETECTADAS:" -ForegroundColor Red
    foreach ($t in $results.chamber_tasks.list | Where-Object { $_.ai_task }) {
        Write-Host ("     - {0} | model={1} | cron={2}" -f $t.name, $t.model, $t.cron) -ForegroundColor Red
    }
} else {
    Write-Host "   Sin tasks IA. Auto-resurrector efectivo." -ForegroundColor Green
}
Write-Host ""

# 4. Balance
if ($results.deepseek_balance) {
    Write-Host "4. Saldo DeepSeek"
    $bicon = if ($results.deepseek_balance.balance_usd -lt 0.50) { "[LOW]" } else { "[OK]" }
    Write-Host ("   {0} Balance: ${1:N4} USD | Granted: ${2:N4} | ToppedUp: ${3:N4}" -f $bicon, $results.deepseek_balance.balance_usd, $results.deepseek_balance.granted, $results.deepseek_balance.topped_up)
    if ($results.deepseek_balance.balance_usd -lt 0.50) {
        Write-Host "   ALERTA: Balance bajo el floor ($0.50). invoke-agent-task.ps1 rechazara tareas." -ForegroundColor Yellow
    }
} else {
    Write-Host "4. Saldo DeepSeek [SKIP] - DEEPSEEK_API_KEY no en entorno o consulta fallo"
}
Write-Host ""

# 5. Procesos
Write-Host "5. Procesos relevantes"
if ($results.processes.Count -eq 0) {
    Write-Host "   (ninguno detectado)"
} else {
    foreach ($p in $results.processes | Select-Object -First 5) {
        Write-Host ("   - {0} PID={1} uptime={2}min" -f $p.name, $p.pid, $p.uptime_min)
    }
    if ($results.processes.Count -gt 5) {
        Write-Host ("   ... +{0} mas" -f ($results.processes.Count - 5))
    }
}
Write-Host ""

# 6-8. Git
Write-Host ("6. Git state ({0})" -f $DiligenciaDir)
$gicon = if ($results.git.clean) { "[OK]" } else { "[DIRTY]" }
Write-Host ("   {0} branch={1} head={2} | ahead={3} behind={4}" -f $gicon, $results.git.branch, $results.git.head, $results.git.ahead, $results.git.behind)
if (-not $results.git.clean) {
    Write-Host ("   Status: {0}" -f $results.git.status_line) -ForegroundColor Yellow
}
Write-Host ""

# Resumen ejecutivo
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
$alerts = @()
if ($results.sessions.expensive -gt 0) { $alerts += "Sesiones caras activas" }
if ($results.chamber_tasks.ai_tasks -gt 0) { $alerts += "Tasks IA programadas" }
if ($results.deepseek_balance -and $results.deepseek_balance.balance_usd -lt 0.50) { $alerts += "Saldo bajo floor" }
if (-not $results.git.clean) { $alerts += "Working tree sucio" }
if ($results.git.behind -gt 0) { $alerts += "Detras de origin ($($results.git.behind) commits)" }

if ($alerts.Count -eq 0) {
    Write-Host "TODO OK. Estado post-fix v3.9.0 consolidado." -ForegroundColor Green
} else {
    Write-Host "Alertas detectadas:" -ForegroundColor Yellow
    foreach ($a in $alerts) { Write-Host ("  ! {0}" -f $a) -ForegroundColor Yellow }
}
