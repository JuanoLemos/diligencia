# vaio-services.ps1
# Watchdog de servicios VAIO - opencode serve + VS Code tunnel.
# Disenado para correr como Scheduled Task al inicio de Windows.
# Invisible, logging a archivo, auto-restart si algo muere.

param(
    [int]$CheckInterval = 30,
    [string]$LogDir = "$env:USERPROFILE\AppData\Local\Temp\opencode"
)

$ErrorActionPreference = "Continue"
New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction SilentlyContinue | Out-Null
$logFile = Join-Path $LogDir "vaio-services.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp | $Message"
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# Variables de entorno - deben estar en el scope de este proceso
$env:OPENCODE_SERVER_USERNAME = "diligencia"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
# DEEPSEEK_API_KEY se toma del entorno (Machine/User), configurada por install-services.ps1

# Asegurar que tambien esten a nivel usuario (para otros procesos)
[Environment]::SetEnvironmentVariable("OPENCODE_SERVER_USERNAME", "diligencia", "User")
[Environment]::SetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", "diligencia-vaio-2026", "User")

Write-Log "=== VAIO Services Watchdog iniciado ==="

# -- Iniciar opencode serve -------------------------------------
function Start-OpenCodeServe {
    $onPort = netstat -ano | Select-String ":4096" | Select-String "LISTENING"
    if ($onPort) { return $true }

    try {
        $proc = Start-Process -FilePath "opencode" `
            -ArgumentList "serve", "--port", "4096", "--hostname", "0.0.0.0" `
            -NoNewWindow -PassThru `
            -RedirectStandardOutput "$env:TEMP\opencode-server-stdout.log" `
            -RedirectStandardError "$env:TEMP\opencode-server-stderr.log"
        Start-Sleep -Seconds 4
        $onPort = netstat -ano | Select-String ":4096" | Select-String "LISTENING"
        if ($onPort) {
            Write-Log "opencode serve INICIADO (PID $($proc.Id))"
            return $true
        } else {
            Write-Log "ERROR: opencode serve no escucha en :4096 tras lanzar PID $($proc.Id)"
            return $false
        }
    } catch {
        Write-Log "ERROR: opencode serve excepcion: $_"
        return $false
    }
}

# -- Iniciar VS Code tunnel -------------------------------------
function Start-VSCodeTunnel {
    $existing = Get-Process -Name "code-tunnel" -ErrorAction SilentlyContinue
    if ($existing) { return $true }

    try {
        $codeCli = Get-Command code -ErrorAction SilentlyContinue
        if (-not $codeCli) {
            Write-Log "ERROR: code CLI no disponible en PATH"
            return $false
        }
        Start-Process -FilePath "code" `
            -ArgumentList "tunnel", "--name", "vaioserver", "--accept-server-license-terms" `
            -NoNewWindow -WindowStyle Hidden
        Start-Sleep -Seconds 6
        $result = Get-Process -Name "code-tunnel" -ErrorAction SilentlyContinue
        if ($result) {
            Write-Log "VS Code tunnel INICIADO"
            return $true
        } else {
            Write-Log "ADVERTENCIA: VS Code tunnel no detectado tras lanzar (auth pendiente?)"
            return $false
        }
    } catch {
        Write-Log "ERROR: VS Code tunnel excepcion: $_"
        return $false
    }
}

# -- Health check opencode serve ---------------------------------
function Test-OpenCodeHealth {
    try {
        $response = curl.exe -s http://localhost:4096/global/health `
            -u "diligencia:diligencia-vaio-2026" -m 3 2>&1
        return ($LASTEXITCODE -eq 0) -and $response
    } catch {
        return $false
    }
}

# -- Session health - abortar sesiones stuck o idle -----------
function Clear-StuckSessions {
    param([int]$MaxAgeSeconds = 300, [int]$IdleMaxMinutes = 30)
    try {
        $sessions = curl.exe -s http://localhost:4096/session -u "diligencia:diligencia-vaio-2026" 2>$null
        if (-not $sessions) { return }
        $list = $sessions | ConvertFrom-Json
        if (-not $list -or $list.Count -eq 0) { return }

        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $aborted = 0
        foreach ($s in $list) {
            $ageMs = $now - $s.time.created
            $ageSec = $ageMs / 1000
            $updatedMs = $now - $s.time.updated
            $idleMin = $updatedMs / 60000
            $isRunning = ($s.info.status -eq "running") -or (-not $s.info.status)

            if ($isRunning -and $ageSec -gt $MaxAgeSeconds) {
                Write-Log "ABORT session $($s.id): ${ageSec}s running (max ${MaxAgeSeconds}s). Title: $($s.title)"
                curl.exe -s -X POST "http://localhost:4096/session/$($s.id)/abort" `
                    -u "diligencia:diligencia-vaio-2026" -H "Content-Type: application/json" 2>$null | Out-Null
                $aborted++
            } elseif ($idleMin -gt $IdleMaxMinutes) {
                Write-Log "ABORT session idle $($s.id): ${idleMin}min sin actualizar. Title: $($s.title)"
                curl.exe -s -X POST "http://localhost:4096/session/$($s.id)/abort" `
                    -u "diligencia:diligencia-vaio-2026" -H "Content-Type: application/json" 2>$null | Out-Null
                $aborted++
            }
        }
        if ($aborted -gt 0) {
            Write-Log "Session cleanup: $aborted sesiones abortadas (stuck o idle)."
        }
    } catch {
        Write-Log "ERROR en session cleanup: $_"
    }
}

# -- Arranque inicial -------------------------------------------
Write-Log "Arranque inicial de servicios..."

# Aplicar plantilla Diligencia (R79.1 burn rate fix) - idempotente
$ensureConfig = Join-Path $PSScriptRoot "ensure-config.ps1"
if (Test-Path $ensureConfig) {
    try {
        & $ensureConfig | Out-Null
        Write-Log "ensure-config.ps1 aplicado (o sin drift)."
    } catch {
        Write-Log "WARN: ensure-config.ps1 fallo: $_"
    }
}

Start-OpenCodeServe | Out-Null
Start-VSCodeTunnel | Out-Null

# -- Watchdog loop ----------------------------------------------
$restartsOC = 0
$restartsVS = 0
while ($true) {
    # Session cleanup - abortar sesiones stuck >5min
    Clear-StuckSessions -MaxAgeSeconds 300

    # opencode serve
    if (-not (Test-OpenCodeHealth)) {
        $restartsOC++
        Write-Log "ALERTA: opencode serve no responde - matando y relanzando (intento $restartsOC)..."
        $onPort = netstat -ano | Select-String ":4096" | Select-String "LISTENING"
        if ($onPort) {
            $pidMatch = [regex]::Match($onPort, "(\d+)\s*$")
            if ($pidMatch.Success) {
                Stop-Process -Id $pidMatch.Groups[1].Value -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
        }
        Start-OpenCodeServe | Out-Null
    }

    # VS Code tunnel
    $vscRunning = Get-Process -Name "code-tunnel" -ErrorAction SilentlyContinue
    if (-not $vscRunning) {
        $restartsVS++
        Write-Log "ALERTA: VS Code tunnel no detectado - relanzando (intento $restartsVS)..."
        Start-VSCodeTunnel | Out-Null
    }

    Start-Sleep -Seconds $CheckInterval
}
