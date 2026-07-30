# invoke-agent-task.ps1
# Envia una tarea al servidor opencode serve en VAIO.
# ⚠️ SIEMPRE en modo async (no bloquea). Usa -Sync para esperar respuesta.
# ⚠️ Si el servidor no responde en 60s, ABORTA la sesion automaticamente.
# Uso:
#   .\invoke-agent-task.ps1 -Prompt "git status" -Project "Nemesis"
#   .\invoke-agent-task.ps1 -Prompt "fix bug" -Project "+RM" -Sync

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Diligencia", "+RM", "MarketAI", "conquisitare", "buenobonitobarato", "Nemesis", "OpenMontage")]
    [string]$Project,

    [string]$Server,

    [string]$Model = "deepseek-v4-flash",

    [ValidateSet("alta", "media", "baja")]
    [string]$Priority = "media",

    [string]$Password = $env:OPENCODE_SERVER_PASSWORD,

    [switch]$Sync,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$maxWaitSec = 120

# Cargar config persistente
. "$PSScriptRoot\server-config.ps1"

# Fallback a env vars si no se pasaron como parametro
if (-not $Server) { $Server = $env:DILIGENCIA_SERVER }
if (-not $Password) { $Password = $env:OPENCODE_SERVER_PASSWORD }

if (-not $Server) {
    Write-Host "ERROR: Define DILIGENCIA_SERVER o usa -Server <url>"
    exit 1
}
$Server = $Server.TrimEnd('/')

# Mapeo proyecto -> ruta
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
if (-not $cwd) { Write-Host "ERROR: Proyecto '$Project' no encontrado."; exit 1 }

# Auth
$username = "diligencia"
if (-not $Password) { Write-Host "ERROR: Define OPENCODE_SERVER_PASSWORD"; exit 1 }
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${username}:${Password}"))
$headers = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "application/json" }

# Health check
try {
    $health = Invoke-RestMethod -Uri "$Server/global/health" -Headers $headers -TimeoutSec 5
    Write-Host "Server: ONLINE"
} catch {
    Write-Host "ERROR: No se pudo conectar al servidor $Server"
    exit 1
}

# Aviso de costo
$costWarning = $false
if ($Model -match "pro" -or $Model -match "claude" -or $Model -match "sonnet") {
    Write-Host "⚠️  ATENCION: El modelo '$Model' es de alto costo." -ForegroundColor Yellow
    Write-Host "⚠️  El consumo excesivo de tokens es responsabilidad del operador." -ForegroundColor Yellow
    Write-Host ""
    $costWarning = $true
}

# Crear sesion
$sessionBody = @{
    title = "[$Project] $($Prompt.Substring(0, [Math]::Min(60, $Prompt.Length)))"
    cwd   = $cwd
} | ConvertTo-Json -Compress

if ($DryRun) {
    Write-Host "DRY RUN - Sesion: $sessionBody"
    exit 0
}

Write-Host "Creando sesion..."
$session = Invoke-RestMethod -Uri "$Server/session" -Method Post -Body $sessionBody -Headers $headers
$sessionId = $session.id
Write-Host "  ID: $sessionId"

# Enviar prompt
$messageBody = @{
    parts = @(@{ type = "text"; text = $Prompt })
    model = @{
        providerID = "deepseek"
        modelID    = $Model
    }
} | ConvertTo-Json -Compress -Depth 5

Write-Host "Enviando prompt ($Model)..."
Write-Host ""

if ($Sync) {
    # Sync con timeout y abort si falla
    try {
        $result = Invoke-RestMethod -Uri "$Server/session/$sessionId/message" `
            -Method Post -Body $messageBody -Headers $headers -TimeoutSec $maxWaitSec

        Write-Host "RESPUESTA:"
        if ($result.parts) {
            foreach ($part in $result.parts) {
                if ($part.text) { Write-Host $part.text }
            }
        }
        Write-Host "Estado: $($result.info.status)"

        # Mostrar costo si disponible
        try {
            $sessionInfo = Invoke-RestMethod -Uri "$Server/session/$sessionId" -Headers $headers
            $t = $sessionInfo.tokens
            $cost = $sessionInfo.cost
            Write-Host "Tokens: input=$($t.input) output=$($t.output) | Costo: `$$cost"
        } catch {}

    } catch {
        Write-Host "ERROR: La tarea no respondio en $maxWaitSec segundos. ABORTANDO sesion..." -ForegroundColor Red
        try {
            Invoke-RestMethod -Uri "$Server/session/$sessionId/abort" -Method Post -Headers $headers
            Write-Host "  Sesion $sessionId abortada." -ForegroundColor Yellow
        } catch {
            Write-Host "  No se pudo abortar la sesion: $_"
        }
        Write-Host ""
        Write-Host "Riesgo de consumo: esta operacion pudo haber consumido tokens sin completarse." -ForegroundColor Red
        exit 1
    }
} else {
    # Async: dispara y no espera
    try {
        Invoke-RestMethod -Uri "$Server/session/$sessionId/prompt_async" `
            -Method Post -Body $messageBody -Headers $headers | Out-Null
        Write-Host "Tarea enviada en modo async. Monitorear con:"
        Write-Host "  .\scripts\watch-server.ps1 -SessionId $sessionId"
    } catch {
        Write-Host "ERROR: No se pudo enviar la tarea en modo async."
        Write-Host "  $_"
        exit 1
    }
}
