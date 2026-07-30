# start-chamber.ps1 - Arranque de Chamber para VAIO v2.0 (DEPRECATED AUTO-RESURRECTOR)
# Inicia Chamber, verifica scheduled tasks (READ-ONLY), inicia tunnel.
# NO recrea tasks programadas - eso lo hace scripts/register-task.ps1 manualmente.
# Solucion al incidente de burn rate USD 10/dia (R79.1, 2026-07-30).
# Repo: C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1

param(
    [int]$Port = 57125,
    [string]$ChamberDir = "$env:USERPROFILE\openchamber",
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia"
)

$projectId = "path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE"
$api = "http://localhost:$Port/api/projects/$projectId/scheduled-tasks"
$tunnelApi = "http://localhost:$Port/api/openchamber/tunnel"

# === 1. Iniciar Chamber ===
Write-Host "[1] Iniciando Chamber en puerto $Port..."
Set-Location $ChamberDir
$proc = Start-Process -WindowStyle Hidden -FilePath "node.exe" `
    -ArgumentList "packages/web/bin/cli.js serve --port $Port" -PassThru

# === 2. Esperar readiness ===
Write-Host "[2] Esperando readiness..."
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 2
    try {
        $r = curl.exe -s "http://localhost:$Port/api/openchamber/tunnel/status" 2>$null
        if ($r -match '"localPort"') { $ready = $true; break }
    } catch { }
}
if (-not $ready) { Write-Host "ERROR: Chamber no responde en $Port segundos"; exit 1 }
Write-Host "     Chamber listo (PID $($proc.Id))"

# === 3. Verificar tasks (READ-ONLY) ===
Write-Host "[3] Verificando scheduled tasks (read-only)..."
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

if (-not $tasks -or $tasks.Count -eq 0) {
    Write-Host "     Sin tasks registradas."
    Write-Host "     Para crear tasks, usar: scripts/register-task.ps1 -Name '...' -Schedule '...' -Prompt '...'"
    Write-Host "     (Este script ya NO recrea tasks automaticamente - solucion burn rate R79.1)"
} else {
    Write-Host "     $($tasks.Count) tasks existentes:"
    foreach ($t in $tasks) {
        $model = $t.execution.modelID
        $warn = if ($model -match "pro|claude|sonnet|opus|gpt-4") { " ⚠️ MODELO CARO" } else { "" }
        Write-Host "       - $($t.name) [$model] enabled=$($t.enabled)$warn"
    }
}

# === 5. Iniciar watchdog túnel ===
Write-Host "[5] Iniciando watchdog-tunnel (background)..."
$watchdogPath = "$DiligenciaDir\doc\vaio\watchdog-tunnel.ps1"
if (Test-Path $watchdogPath) {
    # El watchdog monitorea cloudflared y publica URL cada 30s
    # Corre en segundo plano sin ventana visible
    Start-Process -WindowStyle Hidden -FilePath "powershell.exe" `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$watchdogPath`" -Port $Port -DiligenciaDir `"$DiligenciaDir`""
    Write-Host "     watchdog-tunnel lanzado en background"
} else {
    Write-Host "     ERROR: watchdog-tunnel.ps1 no encontrado en $watchdogPath"
}

Write-Host "[OK] Chamber listo en :$Port"
