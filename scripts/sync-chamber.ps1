# sync-chamber.ps1 — Compara config Chamber entre PC Principal y VAIO v1.0
# Uso:
#   .\sync-chamber.ps1              → reporta divergencias
#   .\sync-chamber.ps1 --generate   → genera tarea VAIO para cada divergencia

param(
    [switch]$Generate,
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia"
)

Set-Location $DiligenciaDir
$report = @()
$divergencias = @()

Write-Host "=== sync-chamber: Comparando PC Principal vs VAIO ==="
Write-Host ""

# 1. Chequear que las scheduled tasks de PC existen y están activas
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty tasks

if (-not $tasks) {
    $divergencias += "Scheduled tasks en PC Principal: NO RESPONDE"
} else {
    $enabled = $tasks | Where-Object { $_.enabled }
    $report += "PC Principal: $($tasks.Count) tasks ($($enabled.Count) activas)"
    foreach ($t in $tasks) { $report += "  - $($t.name): enabled=$($t.enabled) model=$($t.execution.modelID)" }
}

# 2. Verificar configuración OpenCode (opencode.jsonc)
$config = Get-Content "$env:USERPROFILE\.config\opencode\opencode.jsonc" -Raw
if ($config -match '"context":\s*1000000') {
    $report += "PC Principal: deepseek-v4-pro contexto 1M ✅"
} else {
    $divergencias += "deepseek-v4-pro: contexto NO es 1M en PC Principal"
}

if ($config -match '"model":\s*"deepseek/deepseek-v4-flash"') {
    $report += "PC Principal: modelo default deepseek-v4-flash ✅"
} else { $divergencias += "Modelo default cambiado" }

# 3. Verificar adaptar.md global
$adaptarVer = Select-String -Path "$env:USERPROFILE\.config\opencode\commands\adaptar.md" -Pattern 'Versión.*v(\d+\.\d+\.\d+)'
if ($adaptarVer) {
    $report += "PC Principal: adaptar.md v$($adaptarVer.Matches.Groups[1].Value) ✅"
}

# 4. Verificar tray fix (ASAR)
$asarPath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar"
if (Test-Path $asarPath) {
    $asarSize = (Get-Item $asarPath).Length / 1MB
    $report += "PC Principal: ASAR $($asarSize.ToString('0.0')) MB"
    # Verificar si hay backup del tray fix
    $backupPath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar.backup"
    $backupTray = Get-ChildItem "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\" -Filter "app.asar.backup*" | Select-Object -First 1
    if ($backupTray) { $report += "PC Principal: tiene backup ASAR: $($backupTray.Name)" }
}

# 5. Última actividad VAIO
$lastVaio = git log --oneline origin/master --grep="VAIO:" -1 2>$null
if ($lastVaio) {
    $report += "Último commit VAIO: $lastVaio"
}

# 6. Tareas pendientes (sin resultado en VAIO)
$pending = @()
Get-ChildItem "$DiligenciaDir\doc\vaio\tasks\tarea-*.md" | ForEach-Object {
    $num = $_.BaseName -replace 'tarea-',''
    if (-not (Test-Path "$DiligenciaDir\doc\vaio\results\resultado-$num.md")) {
        $pending += $num
    }
}
if ($pending.Count -gt 0) { $divergencias += "Tareas VAIO pendientes: $($pending -join ', ')" }

# Reporte
Write-Host "=== Diagnóstico ==="
$report | ForEach-Object { Write-Host $_ }
Write-Host ""

if ($divergencias.Count -eq 0) {
    Write-Host "✅ SIN DIVERGENCIAS — PC Principal y VAIO sincronizados"
} else {
    Write-Host "⚠️  DIVERGENCIAS DETECTADAS ($($divergencias.Count)):"
    $divergencias | ForEach-Object { Write-Host "  ❌ $_" }
    
    if ($Generate) {
        $taskContent = @"
# Tarea de sincronización generada por sync-chamber.ps1

> **Generada automáticamente.** Aplica las divergencias detectadas.

## Divergencias detectadas

$($divergencias -join "`n")

## Acciones correctivas

1. Verificar estado del tray (click derecho en icono Chamber de la bandeja)
2. Confirmar que deepseek-v4-pro tiene contexto 1M
3. Reportar resultado
"@
        $taskFile = "$DiligenciaDir\doc\vaio\tasks\tarea-sync.md"
        $taskContent | Set-Content $taskFile -Encoding UTF8
        Write-Host ""
        Write-Host "📝 Tarea generada: $taskFile"
        Write-Host "   Hacé git add + commit + push para que VAIO la ejecute"
    }
}
