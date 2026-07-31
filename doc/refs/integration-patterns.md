# integration-patterns.md — Patrones Diligencia ↔ opencode/Chamber

**Versión:** v3.10.0
**Estado:** Estable después de ICT-DIL-20260731-01
**Severidad:** Este documento es CANÓNICO para cualquier integración futura.

---

## 🎯 Principio fundamental

> **Separar metadata de gobernanza (Diligencia) de config de herramientas (opencode/Chamber).**

Diferentes dominios → diferentes archivos.

---

## ✅ Patrón 1 — Metadata Diligencia en archivo externo

**Cuándo usar:** tracking de versión de política, ownership, scope, incidents.

**Cómo:**
```powershell
# Crear archivo externo (no romper schema de opencode)
$metaPath = "$env:USERPROFILE\.config\opencode\.diligencia.json"
$meta = @{
  managed = $true
  methodology = "Diligencia"
  methodology_version = "v3.10.0"
  policy_version = "R79.1"
  burn_rate_incident = "ICT-DIL-20260731-01"
  owner = "$env:USERNAME"
}
$meta | ConvertTo-Json | Set-Content $metaPath
```

**Leer desde opencode.jsonc:**
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "minimax/MiniMax-M2.7",
  "_comment_diligencia": "Managed by Diligencia v3.10.0 — see .diligencia.json"
}
```

El `_comment_*` con prefijo `_comment_` SÍ es válido en JSONC (los comentarios `//` son válidos pero el prefijo en JSON key es decorativo, no validado).

---

## ✅ Patrón 2 — Directivas Diligencia en archivo externo + `{file:...}`

**Cuándo usar:** instrucciones grandes (muchas líneas), reglas que cambian frecuente.

**Cómo crear archivo** (recomendado en `.diligencia/policy.md` o `~/.config/opencode/diligencia/policy.md`):
```markdown
# Diligencia Policy — R79.1

## Reglas vinculantes

1. Responder siempre en español.
2. No ejecutar git commit sin autorización.
3. Scope filter: solo escribir en `*.ps1` y `*.md`.
4. Bootstrap lazy: omitir directivas si prompt es trivial.
5. Balance pre-flight: abortar si balance < 0.50 USD.
6. ...
```

**Inyectar en opencode.jsonc:**
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "minimax/MiniMax-M2.7",
  "instructions": [
    "{env:HOME}/.config/opencode/diligencia/policy.md",
    ".diligencia/instructions/*.md"
  ]
}
```

`instructions` SÍ es schema válido. Acepta array de paths/globs.

---

## ✅ Patrón 3 — Custom agents en markdown, sin tocar schema

**Cuándo usar:** agents específicos como `@server-admin`, `@code-reviewer`.

**Cómo:** colocar en `~/.config/opencode/agents/` (global) o `.opencode/agents/` (proyecto):

```markdown
---
description: Sysadmin remoto del server VAIO
mode: subagent
model: minimax/MiniMax-M2.7
temperature: 0.1
permission:
  bash:
    "*": "ask"
    "Get-Process *": "allow"
    "tailscale *": "allow"
---

Eres el **administrador del server VAIO**...
```

Los agents en markdown son cargados automáticamente — sin tocar JSONC.

---

## ✅ Patrón 4 — Provider MiniMax via auth.json (no en JSONC)

**Cuándo usar:** agregar MiniMax como provider.

**No hacer:**
```jsonc
// ❌ ROMPE SCHEMA (ICT-DIL-20260731-01)
"provider": {
  "minimax": {
    "npm": "@ai-sdk/anthropic",
    "options": { "baseURL": "...", "apiKey": "..." }
  }
}
```

**Hacer:**
```bash
# Configurar auth via /connect dentro del TUI
# O setear env var: $env:MINIMAX_API_KEY = "..."
# auth se guarda en: ~/.local/share/opencode/auth.json
```

Provider MiniMax es **built-in** en opencode. Solo necesita credenciales, no config custom.

---

## ✅ Patrón 5 — Tunnel ngrok dual (Chamber + opencode)

**Cuándo usar:** exponer Chamber (:57123) Y opencode serve (:4096) públicamente.

**Crear config file** en `~/.config/ngrok/ngrok.yml`:
```yaml
version: "2"
authtoken: <tu-token>
tunnels:
  chamber:
    proto: http
    addr: 57123
  opencode:
    proto: http
    addr: 4096
```

**Arrancar:**
```bash
ngrok start --all
```

**Resultado:** 1 ngrok corre 2 tunnels, ambos bajo `https://<random>.ngrok-free.dev` (free tier) en puertos internos distintos.

---

## ✅ Patrón 6 — Pre-flight validation antes de cualquier edit

**Cuándo usar:** ANTES de escribir cualquier cambio a `~/.config/opencode/opencode.jsonc`.

```powershell
# Script: scripts/validate-opencode-config.ps1
$configPath = "$env:USERPROFILE\.config\opencode\opencode.jsonc"
$validKeys = @(
    '$schema','model','small_model','default_agent','agent','subagent_depth',
    'permission','instructions','shell','tools','provider','provider_overrides',
    'disabled_providers','enabled_providers','mcp','lsp','formatter','plugin',
    'server','autoupdate','snapshot','share','watcher','compaction','attachment',
    'experimental'
)

$json = Get-Content $configPath -Raw | ConvertFrom-Json
$bad = @()
foreach ($prop in $json.PSObject.Properties) {
    if ($prop.Name -notin $validKeys) { $bad += $prop.Name }
}
if ($bad.Count -gt 0) {
    Write-Host "ERROR: Custom keys detectadas: $($bad -join ', ')"
    exit 1
}
Write-Host "OK: schema valido"
```

---

## ✅ Patrón 7 — Watchdog persistente con script adapter

**Cuándo usar:** opencode serve debe sobrevivir reboots.

```powershell
# scripts/install-services.ps1 ya existe, ejecuta como admin
$content = @"
@echo off
set OPENCODE_SERVER_USERNAME=diligencia
set OPENCODE_SERVER_PASSWORD=diligencia-vaio-2026
"$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\opencode-cli\opencode.exe" serve --port 4096 --hostname 0.0.0.0
"@
Set-Content "$env:TEMP\opencode-adapter.cmd" -Value $content
```

Luego el `install-services.ps1` apunta a este adapter.

---

## ❌ Anti-patrones (NUNCA hacer)

| Anti-patrón | Por qué |
|---|---|
| Agregar `_diligencia` u otra custom key a `opencode.jsonc` | Schema strict rechaza (ICT-DIL-20260731-01) |
| Hardcodear API keys en el JSONC | Inseguro, encriptado solo via `~/.local/share/opencode/auth.json` |
| Asumir que `opencode serve` y `opencode` CLI validan igual | `serve` NO valida strict; CLI SÍ |
| Crear sub-keys de providers custom en JSONC | MiniMax es built-in, solo necesita auth |
| Compartir JSONC con `//` en lugares donde opencode espera JSON puro | opencode parsea como JSONC pero providers/agents externos no |

---

## 🛡️ Validación previa (pre-flight) - OBLIGATORIO

Antes de commit cualquer cambio que toque:
- `~/.config/opencode/opencode.jsonc`
- `~/.config/opencode/agents/*.md`
- `~/.config/opencode/commands/*.md`
- Cualquier archivo en `~/.config/opencode/`

**Checklist:**
1. ✅ Validar contra schema (Patrón 6)
2. ✅ Probar `opencode debug config` → exit 0
3. ✅ Probar `opencode serve --help` → exit 0
4. ✅ Reiniciar `opencode serve` y verificar `/health`
5. ✅ Si se modifica provider, verificar auth.json

---

## 🔄 Workflow completo de un cambio

```
1. Modificar archivo
   ↓
2. Pre-flight validation (Patrón 6)
   ↓
3. opencode debug config (CLI smoke test)
   ↓
4. Si OK: commit
   ↓
5. Reiniciar opencode serve (si aplica)
   ↓
6. Verificar /health y /config
   ↓
7. Bump Diligencia version
   ↓
8. CHANGELOG entry
   ↓
9. Documentar en doc/arch/incidentes.md (si fue fix)
```

---

## 📚 Files relacionados
- `doc/refs/opencode-schema.md` — schema completo
- `doc/refs/openchamber-overview.md` — arquitectura Chamber
- `doc/arch/incidentes.md` — `ICT-DIL-20260731-01` causa este documento
- `scripts/ensure-config.ps1` — script corregido (sin custom keys)
- `scripts/validate-opencode-config.ps1` (a crear) — pre-flight
