# watch-server.ps1
# Monitoreo del servidor opencode serve en VAIO desde Chamber PC.
# Muestra sesiones activas, progreso en tiempo real, y health status.
# Uso:
#   .\watch-server.ps1 -Server "http://vaio-url:4096"           # Dashboard general
#   .\watch-server.ps1 -Server "http://vaio-url:4096" -Watch     # Streaming SSE en vivo
#   .\watch-server.ps1 -Server "http://vaio-url:4096" -SessionId abc123  # Una sesion especifica

param(
    [string]$Server,

    [string]$Password,

    [string]$SessionId,

    [switch]$Watch,

    [switch]$Clean,

    [int]$PollInterval = 3
)

$ErrorActionPreference = "Continue"

# Cargar config persistente (cambia env vars si existen)
. "$PSScriptRoot\server-config.ps1"

# Fallback a env vars si no se pasaron como parametro
if (-not $Server) { $Server = $env:DILIGENCIA_SERVER }
if (-not $Password) { $Password = $env:OPENCODE_SERVER_PASSWORD }

if (-not $Server) {
    Write-Host "ERROR: Define DILIGENCIA_SERVER o usa -Server <url>"
    exit 1
}

$Server = $Server.TrimEnd('/')

# ── Auth ─────────────────────────────────────────────────────
$username = "diligencia"
if (-not $Password) {
    $Password = Read-Host -Prompt "OPENCODE_SERVER_PASSWORD"
}
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${Password}"))
$headers = @{
    "Authorization" = "Basic $base64Auth"
    "Content-Type"  = "application/json"
}

# ── Funciones helper ─────────────────────────────────────────
function Get-Health {
    try {
        $h = Invoke-RestMethod -Uri "$Server/global/health" -Headers $headers -TimeoutSec 3
        return @{ online = $true; data = $h }
    } catch {
        return @{ online = $false; error = $_.Exception.Message }
    }
}

function Get-Sessions {
    try {
        return Invoke-RestMethod -Uri "$Server/session" -Headers $headers -TimeoutSec 5
    } catch {
        return $null
    }
}

function Get-SessionMessages($sid) {
    try {
        return Invoke-RestMethod -Uri "$Server/session/$sid/message" -Headers $headers -TimeoutSec 5
    } catch {
        return $null
    }
}

# ── Modo: Watch (streaming SSE) ──────────────────────────────
if ($Watch) {
    Write-Host "Modo SSE streaming. Conectando a $Server/event ..."
    Write-Host "Presiona Ctrl+C para detener."
    Write-Host ""

    $sseHeaders = $headers.Clone()
    $sseHeaders["Accept"] = "text/event-stream"

    # PowerShell no tiene cliente SSE nativo - usamos polling como fallback
    Write-Host "Usando polling cada ${PollInterval}s (SSE nativo requiere Node.js/Python)"
    Write-Host ""

    while ($true) {
        $health = Get-Health
        if (-not $health.online) {
            Write-Host ("[{0}] SERVER OFFLINE - reintentando..." -f (Get-Date -Format HH:mm:ss))
            Start-Sleep -Seconds 5
            continue
        }

        $sessions = Get-Sessions
        if ($sessions) {
            $activeCount = ($sessions | Where-Object { $_.info.status -eq "running" }).Count
            $totalCount = $sessions.Count
            Write-Host ("[{0}] Sesiones: {1} total | {2} activas" -f (Get-Date -Format HH:mm:ss), $totalCount, $activeCount)

            foreach ($s in $sessions) {
                $status = $s.info.status
                $icon = $s.info.status
                Write-Host ("  [{0}] {1}" -f $status, $s.title)
            }
        } else {
            Write-Host ("[{0}] Sin sesiones o error de conexion" -f (Get-Date -Format HH:mm:ss))
        }

        Start-Sleep -Seconds $PollInterval
    }
}

# ── Modo: Sesion especifica ──────────────────────────────────
if ($SessionId) {
    Write-Host "Monitoreando sesion: $SessionId"
    Write-Host ""

    $prevStatus = ""
    while ($true) {
        $msgs = Get-SessionMessages $SessionId
        if ($msgs) {
            $currentStatus = $msgs.info.status
            if ($currentStatus -ne $prevStatus) {
                Write-Host ("[{0}] Estado: {1}" -f (Get-Date -Format HH:mm:ss), $currentStatus)
                $prevStatus = $currentStatus
            }

            if ($msgs.parts) {
                foreach ($part in $msgs.parts) {
                    if ($part.text) {
                        $truncated = $part.text.Substring(0, [Math]::Min(120, $part.text.Length))
                        Write-Host ("  {0}..." -f $truncated)
                    }
                }
            }

            if ($currentStatus -eq "done" -or $currentStatus -eq "error") {
                Write-Host ""
                Write-Host ("Sesion terminada. Estado: {0}" -f $currentStatus)
                try {
                    $diff = Invoke-RestMethod -Uri "$Server/session/$SessionId/diff" -Headers $headers
                    Write-Host ("Archivos modificados: {0}" -f $diff.files.Count)
                } catch {}
                break
            }
        }
        Start-Sleep -Seconds $PollInterval
    }
}

# ── Modo: Clean (abortar sesiones viejas o stuck) ──────────────
if ($Clean) {
    Write-Host "Limpiando sesiones en $Server ..."
    $sessions = Get-Sessions
    if (-not $sessions) { Write-Host "  No hay sesiones."; exit 0 }

    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $aborted = 0
    foreach ($s in $sessions) {
        $ageMs = $now - $s.time.created
        $ageSec = [Math]::Round($ageMs / 1000)
        $isRunning = ($s.info.status -eq "running") -or (-not $s.info.status)
        if ($isRunning -and $ageSec -gt 300) {
            Write-Host ("  Abortando {0} ({1}min) - {2}" -f $s.id, [Math]::Round($ageSec/60), $s.title)
            try {
                Invoke-RestMethod -Uri "$Server/session/$($s.id)/abort" -Method Post -Headers $headers
                $aborted++
            } catch { Write-Host ("    Error: {0}" -f $_.Exception.Message) }
        }
    }
    Write-Host ("Hecho: {0} sesiones abortadas." -f $aborted)
    exit 0
}

# ── Modo: Dashboard ──────────────────────────────────────────
if (-not $Watch -and -not $SessionId) {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "  Diligencia - Server Autonomo Dashboard"
    Write-Host "=============================================="
    Write-Host ""

    $health = Get-Health
    if ($health.online) {
        Write-Host "Server: ONLINE  |  $Server"
        Write-Host "Health: $($health.data | ConvertTo-Json -Compress)"
    } else {
        Write-Host "Server: OFFLINE |  $Server"
        Write-Host "Error: $($health.error)"
        exit 1
    }

    Write-Host ""
    Write-Host "--- Sesiones Activas ---"
    $sessions = Get-Sessions
    if ($sessions) {
        $totalCost = 0
        $totalTokensIn = 0
        $totalTokensOut = 0
        foreach ($s in $sessions) {
            $totalCost += $s.cost
            $totalTokensIn += $s.tokens.input
            $totalTokensOut += $s.tokens.output
        }
        Write-Host ("Total tokens: {0} in / {1} out | Costo total: `${2:N2}" -f $totalTokensIn, $totalTokensOut, $totalCost)
        Write-Host ""
        $sessions | Format-Table @(
            @{Label="ID"; Expression={$_.id.Substring(0,8)}},
            @{Label="Status"; Expression={$_.info.status}},
            @{Label="Modelo"; Expression={$_.info.modelID}},
            @{Label="Costo"; Expression={$_.cost}},
            @{Label="Titulo"; Expression={$_.title}}
        ) -AutoSize
    } else {
        Write-Host "  (sin sesiones)"
    }

    Write-Host ""
    Write-Host "Comandos:"
    Write-Host "  .\invoke-agent-task.ps1 -Prompt '...' -Project 'Nemesis'     # Enviar tarea (async)"
    Write-Host "  .\invoke-agent-task.ps1 -Prompt '...' -Project 'Nemesis' -Sync  # Esperar resultado"
    Write-Host "  .\watch-server.ps1 -Watch               # Streaming en vivo"
    Write-Host "  .\watch-server.ps1 -SessionId <id>       # Una sesion"
    Write-Host "  .\watch-server.ps1 -Clean                # Abortar sesiones >5min"
}
