# ensure-config.ps1 - Aplica plantilla Diligencia a ~/.config/opencode/opencode.jsonc
# Idempotente. Solucion R79.1 burn rate (R79.1, 2026-07-30):
# previene que deepseek-v4-pro vuelva a contexto 1M tras upgrades.
#
# Uso:
#   .\scripts\ensure-config.ps1            # Aplica cambios si hay drift
#   .\scripts\ensure-config.ps1 -DryRun    # Solo muestra diff, no escribe
#   .\scripts\ensure-config.ps1 -Force     # Aplica aunque no haya drift detectado

param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

$configPath = Join-Path $env:USERPROFILE ".config\opencode\opencode.jsonc"
$templatePath = Join-Path $PSScriptRoot "opencode.template.jsonc"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: $configPath no existe. Ejecutar 'opencode init' primero." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $templatePath)) {
    Write-Host "ERROR: Template no encontrado: $templatePath" -ForegroundColor Red
    exit 1
}

$configRaw = Get-Content $configPath -Raw -Encoding UTF8

# -- Strip JSONC comments (// ... y /* ... */) para poder parsear ---
$configNoComments = $configRaw -replace '(?m)^\s*//.*$', ''
$configNoComments = $configNoComments -replace '(?s)/\*.*?\*/', ''

try {
    $configObj = $configNoComments | ConvertFrom-Json
} catch {
    Write-Host "ERROR: No se pudo parsear $configPath. Verificar sintaxis JSONC." -ForegroundColor Red
    Write-Host "Detalle: $_" -ForegroundColor Red
    exit 1
}

# -- Verificar drift -------------------------------------------
$drift = New-Object System.Collections.Generic.List[string]

# Drift 1: contexto 1M
$proObj = $configObj.provider.deepseek.options.'deepseek-v4-pro'
if ($proObj -and $proObj.maxTokens -eq 1000000) {
    [void]$drift.Add("deepseek-v4-pro maxTokens = 1M (revertir a 128K)")
}

# Drift 2: falta flag _diligencia
if (-not $configObj._diligencia -or -not $configObj._diligencia.managed) {
    [void]$drift.Add("Falta flag _diligencia.managed")
}

# Drift 3: falta bloque deepseek-v4-pro
if (-not $proObj) {
    [void]$drift.Add("Falta provider.deepseek.options.deepseek-v4-pro")
}

if ($drift.Count -eq 0 -and -not $Force) {
    Write-Host "OK: Configuracion Diligencia al dia. Sin drift detectado." -ForegroundColor Green
    exit 0
}

Write-Host "Drift detectado:" -ForegroundColor Yellow
foreach ($d in $drift) { Write-Host "  - $d" -ForegroundColor Yellow }

# -- Aplicar fixes ---------------------------------------------
if (-not $configObj.provider) {
    $configObj | Add-Member -NotePropertyName "provider" -NotePropertyValue ([PSCustomObject]@{}) -Force
}
if (-not $configObj.provider.deepseek) {
    $configObj.provider | Add-Member -NotePropertyName "deepseek" -NotePropertyValue ([PSCustomObject]@{}) -Force
}
if (-not $configObj.provider.deepseek.options) {
    $configObj.provider.deepseek | Add-Member -NotePropertyName "options" -NotePropertyValue ([PSCustomObject]@{}) -Force
}

# Fix deepseek-v4-pro maxTokens
if (-not $configObj.provider.deepseek.options.'deepseek-v4-pro') {
    $configObj.provider.deepseek.options | Add-Member -NotePropertyName "deepseek-v4-pro" -NotePropertyValue ([PSCustomObject]@{maxTokens = 128000}) -Force
} else {
    $configObj.provider.deepseek.options.'deepseek-v4-pro'.maxTokens = 128000
}

# Fix deepseek-v4-flash maxTokens
if (-not $configObj.provider.deepseek.options.'deepseek-v4-flash') {
    $configObj.provider.deepseek.options | Add-Member -NotePropertyName "deepseek-v4-flash" -NotePropertyValue ([PSCustomObject]@{maxTokens = 128000}) -Force
} else {
    $configObj.provider.deepseek.options.'deepseek-v4-flash'.maxTokens = 128000
}

# Fix _diligencia flag
if (-not $configObj._diligencia) {
    $configObj | Add-Member -NotePropertyName "_diligencia" -NotePropertyValue ([PSCustomObject]@{managed = $true; policy_version = "R79.1"}) -Force
} else {
    $configObj._diligencia.managed = $true
    if (-not $configObj._diligencia.policy_version) {
        $configObj._diligencia | Add-Member -NotePropertyName "policy_version" -NotePropertyValue "R79.1" -Force
    }
}

# -- Serializar ------------------------------------------------
$correctedJson = $configObj | ConvertTo-Json -Depth 10

# -- Dry run ---------------------------------------------------
if ($DryRun) {
    Write-Host ""
    Write-Host "=== DRY RUN - diff propuesto ===" -ForegroundColor Cyan
    Write-Host "Backup: $configPath.bak"
    Write-Host ""
    Write-Host "Config corregida:"
    Write-Host $correctedJson
    exit 0
}

# -- Backup y escribir -----------------------------------------
$backupPath = "$configPath.bak"
Copy-Item $configPath $backupPath -Force
Write-Host "Backup: $backupPath" -ForegroundColor Cyan

$correctedJson | Set-Content $configPath -Encoding UTF8
Write-Host "OK: Configuracion aplicada." -ForegroundColor Green
Write-Host "  - deepseek-v4-pro: maxTokens 128000"
Write-Host "  - _diligencia.managed: true"
Write-Host "  - Backup en: $backupPath"
