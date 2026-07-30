# Tarea 050 — Configurar provider en opencode serve

> **Prioridad:** P1 — CRITICO
> `opencode serve` responde al health check y acepta sesiones,
> pero el agente falla con "Unexpected server error" al procesar prompts.
> Causa: missing provider (DeepSeek V4 Flash/Pro).

---

## Fase A — Sincronizar

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
```

## Fase B — Diagnosticar config de opencode

```powershell
Write-Host "=== Diagnostico de provider ==="

# Ver que API keys estan configuradas en entorno
Write-Host "Variables provider en entorno:"
Get-ChildItem Env: | Where-Object { $_.Name -match "OPENCODE|DEEPSEEK|ANTHROPIC|OPENAI" } | Format-Table Name, Value -AutoSize

# Ver config de opencode
$opencodeConfig = "$env:HOME\.config\opencode\opencode.json"
if (-not (Test-Path $opencodeConfig)) {
    $opencodeConfig = "$env:USERPROFILE\.config\opencode\opencode.json"
    if (-not (Test-Path $opencodeConfig)) {
        $opencodeConfig = "$env:LOCALAPPDATA\opencode\config.json"
    }
}

if (Test-Path $opencodeConfig) {
    Write-Host "Config encontrado en: $opencodeConfig"
    $config = Get-Content $opencodeConfig -Raw | ConvertFrom-Json
    Write-Host "Keys configuradas:"
    $config.keys.PSObject.Properties | ForEach-Object {
        Write-Host "  $($_.Name) = $(if ($_.Value) { 'SI (oculta)' } else { 'VACIO' })"
    }
    Write-Host "Providers activos:"
    $config.providers.PSObject.Properties | ForEach-Object { Write-Host "  $($_.Name)" }
} else {
    Write-Host "No se encontro config de opencode"
}

# Ver log de errores de opencode serve
$logPath = "$env:TEMP\opencode-server-stderr.log"
if (Test-Path $logPath) {
    Write-Host "=== ULTIMAS 30 LINEAS DEL LOG DE ERRORES ==="
    Get-Content $logPath -Tail 30 -ErrorAction SilentlyContinue
}
```

## Fase C — Probar con un modelo local/alternativo

```powershell
Write-Host "=== Prueba con modelo alternativo ==="

# Crear sesion de prueba
$sessionTest = curl.exe -s -X POST http://localhost:4096/session `
  -H "Content-Type: application/json" -u diligencia:diligencia-vaio-2026 `
  -d '{"title":"Test: git status"}'

$testId = ($sessionTest | ConvertFrom-Json).id
Write-Host "Sesion test: $testId"

# Intentar enviar prompt con modelo default (sin especificar model)
$testMsg = curl.exe -s -X POST "http://localhost:4096/session/$testId/message" `
  -H "Content-Type: application/json" -u diligencia:diligencia-vaio-2026 `
  -d '{"parts":[{"type":"text","text":"Ejecuta `git status` en C:\xampp\htdocs\Diligencia y responde. No modifiques nada."}]}' `
  --max-time 120

Write-Host "Resultado:"
Write-Host $testMsg
```

## Fase D — Configurar DeepSeek si es necesario

```powershell
Write-Host "=== Configurar provider DeepSeek ==="

# Buscar ruta de config de opencode
$configPaths = @(
    "$env:HOME\.config\opencode\opencode.json",
    "$env:USERPROFILE\.config\opencode\opencode.json", 
    "$env:LOCALAPPDATA\opencode\config.json"
)

$configPath = $null
foreach ($p in $configPaths) {
    if (Test-Path $p) { $configPath = $p; break }
}

if ($configPath) {
    Write-Host "Config en: $configPath"
} else {
    Write-Host "No hay config de opencode. Creando config por defecto..."
    $defaultDir = "$env:USERPROFILE\.config\opencode"
    New-Item -ItemType Directory -Path $defaultDir -Force | Out-Null
    $configPath = "$defaultDir\opencode.json"
    '{}' | Set-Content -Path $configPath -Encoding UTF8
}

# Verificar si DEEPSEEK_API_KEY existe
$deepseekKey = $env:DEEPSEEK_API_KEY
if (-not $deepseekKey) {
    Write-Host "DEEPSEEK_API_KEY no esta en entorno."
    Write-Host "El provider DeepSeek no esta configurado."
    Write-Host ""
    Write-Host "SOLUCION: Configurar API key de DeepSeek en VAIO."
    Write-Host "Necesitas una API key de DeepSeek para que opencode serve funcione."
} else {
    Write-Host "DEEPSEEK_API_KEY encontrada en entorno."
}
```

## Fase E — Escribir resultado

```powershell
$resultado = @"
# Resultado 050 — Diagnostico de provider en opencode serve

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

## Estado

$(if ($deepseekKey) { 
    "DeepSeek API key encontrada en entorno. opencode serve deberia funcionar."
} else {
    "DEEPSEEK_API_KEY no configurada. El agente no puede procesar prompts sin esta key."
})

## Log de errores

$(if (Test-Path "$env:TEMP\opencode-server-stderr.log") { 
    Get-Content "$env:TEMP\opencode-server-stderr.log" -Tail 20 -ErrorAction SilentlyContinue | Out-String
} else { "No hay log disponible" })

## Para que opencode serve funcione con DeepSeek

Ejecutar en VAIO:

\`\`\`powershell
`$env:DEEPSEEK_API_KEY = "tu-api-key-aqui"
[Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", "tu-api-key-aqui", "User")

# Reiniciar opencode serve
Get-Process opencode | Stop-Process -Force
Start-Sleep -Seconds 3
.\doc\vaio\scripts\start-opencode-server.ps1 -Port 4096 -Lan -Password "diligencia-vaio-2026"
\`\`\`
"@

Set-Content -Path "doc\vaio\results\resultado-050.md" -Value $resultado -Encoding UTF8
Write-Host "Resultado escrito"
```

## Fase G — Commit + push

```powershell
git add -A
git commit -m "VAIO: resultado tarea 050 — diagnostico de provider"
git pull --rebase
git push
Write-Host "DONE"
```
