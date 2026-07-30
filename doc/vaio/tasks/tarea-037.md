# Tarea 037 - Actualizar contexto deepseek-v4-pro a 1M en VAIO [DEPRECATED]

> **DEPRECATED (R79.1, 2026-07-30):** Esta tarea incremento el contexto a 1M, lo cual
> **causo el incidente de burn rate USD 10/dia** (mas tokens input por sesion persistente).
> Reemplazada por `scripts/ensure-config.ps1` que mantiene `maxTokens: 128000` y revierte
> cualquier drift a 1M. Ver AGENTS.md R79.1.
>
> **Politica actual:** deepseek-v4-pro se mantiene en `maxTokens: 128000` (default API).

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
