# invoke-agent-task.ps1
# Envia una tarea al servidor opencode serve en VAIO.
# Uso desde Chamber PC o cualquier equipo con acceso HTTP al server:
#   .\invoke-agent-task.ps1 -Prompt "Fix auth bug" -Project "Nemesis" -Server "http://vaio-url:4096"
#   .\invoke-agent-task.ps1 -Prompt "Actualizar docs" -Project "Diligencia" -Model "deepseek-v4-flash" -Priority alta

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Diligencia", "+RM", "MarketAI", "conquisitare", "buenobonitobarato", "Nemesis", "OpenMontage")]
    [string]$Project,

    [string]$Server = $env:DILIGENCIA_SERVER,

    [string]$Model = "deepseek-v4-pro",

    [ValidateSet("alta", "media", "baja")]
    [string]$Priority = "media",

    [string]$Password = $env:OPENCODE_SERVER_PASSWORD,

    [switch]$Stream,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ── Validaciones ─────────────────────────────────────────────
if (-not $Server) {
    Write-Host "ERROR: Define DILIGENCIA_SERVER o usa -Server <url>"
    Write-Host "  Ejemplo: `$env:DILIGENCIA_SERVER = 'http://vaio-url:4096'"
    exit 1
}

$Server = $Server.TrimEnd('/')

# ── Mapeo proyecto -> ruta ──────────────────────────────────
$projectPaths = @{
    "Diligencia"      = "C:\xampp\htdocs\Diligencia"
    "+RM"             = "C:\xampp\htdocs\+RM"
    "MarketAI"        = "C:\xampp\htdocs\MarketAI"
    "conquisitare"    = "C:\xampp\htdocs\conquisitare"
    "buenobonitobarato" = "C:\xampp\htdocs\buenobonitobarato"
    "Nemesis"         = "C:\xampp\htdocs\nemesis"
    "OpenMontage"     = "C:\Users\jlemo\OneDrive\Desktop\OpenMontage-main"
}

$cwd = $projectPaths[$Project]
if (-not $cwd) {
    Write-Host "ERROR: Proyecto '$Project' no encontrado en el mapa de rutas."
    exit 1
}

# ── Auth ─────────────────────────────────────────────────────
$username = "diligencia"
if (-not $Password) {
    Write-Host "ERROR: Define OPENCODE_SERVER_PASSWORD o usa -Password"
    exit 1
}
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${Password}"))
$headers = @{
    "Authorization" = "Basic $base64Auth"
    "Content-Type"  = "application/json"
}

# ── Health check ─────────────────────────────────────────────
if (-not $DryRun) {
    try {
        $health = Invoke-RestMethod -Uri "$Server/global/health" -Headers $headers -TimeoutSec 5
        Write-Host "Server: ONLINE"
    } catch {
        Write-Host "ERROR: No se pudo conectar al servidor $Server"
        Write-Host "  $_"
        exit 1
    }
}

# ── Crear sesion ────────────────────────────────────────────
$sessionBody = @{
    title = "[$Project] $($Prompt.Substring(0, [Math]::Min(60, $Prompt.Length)))"
    cwd   = $cwd
} | ConvertTo-Json -Compress

if ($DryRun) {
    Write-Host "DRY RUN - Sesion: $sessionBody"
    exit 0
}

Write-Host "Creando sesion en $Server ..."
$session = Invoke-RestMethod -Uri "$Server/session" -Method Post -Body $sessionBody -Headers $headers
$sessionId = $session.id
Write-Host "  Sesion ID: $sessionId"

# ── Enviar prompt ───────────────────────────────────────────
$messageBody = @{
    parts = @(@{ type = "text"; text = $Prompt })
    model = @{
        providerID = "deepseek"
        modelID    = $Model
    }
} | ConvertTo-Json -Compress -Depth 5

Write-Host "Enviando prompt (modelo: $Model)..."
Write-Host ""

# ── Modo streaming (SSE) vs sincrono ─────────────────────────
if ($Stream) {
    # Modo async + SSE
    Invoke-RestMethod -Uri "$Server/session/$sessionId/prompt_async" `
        -Method Post -Body $messageBody -Headers $headers | Out-Null

    Write-Host "Escuchando eventos SSE... (Ctrl+C para detener)"
    Write-Host "=============================================="

    try {
        $sseHeaders = $headers.Clone()
        $sseHeaders["Accept"] = "text/event-stream"

        $response = Invoke-WebRequest -Uri "$Server/event" -Headers $sseHeaders -TimeoutSec 0 2>&1
        # Nota: SSE requiere manejo de stream que PowerShell no soporta nativamente.
        # Usar watch-server.ps1 para monitoreo SSE real.
        Write-Host "Para monitoreo SSE usa: .\watch-server.ps1 -Server $Server -SessionId $sessionId"
    } catch {
        Write-Host "Para monitoreo SSE usa: .\watch-server.ps1 -Server $Server -SessionId $sessionId"
    }
} else {
    # Modo sincrono (espera respuesta completa)
    try {
        $result = Invoke-RestMethod -Uri "$Server/session/$sessionId/message" `
            -Method Post -Body $messageBody -Headers $headers -TimeoutSec 600

        Write-Host ""
        Write-Host "RESPUESTA:"
        Write-Host "=============================================="
        if ($result.parts) {
            foreach ($part in $result.parts) {
                if ($part.text) {
                    Write-Host $part.text
                }
            }
        }
        Write-Host "=============================================="
        Write-Host "Estado: $($result.info.status)"

        # Mostrar diff si hay cambios
        Write-Host ""
        Write-Host "Cambios realizados:"
        try {
            $diff = Invoke-RestMethod -Uri "$Server/session/$sessionId/diff" -Headers $headers
            if ($diff.files -and $diff.files.Count -gt 0) {
                foreach ($file in $diff.files) {
                    Write-Host "  $($file.path) ($($file.additions)+ / $($file.deletions)-)"
                }
            } else {
                Write-Host "  (sin cambios en archivos)"
            }
        } catch {
            Write-Host "  (diff no disponible)"
        }
    } catch {
        Write-Host "ERROR: La tarea fallo o excedio el timeout."
        Write-Host "  $_"
        Write-Host ""
        Write-Host "Para ver el estado:"
        Write-Host "  curl.exe -s $Server/session/$sessionId/message"
        exit 1
    }
}

Write-Host ""
Write-Host "Sesion ID: $sessionId"
Write-Host "Para ver mensajes: curl.exe -s $Server/session/$sessionId/message"
Write-Host "Para ver diff:     curl.exe -s $Server/session/$sessionId/diff"
