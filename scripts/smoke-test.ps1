# smoke-test.ps1 - Smoke test del stack VAIO post-reboot
# Verifica que todos los componentes esten vivos despues de un restart.
# Uso: .\scripts\smoke-test.ps1
# Retorna exit code 0 si todo OK, 1 si falla.
#
# v3.10.3

$ErrorActionPreference = "Continue"
$failures = @()

Write-Host "=== SMOKE TEST VAIO (v3.10.3) via Tailscale ===" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# VAIO via Tailscale
$vaio = "100.120.192.43"
$auth = "Basic ZGlsaWdlbmNpYTpkaWxpZ2VuY2lhLXZhaW8tMjAyNg=="
$headers = @{ Authorization = $auth }

# 1. Tailscale (PC MAIN)
Write-Host "1. Tailscale (PC MAIN)"
$ts = tailscale status 2>&1 | Select-Object -First 1
if ($ts -match "100\.125\.[0-9]+\.[0-9]+") {
    Write-Host "  OK: PC MAIN tiene Tailscale IP 100.125.180.6" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Tailscale en PC MAIN no levantado" -ForegroundColor Red
    $failures += "tailscale_main"
}

# 2. VAIO alcanzable via Tailscale
Write-Host "2. VAIO alcanzable (100.120.192.43)"
if (Test-Connection -ComputerName $vaio -Count 1 -Quiet 2>$null) {
    Write-Host "  OK: ping" -ForegroundColor Green
} else {
    Write-Host "  FAIL: no responde" -ForegroundColor Red
    $failures += "vaio_ping"
}

# 3. Opencode serve en VAIO
Write-Host "3. Opencode serve en VAIO :4096"
try {
    $health = Invoke-RestMethod -Uri ("http://" + $vaio + ":4096/global/health") -Headers $headers -TimeoutSec 5
    if ($health.healthy) {
        Write-Host ("  OK: " + ($health | ConvertTo-Json -Compress)) -ForegroundColor Green
    } else {
        Write-Host "  FAIL: server no healthy" -ForegroundColor Red
        $failures += "opencode_health"
    }
} catch {
    Write-Host ("  FAIL: " + $_.Exception.Message) -ForegroundColor Red
    $failures += "opencode_health"
}

# 4. ngrok tunnels en VAIO
Write-Host "4. ngrok tunnels en VAIO :4040"
try {
    $tunnels = Invoke-RestMethod -Uri ("http://" + $vaio + ":4040/api/tunnels") -TimeoutSec 5
    if ($tunnels.tunnels.Count -ge 1) {
        $tunnels.tunnels | Format-Table name, public_url, config.addr -AutoSize | Out-String | Write-Host
    } else {
        Write-Host "  FAIL: 0 tunnels activos" -ForegroundColor Red
        $failures += "ngrok_tunnels"
    }
} catch {
    Write-Host ("  FAIL: " + $_.Exception.Message) -ForegroundColor Red
    $failures += "ngrok_api"
}

# 5. Chamber en VAIO
Write-Host "5. Chamber en VAIO :57123"
try {
    $c = Invoke-RestMethod -Uri ("http://" + $vaio + ":57123/api/openchamber/tunnel/status") -TimeoutSec 5
    Write-Host ("  OK: " + ($c | ConvertTo-Json -Compress)) -ForegroundColor Green
} catch {
    Write-Host ("  FAIL: " + $_.Exception.Message) -ForegroundColor Yellow
}

# 6. e2e MiniMax test
Write-Host "6. e2e MiniMax test (agent=server-admin)"
try {
    $body = '{"title":"[smoke] e2e","agent":"server-admin"}'
    $sess = Invoke-RestMethod -Uri ("http://" + $vaio + ":4096/session") -Method Post -Body $body -Headers ($headers + @{"Content-Type"="application/json"}) -TimeoutSec 15
    $msgBody = '{"parts":[{"type":"text","text":"OK"}],"model":{"providerID":"minimax-coding-plan","modelID":"MiniMax-M2.7"}}'
    $msg = Invoke-RestMethod -Uri ("http://" + $vaio + ":4096/session/" + $sess.id + "/message") -Method Post -Body $msgBody -Headers ($headers + @{"Content-Type"="application/json"}) -TimeoutSec 60
    $txt = ($msg.parts | Where-Object { $_.type -eq "text" } | Select-Object -First 1).text
    if ($txt) {
        Write-Host "  OK: respuesta MiniMax recibida" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: sin respuesta" -ForegroundColor Red
        $failures += "minimax_e2e"
    }
} catch {
    Write-Host ("  FAIL: " + $_.Exception.Message) -ForegroundColor Red
    $failures += "minimax_e2e"
}

# 7. Agents custom en disco (PC MAIN)
Write-Host "7. Agents custom en disco (PC MAIN)"
$expected = @("server-admin.md", "code-reviewer.md", "project-handler.md")
$globalDir = "$env:USERPROFILE\.config\opencode\agents"
$projectDir = ".opencode\agents"
foreach ($a in $expected) {
    $g = Test-Path (Join-Path $globalDir $a)
    $p = Test-Path (Join-Path $projectDir $a)
    if (-not $g -and -not $p) {
        Write-Host "  FAIL: $a no existe" -ForegroundColor Red
        $failures += "agent_$a"
    } else {
        $where = if ($g) { "global" } else { "proyecto" }
        Write-Host "  OK: $a ($where)" -ForegroundColor Green
    }
}

# 8. API key MiniMax persistida
Write-Host "8. API key MiniMax (PC MAIN User scope)"
$apiKey = [System.Environment]::GetEnvironmentVariable("MINIMAX_API_KEY", "User")
if ($apiKey) {
    Write-Host "  OK: $($apiKey.Length) chars persistidas" -ForegroundColor Green
} else {
    Write-Host "  FAIL: MINIMAX_API_KEY no persistida" -ForegroundColor Red
    $failures += "minimax_api_key"
}

# 9. Working tree Diligencia
Write-Host "9. Working tree Diligencia (PC MAIN)"
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
    Write-Host "=== OK: stack VAIO completamente funcional (Tailscale + opencode + MiniMax) ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "=== FAIL: $($failures.Count) checks fallaron ===" -ForegroundColor Red
    Write-Host "Fallas: $($failures -join ', ')"
    Write-Host ""
    Write-Host "Recovery: ver doc/vaio/RUNBOOK.md"
    exit 1
}
