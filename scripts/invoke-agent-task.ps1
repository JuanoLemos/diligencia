# invoke-agent-task.ps1
# Envia una tarea al servidor opencode serve en VAIO.
# Con -Persist mantiene sesion reutilizable por proyecto (con rotacion automatica cada 5 prompts).
# v2.1 (R79.1 burn rate fix): bootstrap lazy, scope filter, MaxTokens cap.
# El bootstrap de Diligencia se inyecta SOLO cuando el prompt lo necesita (keywords).
# Uso:
#   .\invoke-agent-task.ps1 -Prompt "git status" -Project "Nemesis"
#   .\invoke-agent-task.ps1 -Prompt "fix bug" -Project "Nemesis" -Persist
#   .\invoke-agent-task.ps1 -Prompt "revisa tests" -Project "+RM" -Sync
#   .\invoke-agent-task.ps1 -Prompt "commit cambios" -StrictBootstrap
#   .\invoke-agent-task.ps1 -Prompt "fix bug" -Project "+RM" -Include "*.ps1","*.md"

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
    [switch]$Persist,
    [switch]$DryRun,
    [switch]$NoRotate,
    [switch]$StrictBootstrap,
    [string]$SessionId,
    [int]$MaxPrompts = 5,
    [string[]]$Include,
    [int]$MaxInputTokens = 50000,
    [int]$MaxOutputTokens = 8000,
    [double]$BalanceFloor = 0.50,
    [double]$MaxCost = 1.00,
    [switch]$SkipPolicy
)

$ErrorActionPreference = "Stop"
$maxWaitSec = 120

# Cargar config persistente
. "$PSScriptRoot\server-config.ps1"
if (-not $Server) { $Server = $env:DILIGENCIA_SERVER }
if (-not $Password) { $Password = $env:OPENCODE_SERVER_PASSWORD }
if (-not $Server) { Write-Host "ERROR: Define DILIGENCIA_SERVER o usa -Server <url>"; exit 1 }
$Server = $Server.TrimEnd('/')

# Cargar model policy (R79.1 governance) — solo si no se especifico -Model
if (-not $SkipPolicy) {
    $policyPath = Join-Path $PSScriptRoot "model-policy.json"
    if (Test-Path $policyPath) {
        try {
            $policy = Get-Content $policyPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $projectPolicy = $policy.projects.$Project
            if ($projectPolicy) {
                # Solo aplicar si Model es el default; respeta override explicito
                if ($Model -eq "deepseek-v4-flash" -and $projectPolicy -ne "deepseek-v4-flash") {
                    Write-Host ("[policy] {0} -> {1} (default: {2})" -f $Project, $projectPolicy, $Model) -ForegroundColor DarkGray
                    $Model = $projectPolicy
                }
            }
            # Aplicar caps de policy si no fueron overriden
            if ($MaxInputTokens -eq 50000 -and $policy.max_input_tokens) {
                $MaxInputTokens = [int]$policy.max_input_tokens
            }
            if ($MaxOutputTokens -eq 8000 -and $policy.max_output_tokens) {
                $MaxOutputTokens = [int]$policy.max_output_tokens
            }
            if ($BalanceFloor -eq 0.50 -and $policy.balance_floor_usd) {
                $BalanceFloor = [double]$policy.balance_floor_usd
            }
        } catch {
            Write-Host ("WARN: No se pudo cargar model-policy.json: $_") -ForegroundColor Yellow
        }
    }
}

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
$authParam = "-u `"${username}:${Password}`""

# Bootstrap de contexto Diligencia (lazy: solo si el prompt lo requiere)
$BOOTSTRAP_KEYWORDS = @(
    "commit", "push", "cbp", "version", "build", "agente", "sesion",
    "deploy", "watchdog", "sync", "git ", "rm ", "adapta", "revis",
    "implement", "investig", "doc", "patron", "promp", "sesion",
    "mensaje", "archivo", "linea", "commit", "merge", "branch",
    "rotat", "depend", "contexto", "model", "api", "salud"
)

function Get-Bootstrap {
    param([string]$ProjectName, [string]$Cwd, [string[]]$IncludeGlobs)
    $scope = if ($IncludeGlobs -and $IncludeGlobs.Count -gt 0) {
        "`n- ALCANCE: solo pods leer/escribir archivos que matcheen: $($IncludeGlobs -join ', '). Si necesitas otro path, declarálo antes de leer."
    } else { "" }
    return @"
[BOOTSTRAP DILIGENCIA]
Proyecto: $ProjectName. CWD: $Cwd.
Reglas vinculantes:
- BUILD = aplicar cambios, NUNCA commitear sin orden explicita de este prompt.
- Solo /CBP y /version ejecutan git commit.
- No modificar archivos fuera del CWD.
- Responder SIEMPRE en espanol.
- Reportar EXITO o ERROR al final, con evidencia (archivo:linea siempre que sea posible).$scope
- Si encontrás un bug en otro proyecto, reportalo, no lo arregles.
"@
}

function Test-BootstrapNeeded {
    param([string]$PromptText, [switch]$Strict)
    if ($Strict) { return $true }
    $promptLower = $PromptText.ToLower()
    foreach ($kw in $BOOTSTRAP_KEYWORDS) {
        if ($promptLower -match [regex]::Escape($kw)) { return $true }
    }
    return $false
}

# Health check
try {
    $health = Invoke-RestMethod -Uri "$Server/global/health" -Headers $headers -TimeoutSec 5
    Write-Host ("Server: ONLINE  |  Model: {0}" -f $Model)
} catch {
    Write-Host "ERROR: No se pudo conectar al servidor $Server"; exit 1
}

# Aviso de costo para modelos caros
if ($Model -match "pro|claude|sonnet") {
    Write-Host ("ATENCION: El modelo '{0}' es de alto costo." -f $Model) -ForegroundColor Yellow
}

# Pre-flight balance check (R79.1 burn rate circuit breaker)
if ($env:DEEPSEEK_API_KEY -and $BalanceFloor -gt 0) {
    try {
        $hdrB = @{ "Authorization" = "Bearer $($env:DEEPSEEK_API_KEY)"; "Content-Type" = "application/json" }
        $bal = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" -Headers $hdrB -TimeoutSec 5
        if ($bal.balance_infos -and $bal.balance_infos.Count -gt 0) {
            $balance = [double]$bal.balance_infos[0].balance
            $balStr = $balance.ToString('N4')
            if ($balance -lt $BalanceFloor) {
                Write-Host ("ERROR: Balance DeepSeek `$$balStr debajo del floor `$$BalanceFloor. Abortando.") -ForegroundColor Red
                Write-Host "       Recarga credito o usa -BalanceFloor 0 para desactivar este check." -ForegroundColor Yellow
                exit 1
            }
            Write-Host ("Balance OK: `$$balStr (floor `$$BalanceFloor)") -ForegroundColor DarkGray
        }
    } catch {
        Write-Host ("WARN: No se pudo verificar balance DeepSeek: $_") -ForegroundColor Yellow
    }
}

# -- Gestion de sesion (persistente o nueva) -------------------
$sessionDir = Join-Path $PSScriptRoot "..\.agent-sessions"
$sessionFile = Join-Path $sessionDir ("{0}.session" -f $Project)
$sessionIdActual = $SessionId
$needBootstrap = $false

if ($Persist -and -not $SessionId) {
    # Intentar recuperar sesion guardada
    if (Test-Path $sessionFile) {
        try {
            $saved = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $sessionIdActual = $saved.session_id
            $promptCount = $saved.prompt_count

            # Verificar que la sesion siga viva
            try {
                $check = Invoke-RestMethod -Uri "$Server/session/$sessionIdActual" -Headers $headers -TimeoutSec 5
                if ($check.info.status -eq "error") { throw "session in error state" }
                Write-Host ("Sesion recuperada: {0} ({1}/{2} prompts)" -f $sessionIdActual, $promptCount, $MaxPrompts)
            } catch {
                Write-Host "Sesion guardada no responde. Creando nueva..."
                $sessionIdActual = $null
                $needBootstrap = $true
            }

            # Rotacion si se excede el limite
            if ($sessionIdActual -and $promptCount -ge $MaxPrompts -and -not $NoRotate) {
                Write-Host "Limite de prompts alcanzado ($promptCount/$MaxPrompts). Rotando sesion..."
                $resumenPrompt = "Resumi el estado actual del proyecto en 200 caracteres o menos, incluyendo ultima tarea completada y rama git activa."
                $resumenBody = @{
                    parts = @(@{ type = "text"; text = $resumenPrompt })
                    model = @{ providerID = "deepseek"; modelID = $Model }
                } | ConvertTo-Json -Compress -Depth 5
                try {
                    $resp = Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/message" -Method Post -Body $resumenBody -Headers $headers -TimeoutSec 30
                    $resumen = if ($resp.parts) { ($resp.parts | Where-Object { $_.type -eq "text" } | Select-Object -First 1).text } else { "resumen no disponible" }
                } catch { $resumen = "resumen no disponible" }

                # Abortar sesion vieja
                try { Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/abort" -Method Post -Headers $headers } catch {}
                $sessionIdActual = $null
                $needBootstrap = $true
                $promptCount = 0
                Write-Host "Sesion rotada."
            }
        } catch {
            Write-Host "Error al leer sesion guardada. Creando nueva..."
            $sessionIdActual = $null
            $needBootstrap = $true
        }
    } else {
        $needBootstrap = $true
    }
}

# Crear sesion nueva si no tenemos una
if (-not $sessionIdActual) {
    $sessionBody = @{
        title = ("[{0}] {1}" -f $Project, $Prompt.Substring(0, [Math]::Min(60, $Prompt.Length)))
        cwd   = $cwd
    } | ConvertTo-Json -Compress

    if ($DryRun) { Write-Host ("DRY RUN - Sesion: {0}" -f $sessionBody); exit 0 }

    Write-Host "Creando sesion nueva..."
    $session = Invoke-RestMethod -Uri "$Server/session" -Method Post -Body $sessionBody -Headers $headers
    $sessionIdActual = $session.id
    $needBootstrap = $true

    # Guardar sesion persistente
    if ($Persist) {
        if (-not (Test-Path $sessionDir)) { New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null }
        $sessionData = @{
            session_id = $sessionIdActual
            project = $Project
            cwd = $cwd
            created_at = (Get-Date -Format "o")
            prompt_count = 0
            bootstrap_done = $false
        } | ConvertTo-Json -Compress
        Set-Content -Path $sessionFile -Value $sessionData -Encoding UTF8
    }
    Write-Host ("  ID: {0}" -f $sessionIdActual)
}

# -- Construir prompt final ------------------------------------
$needsBootstrap = ($needBootstrap -and (Test-BootstrapNeeded -PromptText $Prompt -Strict:$StrictBootstrap))
$promptFinal = if ($needsBootstrap) {
    (Get-Bootstrap -ProjectName $Project -Cwd $cwd -IncludeGlobs $Include) + "`n`n---`n`n" + $Prompt
} else {
    $Prompt
}

# Log si el bootstrap fue omitido por lazy (util para debugging)
if ($needBootstrap -and -not $needsBootstrap) {
    Write-Host "[bootstrap lazy] Omitido - prompt no requiere reglas vinculantes." -ForegroundColor DarkGray
}

$messageBody = @{
    parts = @(@{ type = "text"; text = $promptFinal })
    model = @{ providerID = "deepseek"; modelID = $Model }
    maxTokens = $MaxOutputTokens
} | ConvertTo-Json -Compress -Depth 5

Write-Host "Enviando prompt...`n"

# -- Enviar ----------------------------------------------------
if ($Sync) {
    try {
        $result = Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/message" `
            -Method Post -Body $messageBody -Headers $headers -TimeoutSec $maxWaitSec
        Write-Host "RESPUESTA:"
        if ($result.parts) {
            foreach ($part in $result.parts) { if ($part.text) { Write-Host $part.text } }
        }
        Write-Host ("Estado: {0}" -f $result.info.status)
        try {
            $info = Invoke-RestMethod -Uri "$Server/session/$sessionIdActual" -Headers $headers
            Write-Host ("Tokens: input={0} output={1} | Costo: ${2}" -f $info.tokens.input, $info.tokens.output, $info.cost)
            # MaxCost enforcement (R79.1)
            if ($MaxCost -gt 0 -and [double]$info.cost -gt $MaxCost) {
                $costStr = $info.cost.ToString('N4')
                $maxStr = $MaxCost.ToString('N4')
                Write-Host ("ALERTA: Costo `$$costStr excede MaxCost `$$maxStr. Abortando sesion.") -ForegroundColor Red
                try {
                    Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/abort" -Method Post -Headers $headers | Out-Null
                    Write-Host "  Sesion abortada."
                } catch {}
                exit 1
            }
        } catch {}
    } catch {
        Write-Host "ERROR: Tarea no respondio en $maxWaitSec seg. ABORTANDO..." -ForegroundColor Red
        try { Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/abort" -Method Post -Headers $headers; Write-Host "  Abortada." } catch {}
        exit 1
    }
} else {
    try {
        Invoke-RestMethod -Uri "$Server/session/$sessionIdActual/prompt_async" `
            -Method Post -Body $messageBody -Headers $headers | Out-Null
        Write-Host "Tarea enviada (async)."
        Write-Host ("  .\scripts\watch-server.ps1 -Server {0} -SessionId {1}" -f $Server, $sessionIdActual)
    } catch {
        Write-Host "ERROR: No se pudo enviar la tarea: $_"; exit 1
    }
}

# Actualizar contador en sesion persistente
if ($Persist -and (Test-Path $sessionFile)) {
    try {
        $saved = Get-Content $sessionFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $saved.prompt_count = [int]$saved.prompt_count + 1
        $saved.bootstrap_done = $true
        Set-Content -Path $sessionFile -Value ($saved | ConvertTo-Json -Compress) -Encoding UTF8
    } catch {}
}
