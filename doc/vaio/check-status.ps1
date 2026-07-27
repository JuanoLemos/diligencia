# check-status.ps1 - Monitoreo de actividad VAIO con toast notifications
# Ejecutar cada 2 minutos via Chamber scheduled task

$diligenciaDir = "C:\xampp\htdocs\Diligencia"
$lastCheckFile = "$diligenciaDir\doc\vaio\.last-check"
$statusFile = "$diligenciaDir\doc\vaio\status.md"

Set-Location $diligenciaDir

# 1. Git fetch (solo lectura, no modifica WT)
git fetch origin 2>&1 | Out-Null

# 2. Detectar commits VAIO nuevos
$lastCheck = if (Test-Path $lastCheckFile) { Get-Content $lastCheckFile } else { "" }
$commits = git log origin/master --oneline --grep="VAIO:" --since="2 minutes ago" 2>$null
$allVaioCommits = git log origin/master --oneline --grep="VAIO:" -5 2>$null

# 3. Contar tareas pendientes (sin resultado)
$tasksDir = "$diligenciaDir\doc\vaio\tasks"
$tasksPending = @()
if (Test-Path $tasksDir) {
    $taskFiles = Get-ChildItem $tasksDir -Filter "tarea-*.md" | Sort-Object Name
    foreach ($tf in $taskFiles) {
        $num = $tf.BaseName -replace 'tarea-',''
        if (-not (Test-Path "$diligenciaDir\doc\vaio\results\resultado-$num.md")) {
            $tasksPending += $num
        }
    }
}

# 4. Actualizar status.md
$date = Get-Date -Format "yyyy-MM-dd HH:mm UTC"
@"
# Status VAIO

**Actualizado:** $date
**Ultimos 5 commits VAIO:**
$($allVaioCommits -join "`n")

**Tareas pendientes:** $($tasksPending.Count) $($($tasksPending -join ', '))
"@ | Set-Content -Path $statusFile -Encoding UTF8

# 5. Si hay novedades, toast notification
if ($commits) {
    $count = ($commits | Measure-Object -Line).Lines
    $firstCommit = ($commits -split "`n")[0].Substring(8)

    # PowerShell toast nativa de Windows
    try {
        # Usar BurntToast si esta disponible
        if (Get-Module -ListAvailable -Name BurntToast) {
            Import-Module BurntToast -ErrorAction Stop
            New-BurntToastNotification -Text "[VAIO]", "Resultado: $firstCommit" -AppLogo "$env:USERPROFILE\.config\opencode\templates\doc-base\.opencode\icon-template.svg"
        } else {
            # Fallback: balloon tip (Windows 10+)
            Add-Type -AssemblyName System.Windows.Forms
            $balloon = New-Object System.Windows.Forms.NotifyIcon
            $balloon.Icon = [System.Drawing.SystemIcons]::Information
            $balloon.BalloonTipTitle = "[VAIO] $count novedad(es)"
            $balloon.BalloonTipText = $firstCommit
            $balloon.Visible = $true
            $balloon.ShowBalloonTip(5000)
            Start-Sleep -Seconds 6
            $balloon.Dispose()
        }
    } catch {
        # Sin GUI: loguear nomas
        "Toast no disponible en esta terminal" | Out-File "$env:TEMP\check-status.log" -Append
    }

    # Actualizar last-check
    git log origin/master --oneline -1 | Set-Content $lastCheckFile
}

# 6. Commit status.md si cambio
git add doc/vaio/status.md 2>&1 | Out-Null
git commit -m "VAIO: status actualizado - $date" 2>&1 | Out-Null
git pull --rebase 2>&1 | Out-Null
git push 2>&1 | Out-Null
