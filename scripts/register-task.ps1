# register-task.ps1 — Registro idempotente de scheduled tasks en Chamber
# Reemplaza la auto-creacion de tasks de start-chamber.ps1 (R79.1 burn rate fix).
# BLOQUEA modelos caros (pro, claude, sonnet, opus, gpt-4) — solo modelos flash.
# Repo: C:\xampp\htdocs\Diligencia\scripts\register-task.ps1
#
# Uso:
#   .\scripts\register-task.ps1 -Name "VAIO: check-tareas" -Schedule "*/5 * * * *" -Prompt "..."
#   .\scripts\register-task.ps1 -Name "VAIO: check-tareas" -Schedule "*/5 * * * *" -Prompt "..." -WhatIf
#   .\scripts\register-task.ps1 -Name "VAIO: check-tareas" -Schedule "*/5 * * * *" -Prompt "..." -Force
#   .\scripts\register-task.ps1 -List
#   .\scripts\register-task.ps1 -Delete "VAIO: check-tareas"

param(
    [Parameter(Mandatory=$false)]
    [string]$Name,

    [Parameter(Mandatory=$false)]
    [string]$Schedule,

    [Parameter(Mandatory=$false)]
    [string]$Prompt,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Diligencia", "+RM", "MarketAI", "conquisitare", "buenobonitobarato", "Nemesis", "OpenMontage")]
    [string]$Project = "Diligencia",

    [Parameter(Mandatory=$false)]
    [string]$Model = "deepseek-v4-flash",

    [Parameter(Mandatory=$false)]
    [string]$Provider = "deepseek",

    [Parameter(Mandatory=$false)]
    [int]$Port = 57125,

    [Parameter(Mandatory=$false)]
    [string]$Timezone = "UTC",

    [Parameter(Mandatory=$false)]
    [switch]$List,

    [Parameter(Mandatory=$false)]
    [string]$Delete,

    [Parameter(Mandatory=$false)]
    [switch]$WhatIf,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# ── Modelos prohibidos (burn rate) ─────────────────────────────
$PROHIBITED_MODELS = @("pro", "claude", "sonnet", "opus", "gpt-4", "gemini-pro", "haiku")
foreach ($prohibited in $PROHIBITED_MODELS) {
    if ($Model -match $prohibited) {
        Write-Host "ERROR: Modelo '$Model' esta en la lista de prohibidos (burn rate)." -ForegroundColor Red
        Write-Host "       Modelos permitidos: deepseek-v4-flash, MiniMax flash-tier, etc." -ForegroundColor Yellow
        Write-Host "       Si NECESITAS un modelo pro, usar -Force y justificar en commit message." -ForegroundColor Yellow
        exit 1
    }
}

# ── Project ID hardcoded (mismo que start-chamber.ps1) ─────────
$projectId = "path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE"
$api = "http://localhost:$Port/api/projects/$projectId/scheduled-tasks"

# ── Health check Chamber ───────────────────────────────────────
try {
    $health = curl.exe -s "http://localhost:$Port/api/openchamber/tunnel/status" -m 3 2>$null
    if (-not $health -or $health -notmatch '"localPort"') {
        throw "Chamber no responde"
    }
} catch {
    Write-Host "ERROR: Chamber no esta corriendo en puerto $Port. Iniciar primero con start-chamber.ps1." -ForegroundColor Red
    exit 1
}

# ── Modo: List ─────────────────────────────────────────────────
if ($List) {
    Write-Host "=== Scheduled tasks registradas (puerto $Port) ==="
    $tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
    if (-not $tasks -or $tasks.Count -eq 0) {
        Write-Host "  (ninguna)"
    } else {
        foreach ($t in $tasks) {
            $model = $t.execution.modelID
            $warn = if ($model -match "pro|claude|sonnet|opus|gpt-4") { " ⚠️ CARO" } else { "" }
            $cron = $t.schedule.cron
            $enabled = $t.enabled
            Write-Host "  - $($t.name) [$model] cron='$cron' enabled=$enabled$warn"
            if ($t.execution.prompt) {
                $promptPreview = $t.execution.prompt.Substring(0, [Math]::Min(80, $t.execution.prompt.Length))
                Write-Host "    prompt: $promptPreview..."
            }
        }
    }
    exit 0
}

# ── Modo: Delete ───────────────────────────────────────────────
if ($Delete) {
    Write-Host "=== Eliminando task '$Delete' ==="
    $tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
    $target = $tasks | Where-Object { $_.name -eq $Delete }
    if (-not $target) {
        Write-Host "  Task '$Delete' no encontrada." -ForegroundColor Yellow
        exit 0
    }
    if (-not $WhatIf) {
        curl.exe -s -X DELETE "$api/$($target.id)" | Out-Null
    }
    Write-Host "  Task '$Delete' eliminada." -ForegroundColor Green
    exit 0
}

# ── Validaciones para create/update ────────────────────────────
if (-not $Name) { Write-Host "ERROR: -Name requerido (o usa -List / -Delete <name>)."; exit 1 }
if (-not $Schedule) { Write-Host "ERROR: -Schedule requerido (formato cron: '*/5 * * * *')."; exit 1 }
if (-not $Prompt) { Write-Host "ERROR: -Prompt requerido."; exit 1 }

# ── Validar frecuencia minima (anti-loop) ─────────────────────
$parts = $Schedule -split "\s+"
if ($parts.Count -eq 5) {
    $minute = $parts[0]
    if ($minute -eq "*" -and -not $Force) {
        Write-Host "ERROR: cron='* * * * *' (cada minuto) requiere -Force. Es un patron quemador de tokens." -ForegroundColor Red
        Write-Host "       Minimo recomendado: */5 * * * * (cada 5 minutos)." -ForegroundColor Yellow
        exit 1
    }
}

# ── Construir body ─────────────────────────────────────────────
$body = @{
    task = @{
        name = $Name
        enabled = $true
        schedule = @{
            kind = "cron"
            cron = $Schedule
            timezone = $Timezone
        }
        execution = @{
            providerID = $Provider
            modelID = $Model
            prompt = $Prompt
        }
    }
} | ConvertTo-Json -Depth 10

# ── Verificar si la task ya existe (idempotencia) ─────────────
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$existing = $tasks | Where-Object { $_.name -eq $Name }

if ($existing) {
    Write-Host "Task '$Name' ya existe (id: $($existing.id)). Actualizando in-place..."
    $taskId = $existing.id
    # PUT con id para update
    $body = @{
        task = @{
            id = $taskId
            name = $Name
            enabled = $true
            schedule = @{
                kind = "cron"
                cron = $Schedule
                timezone = $Timezone
            }
            execution = @{
                providerID = $Provider
                modelID = $Model
                prompt = $Prompt
            }
        }
    } | ConvertTo-Json -Depth 10
} else {
    Write-Host "Task '$Name' no existe. Creando nueva..."
}

# ── WhatIf (dry-run) ───────────────────────────────────────────
if ($WhatIf) {
    Write-Host ""
    Write-Host "=== DRY RUN — NO EJECUTADO ===" -ForegroundColor Cyan
    Write-Host "PUT $api"
    Write-Host "Body:"
    Write-Host $body
    exit 0
}

# ── Ejecutar ──────────────────────────────────────────────────
$jsonPath = "$env:TEMP\register-task-$($Name -replace '[^a-zA-Z0-9]', '-').json"
$body | Set-Content $jsonPath -Encoding UTF8 -Force
$result = curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$jsonPath"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "OK: Task '$Name' registrada/actualizada." -ForegroundColor Green
    Write-Host "  Model: $Model"
    Write-Host "  Cron: $Schedule ($Timezone)"
    Write-Host "  Project: $Project"
    Write-Host "  Endpoint: $api"
} else {
    Write-Host "ERROR: Fallo el PUT. curl exit code: $LASTEXITCODE" -ForegroundColor Red
    Write-Host $result
    exit 1
}
