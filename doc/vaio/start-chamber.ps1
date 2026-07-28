# start-chamber.ps1 — Arranque auto-curativo de Chamber para VAIO v1.0
# Inicia Chamber, verifica scheduled tasks, las recrea si faltan,
# fija sessionId, inicia tunnel. Sobrevive a reinicios.
# Repo: C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1

param(
    [int]$Port = 57125,
    [string]$ChamberDir = "$env:USERPROFILE\openchamber",
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia"
)

$projectId = "path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE"
$api = "http://localhost:$Port/api/projects/$projectId/scheduled-tasks"
$tunnelApi = "http://localhost:$Port/api/openchamber/tunnel"

# === 1. Iniciar Chamber ===
Write-Host "[1] Iniciando Chamber en puerto $Port..."
Set-Location $ChamberDir
$proc = Start-Process -WindowStyle Hidden -FilePath "node.exe" `
    -ArgumentList "packages/web/bin/cli.js serve --port $Port" -PassThru

# === 2. Esperar readiness ===
Write-Host "[2] Esperando readiness..."
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 2
    try {
        $r = curl.exe -s "http://localhost:$Port/api/openchamber/tunnel/status" 2>$null
        if ($r -match '"localPort"') { $ready = $true; break }
    } catch { }
}
if (-not $ready) { Write-Host "ERROR: Chamber no responde en $Port segundos"; exit 1 }
Write-Host "     Chamber listo (PID $($proc.Id))"

# === 3. Verificar tasks ===
Write-Host "[3] Verificando scheduled tasks..."
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

if ($tasks.Count -eq 0) {
    Write-Host "     Sin tasks — creando..."

    # Prompt real de check-tareas
    $checkPrompt = "Ejecutá secuencialmente sin interpretar.`n1. cd $DiligenciaDir; git pull --rebase`n2. Buscá tareas en doc/vaio/tasks/ sin resultado`n3. Si hay: leé la tarea, ejecutá los comandos, escribí resultado en doc/vaio/results/`n4. git add doc/vaio/results/; git commit -m 'VAIO: resultado'; git push"

    $body1 = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$checkPrompt}}} | ConvertTo-Json -Depth 10
    $body1 | Set-Content "$env:TEMP\start-check.json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\start-check.json" | Out-Null
    Write-Host "     check-tareas creada"

    $pubPrompt = "Leé URL de cloudflared.`n1. Get-Content `$env:TEMP\cloudflared-url.log`n2. Extraé https://*.trycloudflare.com`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit -m 'VAIO: URL cloudflared' + push"

    $body2 = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$pubPrompt}}} | ConvertTo-Json -Depth 10
    $body2 | Set-Content "$env:TEMP\start-pub.json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\start-pub.json" | Out-Null
    Write-Host "     publish-url creada"

    # === 4. Esperar primer ciclo y fijar sessionId ===
    Write-Host "[4] Esperando sessionId (65s)..."
    Start-Sleep -Seconds 65
    $tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
    $ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
    $sid = $ct.state.lastSessionId
    if ($sid) {
        foreach ($t in $tasks) {
            $prompt2 = $t.execution.prompt
            $fix = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt2}}} | ConvertTo-Json -Depth 10
            $fix | Set-Content "$env:TEMP\start-fix-$($t.id).json" -Encoding UTF8 -Force
            curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\start-fix-$($t.id).json" | Out-Null
        }
        Write-Host "     sessionId fijado: $sid"
    }
} else {
    Write-Host "     $($tasks.Count) tasks existentes — sin cambios"
}

# === 5. Iniciar túnel ===
Write-Host "[5] Iniciando tunnel quick mode..."
$tunnel = curl.exe -s -X POST "$tunnelApi/start" -H "Content-Type: application/json" -d '{"provider":"cloudflare","mode":"quick"}'
if ($tunnel -match '"url":') {
    $url = ($tunnel | ConvertFrom-Json).url
    Write-Host "     Tunnel URL: $url"
} else {
    Write-Host "     Tunnel ya activo o falló"
}

Write-Host "[OK] Chamber listo en :$Port"
