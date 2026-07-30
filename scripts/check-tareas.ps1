# check-tareas.ps1 - Verificacion de tareas VAIO pendientes (PURE BASH, SIN LLM)
# Reemplaza la task 'VAIO: check-tareas' (R79.1 burn rate fix).
# Listaba tareas en doc/vaio/tasks/ sin resultado en doc/vaio/results/ usando LLM.
# Ahora es PowerShell puro: 0 tokens consumidos.
# Repo: C:\xampp\htdocs\Diligencia\scripts\check-tareas.ps1
#
# Uso:
#   .\scripts\check-tareas.ps1                        # Listar pendientes
#   .\scripts\check-tareas.ps1 -Json                 # Output JSON para tooling
#   .\scripts\check-tareas.ps1 -MarkDone "tarea-053"  # Marcar como procesada
#   .\scripts\check-tareas.ps1 -Sync                  # git pull + rebase antes
#   .\scripts\check-tareas.ps1 -Cleanup -DaysOld 30   # Limpiar tracker viejo

param(
    [switch]$Json,
    [string]$MarkDone,
    [switch]$Sync,
    [switch]$Cleanup,
    [int]$DaysOld = 30,
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia"
)

$ErrorActionPreference = "Stop"

$tasksDir = Join-Path $DiligenciaDir "doc\vaio\tasks"
$resultsDir = Join-Path $DiligenciaDir "doc\vaio\results"
$trackerDir = Join-Path $DiligenciaDir "scripts\.task-tracker"
$trackerFile = Join-Path $trackerDir "completed.json"

# -- git sync opcional ------------------------------------------
if ($Sync) {
    Write-Host "[sync] git pull --rebase..." -ForegroundColor Cyan
    Push-Location $DiligenciaDir
    try {
        git pull --rebase 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  WARN: git pull tuvo issues (code $LASTEXITCODE). Continuando con estado local." -ForegroundColor Yellow
        } else {
            Write-Host "  OK" -ForegroundColor Green
        }
    } finally {
        Pop-Location
    }
}

# -- Verificar directorios --------------------------------------
if (-not (Test-Path $tasksDir)) {
    Write-Host "ERROR: Directorio de tasks no existe: $tasksDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $resultsDir)) {
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null
}

# -- Cargar tracker (idempotencia) ------------------------------
$completed = @()
if (Test-Path $trackerFile) {
    try {
        $tracker = Get-Content $trackerFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $completed = @($tracker.completed)
    } catch {
        Write-Host "WARN: tracker file corrupto, regenerando." -ForegroundColor Yellow
    }
}

# -- Cleanup viejo ----------------------------------------------
if ($Cleanup) {
    $cutoff = (Get-Date).AddDays(-$DaysOld)
    $newCompleted = @()
    $removed = 0
    foreach ($entry in $completed) {
        try {
            $entryDate = [DateTime]::Parse($entry.completed_at)
            if ($entryDate -ge $cutoff) {
                $newCompleted += $entry
            } else {
                $removed++
            }
        } catch {
            $newCompleted += $entry
        }
    }
    $completed = $newCompleted
    Write-Host "Cleanup: $removed entradas removidas (> $DaysOld dias)." -ForegroundColor Yellow
}

# -- Escanear tasks y resultados --------------------------------
$taskFiles = Get-ChildItem -Path $tasksDir -Filter "tarea-*.md" -ErrorAction SilentlyContinue
$resultFiles = Get-ChildItem -Path $resultsDir -Filter "resultado-*.md" -ErrorAction SilentlyContinue

$pendingTasks = @()
foreach ($tf in $taskFiles) {
    $taskName = $tf.BaseName -replace '^tarea-', ''
    $resultName = "resultado-$taskName"
    $hasResult = $resultFiles | Where-Object { $_.BaseName -eq $resultName }

    # Verificar tracker
    $inTracker = $completed | Where-Object { $_.task -eq $tf.BaseName }

    if (-not $hasResult -and -not $inTracker) {
        $pendingTasks += @{
            name = $tf.BaseName
            path = $tf.FullName
            size = $tf.Length
            modified = $tf.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            priority = if ($tf.Name -match "P0") { "P0" }
                       elseif ($tf.Name -match "P1") { "P1" }
                       elseif ($tf.Name -match "P2") { "P2" }
                       else { "P3" }
        }
    }
}

# -- Marcar como hecho ------------------------------------------
if ($MarkDone) {
    if (-not (Test-Path $trackerDir)) {
        New-Item -ItemType Directory -Path $trackerDir -Force | Out-Null
    }
    $entry = @{
        task = $MarkDone
        completed_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        source = "manual"
    }
    $completed += $entry
    $trackerObj = @{ completed = $completed }
    $trackerObj | ConvertTo-Json -Depth 5 | Set-Content $trackerFile -Encoding UTF8
    Write-Host "Marcada como hecha: $MarkDone" -ForegroundColor Green
    exit 0
}

# -- Output -----------------------------------------------------
if ($Json) {
    $output = @{
        checked_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        total_tasks = $taskFiles.Count
        total_results = $resultFiles.Count
        pending_count = $pendingTasks.Count
        pending = $pendingTasks | Sort-Object { $_.priority }, modified
    }
    $output | ConvertTo-Json -Depth 5
    exit 0
}

# -- Output humanizado ------------------------------------------
Write-Host ""
Write-Host "=== Check-Tareas VAIO (R79.1 burn rate fix) ===" -ForegroundColor Cyan
Write-Host "  Tasks:   $($taskFiles.Count)"
Write-Host "  Results: $($resultFiles.Count)"
Write-Host "  Pending: $($pendingTasks.Count)" -ForegroundColor $(if ($pendingTasks.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($pendingTasks.Count -eq 0) {
    Write-Host "  Ninguna tarea pendiente. Todo al dia." -ForegroundColor Green
} else {
    $sorted = $pendingTasks | Sort-Object priority, modified
    foreach ($t in $sorted) {
        $color = switch ($t.priority) {
            "P0" { "Red" }
            "P1" { "Yellow" }
            "P2" { "Cyan" }
            default { "Gray" }
        }
        Write-Host "  [$($t.priority)] $($t.name)  (modificado: $($t.modified))" -ForegroundColor $color
    }
}

Write-Host ""
Write-Host "  Para ejecutar una tarea, abrir el archivo y correr manualmente." -ForegroundColor Gray
Write-Host "  Para marcar como procesada: -MarkDone <nombre-tarea>" -ForegroundColor Gray
