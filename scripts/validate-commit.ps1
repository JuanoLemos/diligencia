# validate-commit.ps1 — Valida commits contra reglas Diligencia
# Modo advisory: emite WARNING, no bloquea
# Instalar como git hook: .opencode/hooks/README.md

param(
    [string]$CommitMsgFile,
    [switch]$Quiet
)

if (-not $CommitMsgFile) {
    if (-not $Quiet) { Write-Host "USO: validate-commit.ps1 <ruta-commit-msg> [--Quiet]" }
    exit 0
}

$msg = Get-Content -Raw -LiteralPath $CommitMsgFile
$warnings = @()

# Regla 1: cambios metodológicos deben tener CHANGELOG entry
if ($msg -match '^(feat|fix|docs)\(.*(?:metodologia|metodológica|rules|reglas|r\d+|agentes|cbp|version|changelog).*\)') {
    $hasChangelog = Select-String -LiteralPath $CommitMsgFile -Pattern 'CHANGELOG|changelog|changelog' -SimpleMatch
    if (-not $hasChangelog) {
        $warnings += "R6: Cambio metodologico sin referencia a CHANGELOG. Agregar entrada en CHANGELOG.md"
    }
}

# Regla 2: afirmaciones con evidencia (R16)
if ($msg -match '^(?!(chore|revert)).*:\s') {
    $hasEvidence = $msg -match '(?:archivo:línea|archivo:\d+|file:\d+|verify:|git log|grep|rg\s)'
    if (-not $hasEvidence -and $msg -match '^\w+\(.*\):.*\d+%|\d+ commits|\d+ archivos|\d+ tareas') {
        $warnings += "R16: Afirmacion numerica sin evidencia (archivo:linea o comando verify:)"
    }
}

# Regla 3: sin heartbeats ni URLs de túnel en commits de metodología
if ($msg -match '^(chore|docs)\(.*\)') {
    $isInfra = $msg -match '(?:heartbeat|tunnel|cloudflared|url\s|trycloudflare|port\s\d+)'
    if ($isInfra) {
        $warnings += "R6: Commit de infraestructura. Usar /CBP commit, no /CBP version. No justifica bump."
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  validate-commit:"
    $warnings | ForEach-Object { Write-Host "   $_" }
    Write-Host "   (advisory — commit no bloqueado)`n"
}
