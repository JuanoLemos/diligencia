# watch-server.ps1
# Monitoreo del servidor opencode serve en VAIO desde Chamber PC.
# Muestra sesiones activas, progreso en tiempo real, y health status.
# Uso:
#   .\watch-server.ps1 -Server "http://vaio-url:4096"           # Dashboard general
#   .\watch-server.ps1 -Server "http://vaio-url:4096" -Watch     # Streaming SSE en vivo
#   .\watch-server.ps1 -Server "http://vaio-url:4096" -SessionId abc123  # Una sesion especifica

param(
    [string]$Server = $env:DILIGENCIA_SERVER,

    [string]$Password = $env:OPENCODE_SERVER_PASSWORD,

    [string]$SessionId,

    [switch]$Watch,

    [int]$PollInterval = 3
)

$ErrorActionPreference = "Continue"

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

    # PowerShell no tiene cliente SSE nativo — usamos polling como fallback
    Write-Host "Usando polling cada ${PollInterval}s (SSE nativo requiere Node.js/Python)"
    Write-Host ""

    $lastMessageCount = 0
    while ($true) {
        $health = Get-Health
        if (-not $health.online) {
            Write-Host "[$(Get-Date -Format HH:mm:ss)] SERVER OFFLINE — reintentando..."
            Start-Sleep -Seconds 5
            continue
        }

        $sessions = Get-Sessions
        if ($sessions) {
            $activeCount = ($sessions | Where-Object { $_.info.status -eq "running" }).Count
            $totalCount = $sessions.Count
            Write-Host "[$(Get-Date -Format HH:mm:ss)] Sesiones: $totalCount total | $activeCount activas"

            foreach ($s in $sessions) {
                $status = $s.info.status
                $icon = switch ($status) {
                    "running"  { "🟢" }
                    "idle"     { "⚪" }
                    "done"     { "✅" }
                    "error"    { "🔴" }
                    default    { "❓" }
                }
                Write-Host "  $icon [$status] $($s.title)"
            }
        } else {
            Write-Host "[$(Get-Date -Format HH:mm:ss)] Sin sesiones o error de conexion"
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
                Write-Host "[$(Get-Date -Format HH:mm:ss)] Estado: $currentStatus"
                $prevStatus = $currentStatus
            }

            if ($msgs.parts) {
                foreach ($part in $msgs.parts) {
                    if ($part.text) {
                        Write-Host "  $($part.text.Substring(0, [Math]::Min(120, $part.text.Length)))..."
                    }
                }
            }

            if ($currentStatus -eq "done" -or $currentStatus -eq "error") {
                Write-Host ""
                Write-Host "Sesion terminada. Estado: $currentStatus"
                try {
                    $diff = Invoke-RestMethod -Uri "$Server/session/$SessionId/diff" -Headers $headers
                    Write-Host "Archivos modificados: $($diff.files.Count)"
                } catch {}
                break
            }
        }
        Start-Sleep -Seconds $PollInterval
    }
}

# ── Modo: Dashboard ──────────────────────────────────────────
if (-not $Watch -and -not $SessionId) {
    Clear-Host
    Write-Host "=============================================="
    Write-Host "  Diligencia — Server Autonomo Dashboard"
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
        $sessions | Format-Table @(
            @{Label="ID"; Expression={$_.id.Substring(0,8)}},
            @{Label="Status"; Expression={$_.info.status}},
            @{Label="Modelo"; Expression={$_.info.modelID}},
            @{Label="Titulo"; Expression={$_.title}}
        ) -AutoSize
    } else {
        Write-Host "  (sin sesiones)"
    }

    Write-Host ""
    Write-Host "Comandos:"
    Write-Host "  .\invoke-agent-task.ps1 -Prompt '...' -Project 'Nemesis'"
    Write-Host "  .\watch-server.ps1 -Watch               # Streaming en vivo"
    Write-Host "  .\watch-server.ps1 -SessionId <id>       # Una sesion"
}
