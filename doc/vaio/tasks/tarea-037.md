# Tarea 037 — Actualizar contexto deepseek-v4-pro a 1M en VAIO

> El contexto de deepseek-v4-pro está en 128K. Debería ser 1M.

```powershell
$configPath = "$env:USERPROFILE\.config\opencode\opencode.jsonc"
$c = Get-Content $configPath -Raw

if ($c -match '"context": 128000') {
    $c = $c -replace '"context": 128000', '"context": 1000000'
    $c | Set-Content $configPath -Encoding UTF8
    "Config actualizada: deepseek-v4-pro contexto 1M"
} else {
    "Ya tiene 1M o el formato es diferente"
}

# Verificar
Select-String -Path $configPath -Pattern "context" -Context 1,1
```
