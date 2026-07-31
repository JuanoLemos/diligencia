# ensure-config.ps1 - Aplica plantilla Diligencia a opencode.jsonc
# Idempotente. Solucion R79.1 burn rate.
#
# IMPORTANTE (ICT-DIL-20260731-01): El schema oficial de opencode
# (https://opencode.ai/config.json) rechaza custom keys en la raiz.
# Este script NO agrega bloques custom. Metadata Diligencia vive en
# ~/.config/opencode/.diligencia.json (archivo separado).
#
# Uso:
#   .\scripts\ensure-config.ps1            # Aplica cambios si hay drift
#   .\scripts\ensure-config.ps1 -DryRun    # Solo muestra diff, no escribe
#   .\scripts\ensure-config.ps1 -Force     # Aplica aunque no haya drift

param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

$configPath = Join-Path $env:USERPROFILE ".config\opencode\opencode.jsonc"
$metaPath   = Join-Path $env:USERPROFILE ".config\opencode\.diligencia.json"

# Keys validas en raiz segun schema oficial de opencode
$validRootKeys = @(
    '$schema','model','small_model','default_agent','agent','subagent_depth',
    'permission','instructions','shell','tools','provider','provider_overrides',
    'disabled_providers','enabled_providers','mcp','lsp','formatter','plugin',
    'server','autoupdate','snapshot','share','watcher','compaction','attachment','experimental'
)

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: $configPath no existe. Ejecutar 'opencode init' primero." -ForegroundColor Red
    exit 1
}

$configRaw = Get-Content $configPath -Raw

# -- Strip JSONC comments para parsear ---
$configNoComments = $configRaw -replace '(?m)^\s*//.*$', ''
$configNoComments = $configNoComments -replace '(?s)/\*.*?\*/', ''

try {
    $configObj = $configNoComments | ConvertFrom-Json
} catch {
    Write-Host "ERROR: No se pudo parsear $configPath. Verificar sintaxis JSON." -ForegroundColor Red
    Write-Host "Detalle: $_" -ForegroundColor Red
    exit 1
}

# -- Detectar custom keys en raiz (ICT-DIL-20260731-01 prevention) ---
$customKeys = @()
foreach ($prop in $configObj.PSObject.Properties) {
    if ($prop.Name -notin $validRootKeys) {
        $customKeys += $prop.Name
    }
}

if ($customKeys.Count -gt 0) {
    Write-Host "ERROR: El jsonc contiene custom keys en raiz que rompen el schema de opencode:" -ForegroundColor Red
    foreach ($k in $customKeys) { Write-Host "  - $k" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Solucion: editar manualmente $configPath y mover las custom keys" -ForegroundColor Yellow
    Write-Host "a un archivo externo (ej: $metaPath)" -ForegroundColor Yellow
    exit 2
}

# -- Verificar metadata Diligencia en archivo externo ---
$metaObj = $null
if (Test-Path $metaPath) {
    try {
        $metaObj = Get-Content $metaPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "WARN: $metaPath invalido. Recreando..." -ForegroundColor Yellow
    }
}

# -- Verificar drift ---
$drift = New-Object System.Collections.Generic.List[string]

# Drift 1: Provider MiniMax cargado (preferido para stack actual)
$hasMiniMax = $false
if ($configObj.provider) {
    foreach ($prop in $configObj.provider.PSObject.Properties) {
        if ($prop.Name -match "minimax") { $hasMiniMax = $true }
    }
}
if (-not $hasMiniMax) {
    [void]$drift.Add("No hay provider minimax en config (usar auth.json con /connect)")
}

# Drift 2: Falta archivo metadata Diligencia
if (-not (Test-Path $metaPath)) {
    [void]$drift.Add("Falta $metaPath (metadata Diligencia)")
} elseif (-not $metaObj.managed) {
    [void]$drift.Add("Archivo $metaPath no tiene managed=true")
}

if ($drift.Count -eq 0 -and -not $Force) {
    Write-Host "OK: Configuracion Diligencia al dia. Sin drift detectado." -ForegroundColor Green
    exit 0
}

Write-Host "Drift detectado:" -ForegroundColor Yellow
foreach ($d in $drift) { Write-Host "  - $d" -ForegroundColor Yellow }

if ($DryRun) {
    Write-Host ""
    Write-Host "=== DRY RUN - NO EJECUTADO ===" -ForegroundColor Cyan
    exit 0
}

# -- Aplicar fixes ---
# Crear metadata externa si falta
if (-not (Test-Path $metaPath)) {
    $metaContent = @"
{
  "_comment": "Metadata Diligencia - NO es parte del schema de opencode.",
  "managed": true,
  "methodology": "Diligencia",
  "methodology_version": "v3.10.0",
  "policy_version": "R79.1",
  "burn_rate_incident": "ICT-DIL-20260731-01",
  "owner": "$env:USERNAME",
  "scope": [
    "bootstrap lazy",
    "denylist modelos caros",
    "scope filter",
    "balance pre-flight",
    "circuit breaker diario",
    "max-cost enforcement"
  ]
}
"@
    Set-Content -LiteralPath $metaPath -Value $metaContent -Encoding UTF8
    Write-Host "  Creado: $metaPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "OK: Configuracion Diligencia al dia." -ForegroundColor Green
Write-Host "  - opencode.jsonc: solo keys validas del schema"
Write-Host "  - .diligencia.json: metadata externa en $metaPath"
Write-Host ""
Write-Host "Nota: provider minimax se carga via auth.json (built-in)."
Write-Host "      Usar /connect dentro del TUI para configurar API keys."
