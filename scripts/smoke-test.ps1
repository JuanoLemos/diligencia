# smoke-test.ps1 - Smoke test del stack VAIO post-reboot
# Verifica que todos los componentes esten vivos despues de un restart.
# Uso: .\scripts\smoke-test.ps1
# Retorna exit code 0 si todo OK, 1 si falla.
#
# v3.10.3

$ErrorActionPreference = "Continue"
$failures = @()

Write-Host "=== SMOKE TEST VAIO (v3.10.3) ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# 1. Procesos criticos
Write-Host "1. Procesos criticos"
$procs = Get-Process -Name "opencode", "OpenChamber", "ngrok" -ErrorAction SilentlyContinue
if ($procs.Count -ge 2) {
    $procs | Format-Table Name, Id, StartTime -AutoSize | Out-String | Write-Host
} else {
    Write-Host "  FAIL: solo $($procs.Count) procesos criticos encontrados (esperado: 2-3)" -ForegroundColor Red
    $failures += "procesos"
}

# 2. Puertos
Write-Host "2. Puertos escuchando"
$ports = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 4096,57123,4040 }
if ($ports.Count -ge 2) {
    $ports | Format-Table LocalPort, OwningProcess -AutoSize | Out-String | Write-Host
} else {
    Write-Host "  FAIL: solo $($ports.Count) puertos esperados (4096, 57123, 4040)" -ForegroundColor Red
    $failures += "puertos"
}

# 3. Opencode health
Write-Host "3. Opencode health"
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4096/global/health" -Headers @{Authorization="Basic ZGlsaWdlbmNpYTpkaWxpZ2VuY2lhLXZhaW8tMjAyNg=="} -TimeoutSec 5
    if ($health.healthy) {
        Write-Host "  OK: $($health | ConvertTo-Json -Compress)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: server no healthy" -ForegroundColor Red
        $failures += "opencode_health"
    }
} catch {
    Write-Host "  FAIL: $($_.Exception.Message)" -ForegroundColor Red
    $failures += "opencode_health"
}

# 4. ngrok tunnels
Write-Host "4. ngrok tunnels"
try {
    $tunnels = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -TimeoutSec 5
    if ($tunnels.tunnels.Count -ge 1) {
        $tunnels.tunnels | Format-Table name, public_url, config.addr -AutoSize | Out-String | Write-Host
    } else {
        Write-Host "  FAIL: 0 tunnels activos" -ForegroundColor Red
        $failures += "ngrok_tunnels"
    }
} catch {
    Write-Host "  FAIL: ngrok offline - $($_.Exception.Message)" -ForegroundColor Red
    $failures += "ngrok_api"
}

# 5. Tailscale
Write-Host "5. Tailscale"
$ts = tailscale status 2>&1 | Select-Object -First 1
if ($ts -match "100\.\d+\.\d+\.\d+") {
    Write-Host "  OK: $ts" -ForegroundColor Green
} else {
    Write-Host "  WARN: $ts" -ForegroundColor Yellow
}

# 6. Agents custom cargados
Write-Host "6. Agents custom en disco"
$expected = @("server-admin.md", "code-reviewer.md", "project-handler.md")
$globalDir = "$env:USERPROFILE\.config\opencode\agents"
$projectDir = ".opencode\agents"
foreach ($a in $expected) {
    $g = Test-Path (Join-Path $globalDir $a)
    $p = Test-Path (Join-Path $projectDir $a)
    if (-not $g -and -not $p) {
        Write-Host "  FAIL: $a no existe en global ni proyecto" -ForegroundColor Red
        $failures += "agent_$a"
    } else {
        $where = if ($g) { "global" } else { "proyecto" }
        Write-Host "  OK: $a ($where)" -ForegroundColor Green
    }
}

# 7. API key MiniMax
Write-Host "7. API key MiniMax"
$apiKey = [System.Environment]::GetEnvironmentVariable("MINIMAX_API_KEY", "User")
if ($apiKey) {
    Write-Host "  OK: $($apiKey.Length) chars persistidas" -ForegroundColor Green
} else {
    Write-Host "  FAIL: MINIMAX_API_KEY no persistida en User scope" -ForegroundColor Red
    $failures += "minimax_api_key"
}

# 8. Working tree Diligencia
Write-Host "8. Working tree Diligencia"
$wt = git status --short 2>&1
if (-not $wt) {
    Write-Host "  OK: limpio" -ForegroundColor Green
} else {
    Write-Host "  WARN: working tree dirty:" -ForegroundColor Yellow
    Write-Host $wt
}

# Resumen
Write-Host ""
if ($failures.Count -eq 0) {
    Write-Host "=== OK: stack VAIO completamente funcional ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "=== FAIL: $($failures.Count) checks fallaron ===" -ForegroundColor Red
    Write-Host "Fallas: $($failures -join ', ')"
    Write-Host ""
    Write-Host "Recovery: ver doc/vaio/RUNBOOK.md"
    exit 1
}
