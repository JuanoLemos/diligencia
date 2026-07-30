# install-services.ps1
# Instalador de Scheduled Tasks para VAIO — opencode serve + VS Code tunnel.
# Ejecutar UNA SOLA VEZ como Administrador.
# Creara dos tareas independientes en el Task Scheduler de Windows.

param(
    [string]$ScriptDir = "$PSScriptRoot"
)

$ErrorActionPreference = "Stop"
$hostname = hostname

Write-Host "=== Diligencia VAIO — Instalador de Servicios ==="
Write-Host "Hostname: $hostname"
Write-Host ""

# ── Verificar admin ────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "ERROR: Ejecutar como Administrador." -ForegroundColor Red
    exit 1
}

# ── Verificar binarios ─────────────────────────────────────────
$opencodePath = Get-Command opencode -ErrorAction SilentlyContinue
if (-not $opencodePath) {
    Write-Host "ADVERTENCIA: opencode no esta en PATH. La tarea puede fallar." -ForegroundColor Yellow
    # Intentar ruta tipica de Chamber
    $opencodePath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\opencode-cli\opencode.exe"
    if (-not (Test-Path $opencodePath)) {
        $opencodePath = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\opencode.exe"
    }
}

$codePath = Get-Command code -ErrorAction SilentlyContinue
if (-not $codePath) {
    Write-Host "ADVERTENCIA: code no esta en PATH. El tunnel de VS Code no funcionara." -ForegroundColor Yellow
}

# ── Ruta del script watchdog ───────────────────────────────────
$watchdogScript = Join-Path $ScriptDir "vaio-services.ps1"
if (-not (Test-Path $watchdogScript)) {
    Write-Host "ERROR: No se encuentra $watchdogScript" -ForegroundColor Red
    exit 1
}

Write-Host "Watchdog script: $watchdogScript"
Write-Host ""

# ── Configuracion de la tarea ──────────────────────────────────
$taskName = "Diligencia-VAIO-Services"
$taskDescription = "Mantiene opencode serve (4096) y VS Code tunnel (vaioserver) siempre activos. Watchdog con health checks cada 30s."
$currentUser = "$env:USERDOMAIN\$env:USERNAME"

# Accion
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$watchdogScript`""

# Trigger: al iniciar el sistema + al iniciar sesion
$triggerStartup = New-ScheduledTaskTrigger -AtStartup
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn -User $currentUser

# Settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Days 0) `
    -MultipleInstances IgnoreNew

# Principal: usuario actual sin guardar password (S4U)
$principal = New-ScheduledTaskPrincipal `
    -UserId $currentUser `
    -LogonType S4U `
    -RunLevel Highest

# ── Registrar tarea ────────────────────────────────────────────
Write-Host "Creando tarea programada '$taskName'..."

# Eliminar si ya existe
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $triggerStartup, $triggerLogon `
    -Settings $settings `
    -Principal $principal `
    -Description $taskDescription `
    -Force

Write-Host "Tarea '$taskName' creada." -ForegroundColor Green

# ── Iniciar inmediatamente ─────────────────────────────────────
Write-Host "Iniciando tarea ahora..."
Start-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 10

# ── Verificar ──────────────────────────────────────────────────
$taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction SilentlyContinue
if ($taskInfo) {
    Write-Host ""
    Write-Host "Estado de la tarea:" -ForegroundColor Green
    Write-Host "  Ultima ejecucion: $($taskInfo.LastRunTime)"
    Write-Host "  Resultado: $($taskInfo.LastTaskResult)"
}

Write-Host ""
Write-Host "=== Verificacion rapida ==="
Start-Sleep -Seconds 5

$serveOnline = $false
try {
    $r = curl.exe -s http://localhost:4096/global/health -u "diligencia:diligencia-vaio-2026" -m 3 2>&1
    $serveOnline = ($LASTEXITCODE -eq 0) -and $r
} catch {}

$tunnelOnline = (Get-Process -Name "code-tunnel" -ErrorAction SilentlyContinue) -ne $null

Write-Host "  opencode serve :4096 : $(if ($serveOnline) { 'ONLINE' } else { 'CAIDO' })"
Write-Host "  VS Code tunnel        : $(if ($tunnelOnline) { 'Activo' } else { 'Caido' })"

if ($serveOnline) {
    Write-Host ""
    Write-Host "Tailscale IP: $(try { (tailscale ip -4 2>$null).Trim() } catch { '?' })"
}

Write-Host ""
Write-Host "DONE — Los servicios se mantendran vivos automaticamente." -ForegroundColor Green
Write-Host "  Log: `$env:USERPROFILE\AppData\Local\Temp\opencode\vaio-services.log"
Write-Host "  Reinicio manual: Get-ScheduledTask '$taskName' | Start-ScheduledTask"
Write-Host "  Ver tareas: taskschd.msc"

# ── Tambien asegurar regla de firewall ─────────────────────────
Write-Host ""
Write-Host "Verificando regla de firewall..."
$fwExists = netsh advfirewall firewall show rule name="opencode serve 4096 (Tailscale)" 2>&1
if ($fwExists -match "No rules match") {
    netsh advfirewall firewall add rule name="opencode serve 4096 (Tailscale)" dir=in action=allow protocol=tcp localport=4096
    Write-Host "  Regla de firewall creada." -ForegroundColor Green
} else {
    Write-Host "  Regla de firewall ya existe." -ForegroundColor Green
}
