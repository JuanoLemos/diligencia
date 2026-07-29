# Tarea 040 — Aplicar tray fix al Electron EXE de VAIO

> **Objetivo:** Remover "Sessions" y "New Session" del menú contextual del tray de Chamber en VAIO.
> Igual que se hizo en PC Principal.
> El ASAR del Electron EXE necesita ser extraído, modificado y reempaquetado.

## Paso 1 — Instalar herramienta ASAR si no está

```powershell
$asarCmd = Get-Command npx -ErrorAction SilentlyContinue
if (-not $asarCmd) { "ERROR: npx no disponible — instalar Node.js"; exit 1 }
```

## Paso 2 — Backup del app.asar original

```powershell
$asarPath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar"
$backupPath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar.backup-tray"

if (-not (Test-Path $backupPath)) {
    Copy-Item $asarPath $backupPath -Force
    "Backup: $backupPath"
} else { "Backup ya existe" }
```

## Paso 3 — Detener Chamber Electron

```powershell
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
"Chamber Electron detenido"
```

## Paso 4 — Extraer ASAR

```powershell
$extractDir = "$env:TEMP\asar-vaio-tray-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

npx --yes @electron/asar extract $asarPath $extractDir 2>&1 | Out-Null
"ASAR extraído en $extractDir"
```

## Paso 5 — Modificar dist-bundle/main.mjs

```powershell
$mainFile = "$extractDir\dist-bundle\main.mjs"
$content = Get-Content $mainFile -Raw

Write-Host "=== Buscando bloque Sessions ==="
# Buscar el bloque que contiene "label: "Sessions""
if ($content -match ',?\s*\{\s*label:\s*"Sessions"\s*,\s*enabled:\s*false\s*\}') {
    Write-Host "Sessions encontrado — removiendo..."
    # Remover desde el inicio hasta "No active sessions" inclusive
    $content = $content -replace ',?\s*const sessionItem\s*=\s*\(session\)\s*=>\s*\{[^}]*\};[\s\S]*?(template\.push\(\{ label: "No active sessions", enabled: false \}\);|template\.push\(\{ label: "No active sessions" \}\))', ''
    Write-Host "Bloque Sessions removido"
} else {
    Write-Host "Sessions no encontrado — puede que ya esté aplicado"
}

# Buscar y remover "New Session" del tray
if ($content -match '\{ label: "New Session", click: \(\) => onAction\(\) \},') {
    $content = $content -replace '\{ label: "New Session", click: \(\) => onAction\(\) \},\s*', ''
    Write-Host "New Session removido"
} else {
    # Versión más específica
    $content = $content -replace '\{ label: "New Session", click: \(\) => onAction\(\{ type: "new-session" \}\) \},\s*', ''
    Write-Host "New Session removido (fallback)"
}

Set-Content $mainFile $content -Encoding UTF8 -NoNewline
Write-Host "main.mjs modificado"
```

## Paso 6 — Reempaquetar ASAR

```powershell
Remove-Item $asarPath -Force
npx --yes @electron/asar pack $extractDir $asarPath 2>&1 | Out-Null
"ASAR reempaquetado: $(($(Get-Item $asarPath).Length / 1MB).ToString('0.0')) MB"

# Limpiar temp
Remove-Item -Recurse -Force $extractDir
```

## Paso 7 — Iniciar Chamber Electro y verificar

```powershell
Start-Process -FilePath "$env:LOCALAPPDATA\Programs\@openchamberelectron\OpenChamber.exe"
Start-Sleep -Seconds 15

$r = curl.exe -s http://localhost:57123/api/openchamber/tunnel/status 2>$null
if ($r -match '"localPort"') { "Chamber Electro arrancó OK" } else { "ERROR" }
```

## Paso 8 — Restaurar dev server si estaba

```powershell
if (Test-Path "C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1") {
    powershell -ExecutionPolicy Bypass -File "C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1"
}
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 040 — Tray fix aplicado en VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Sessions removido | SI/NO |
| New Session removido | SI/NO |
| ASAR reempaquetado | SI/NO |
| Chamber arranca | SI/NO |
"@
Set-Content -Path "doc\vaio\results\resultado-040.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-040.md
git commit -m "VAIO: resultado tarea 040 — tray fix"
git pull --rebase
git push
```
