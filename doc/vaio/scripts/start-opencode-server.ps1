# start-opencode-server.ps1
# Inicia opencode serve como servicio headless en la VAIO.
# Uso: .\start-opencode-server.ps1 [-Port 4096] [-Password "secreto"] [-Lan]
# El servidor expone API REST + SSE para control remoto desde Chamber en PC Principal.

param(
    [int]$Port = 4096,
    [string]$Password = $env:OPENCODE_SERVER_PASSWORD,
    [switch]$Lan,
    [switch]$Kill
)

$ErrorActionPreference = "Stop"

# ── Kill anterior ────────────────────────────────────────────
if ($Kill) {
    Write-Host "Matando procesos opencode existentes..."
    Get-Process opencode -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 1
}

# ── Verificar que no hay otro corriendo ───────────────────────
$existing = Get-Process opencode -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "ERROR: opencode ya esta corriendo (PID: $($existing.Id)). Usa -Kill para reiniciar."
    exit 1
}

# ── Password ──────────────────────────────────────────────────
if (-not $Password) {
    $Password = Read-Host -Prompt "OPENCODE_SERVER_PASSWORD no definida. Ingresa password" -AsSecureString
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    )
}

$env:OPENCODE_SERVER_PASSWORD = $Password
$env:OPENCODE_SERVER_USERNAME = "diligencia"

# ── Hostname ──────────────────────────────────────────────────
$hostname = if ($Lan) { "0.0.0.0" } else { "127.0.0.1" }
$localUrl = "http://$hostname`:$Port"

# ── Arrancar servidor ────────────────────────────────────────
Write-Host "Iniciando opencode serve en $localUrl ..."

$proc = Start-Process -FilePath "opencode" `
    -ArgumentList "serve", "--port", $Port, "--hostname", $hostname, "--mdns" `
    -NoNewWindow -PassThru `
    -RedirectStandardOutput "$env:TEMP\opencode-server-stdout.log" `
    -RedirectStandardError "$env:TEMP\opencode-server-stderr.log"

Start-Sleep -Seconds 3

# ── Verificar que arranco ────────────────────────────────────
$maxRetries = 10
for ($i = 1; $i -le $maxRetries; $i++) {
    try {
        $health = Invoke-RestMethod -Uri "$localUrl/global/health" -TimeoutSec 2 -ErrorAction Stop
        Write-Host "Servidor ONLINE en $localUrl"
        Write-Host "  Health: $($health | ConvertTo-Json -Compress)"
        Write-Host "  PID: $($proc.Id)"
        Write-Host "  Log: $env:TEMP\opencode-server-stdout.log"
        Write-Host "  Errores: $env:TEMP\opencode-server-stderr.log"

        Write-Host ""
        Write-Host "Conectate desde Chamber Desktop:"
        Write-Host "  Settings -> Remote Instances -> Direct Instances -> Import Link"
        Write-Host "  O usa opencode connect-url --port $Port --qr desde este equipo"

        exit 0
    } catch {
        if ($i -eq $maxRetries) {
            Write-Host "ERROR: El servidor no respondio despues de $maxRetries intentos."
            Write-Host "Ultimo error: $_"
            Write-Host "Log de errores:"
            if (Test-Path "$env:TEMP\opencode-server-stderr.log") {
                Get-Content "$env:TEMP\opencode-server-stderr.log" -Tail 10
            }
            $proc | Stop-Process -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "Esperando... ($i/$maxRetries)"
        Start-Sleep -Seconds 2
    }
}
