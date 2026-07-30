# Tarea 051 — Configurar DeepSeek API key en opencode serve

> **Prioridad:** P1 — BLOQUEANTE
> `opencode serve` responde health check pero el agente falla con "Unexpected server error"
> Causa: falta la API key de DeepSeek en el entorno de `opencode serve`.

---

## Fase A — Sincronizar

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
Write-Host "Repo actualizado"
```

## Fase B — Buscar la API key de DeepSeek

```powershell
Write-Host "=== Buscando DEEPSEEK_API_KEY ==="

$foundKey = $null

# 1. Variable de entorno actual
Write-Host "1. Revisando env:DEEPSEEK_API_KEY..."
$foundKey = $env:DEEPSEEK_API_KEY
if ($foundKey) { Write-Host "  ENCONTRADA en variable de entorno" }

# 2. Config de opencode (opencode.json)
if (-not $foundKey) {
    Write-Host "2. Revisando opencode.json..."
    $configPaths = @(
        "$env:HOME\.config\opencode\opencode.json",
        "$env:USERPROFILE\.config\opencode\opencode.json",
        "$env:LOCALAPPDATA\opencode\config.json",
        "$env:APPDATA\opencode\config.json"
    )
    foreach ($p in $configPaths) {
        if (Test-Path $p) {
            Write-Host "  Leyendo: $p"
            try {
                $config = Get-Content $p -Raw -Encoding UTF8 | ConvertFrom-Json
                # Buscar deepseek en providers
                if ($config.providers) {
                    $config.providers.PSObject.Properties | ForEach-Object {
                        if ($_.Name -like "*deepseek*") {
                            if ($_.Value.apiKey) { $foundKey = $_.Value.apiKey; Write-Host "  ENCONTRADA en providers" }
                            if ($_.Value.api_key) { $foundKey = $_.Value.api_key; Write-Host "  ENCONTRADA en providers.api_key" }
                        }
                    }
                }
                # Buscar en keys
                if (-not $foundKey -and $config.keys) {
                    $config.keys.PSObject.Properties | ForEach-Object {
                        if ($_.Name -like "*deepseek*") {
                            $foundKey = $_.Value; Write-Host "  ENCONTRADA en keys"
                        }
                    }
                }
            } catch {
                Write-Host "  Error leyendo $p : $_"
            }
        }
    }
}

# 3. Revisar Chamber config
if (-not $foundKey) {
    Write-Host "3. Revisando config de Chamber..."
    $chamberPaths = @(
        "$env:USERPROFILE\.config\openchamber\config.json",
        "$env:LOCALAPPDATA\openchamber\config.json",
        "$env:APPDATA\openchamber\config.json"
    )
    foreach ($p in $chamberPaths) {
        if (Test-Path $p) {
            Write-Host "  Leyendo: $p"
            try {
                $config = Get-Content $p -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($config.apiKeys) {
                    $config.apiKeys.PSObject.Properties | ForEach-Object {
                        if ($_.Name -like "*deepseek*") {
                            $foundKey = $_.Value; Write-Host "  ENCONTRADA en Chamber config"
                        }
                    }
                }
            } catch { Write-Host "  Error: $_" }
        }
    }
}

if ($foundKey) {
    Write-Host ""
    Write-Host "DEEPSEEK_API_KEY encontrada. Configurando..."
} else {
    Write-Host ""
    Write-Host "NO se encontro DEEPSEEK_API_KEY en ninguna configuracion."
    Write-Host "Necesitas proporcionarla manualmente en VAIO."
}
```

## Fase C — Configurar variable de entorno y reiniciar

```powershell
if ($foundKey) {
    Write-Host "=== Configurando variable de entorno ==="

    # Setear en proceso actual
    $env:DEEPSEEK_API_KEY = $foundKey

    # Persistir a nivel usuario
    [Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", $foundKey, "User")
    [Environment]::SetEnvironmentVariable("OPENCODE_SERVER_USERNAME", "diligencia", "User")
    [Environment]::SetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", "diligencia-vaio-2026", "User")

    Write-Host "Variables configuradas."

    # Reiniciar opencode serve
    Write-Host "Reiniciando opencode serve..."
    Get-Process opencode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3

    $env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
    $env:OPENCODE_SERVER_USERNAME = "diligencia"

    Start-Process -FilePath "opencode" `
        -ArgumentList "serve", "--port", "4096", "--hostname", "0.0.0.0" `
        -NoNewWindow -PassThru `
        -RedirectStandardOutput "$env:TEMP\opencode-server-stdout.log" `
        -RedirectStandardError "$env:TEMP\opencode-server-stderr.log"

    Start-Sleep -Seconds 5

    # Verificar health
    try {
        $health = curl.exe -s http://localhost:4096/global/health
        Write-Host "Health: $health"
    } catch { Write-Host "Health: FALLO" }
} else {
    Write-Host "No se configuro nada (API key no encontrada)."
}
```

## Fase D — Self-test con un prompt real

```powershell
if ($foundKey) {
    Write-Host "=== Self-test: enviando prompt de prueba ==="

    $sessionTest = curl.exe -s -X POST http://localhost:4096/session `
      -H "Content-Type: application/json" -u diligencia:diligencia-vaio-2026 `
      -d '{"title":"[VAIO] Self-test post-config"}'

    $testId = if ($sessionTest) { ($sessionTest | ConvertFrom-Json).id } else { $null }

    if ($testId) {
        Write-Host "Sesion creada: $testId"

        $result = curl.exe -s -X POST "http://localhost:4096/session/$testId/message" `
          -H "Content-Type: application/json" -u diligencia:diligencia-vaio-2026 `
          -d '{"parts":[{"type":"text","text":"Responde OK si me escuchas"}],"model":{"providerID":"opencode","modelID":"deepseek-v4-flash"}}' `
          --max-time 120

        Write-Host "Resultado del test:"
        Write-Host $result

        $testOk = ($result -match "OK")
    } else {
        Write-Host "No se pudo crear sesion de test."
        $testOk = $false
    }
} else {
    $testOk = $false
}
```

## Fase E — Escribir resultado

```powershell
$resultado = @"
# Resultado 051 — Configuracion de DeepSeek API key

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

| Componente | Estado |
|---|---|
| DEEPSEEK_API_KEY encontrada | $(if ($foundKey) { "SI" } else { "NO - necesita config manual" }) |
| Variable de entorno seteada | $(if ($foundKey) { "SI" } else { "NO" }) |
| opencode serve post-config | $(try { curl.exe -s http://localhost:4096/global/health | ConvertFrom-Json | Select-Object -ExpandProperty healthy } catch { "NO RESPONDE" }) |
| Self-test | $(if ($testOk) { "OK - agente responde" } else { "FALLO - ver log abajo" }) |
"@

Set-Content -Path "doc\vaio\results\resultado-051.md" -Value $resultado -Encoding UTF8
Write-Host "Resultado escrito"
```

## Fase F — Commit + push

```powershell
git add -A
git commit -m "VAIO: resultado tarea 051 — configuracion DeepSeek API key"
git pull --rebase
git push
Write-Host "DONE"
```
