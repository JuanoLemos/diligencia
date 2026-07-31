# opencode-troubleshooting.md — Guía de troubleshooting rápido

**Propósito:** diagnósticos + fixes para los problemas MÁS COMUNES con opencode + Chamber.

---

## 1. "Configuration is invalid" / "Unrecognized key"

**Síntoma:**
```
Configuration is invalid at ~/.config/opencode/opencode.jsonc
↳ Unrecognized key: <nombre>
```

**Causa:** custom key en raíz que no es schema válido (ICT-DIL-20260731-01).

**Fix:**
1. Abrir `~/.config/opencode/opencode.jsonc`
2. Localizar y eliminar el bloque custom
3. Validar con `opencode debug config`

**Prevención:** ver `doc/refs/integration-patterns.md` #1.

---

## 2. "ServeError" en server

**Síntoma:**
- `opencode serve` arranca (`/health` OK)
- Pero requests devuelven 500 + `ServeError` en STDERR
- Posible: provider no encontrado, model inválido

**Diagnóstico:**
```bash
# Ver logs
Get-Content "$env:TEMP\opencode-server-stderr.log" -Tail 20
# Ver config cargado
curl -u "diligencia:diligencia-vaio-2026" http://localhost:4096/config
# Ver auth
cat ~/.local/share/opencode/auth.json | jq
```

**Fix común:** provider en `auth.json` no coincide con `model:` en JSONC.

---

## 3. Tunnel ngrok killed

**Síntoma:**
- `curl http://localhost:4040/api/tunnels` no responde
- O devuelve tunel vacío
- URL pública no responde

**Diagnóstico:**
```bash
Get-Process ngrok -ErrorAction SilentlyContinue
cat "$env:TEMP\ngrok-all.log" | Select-Object -Tail 20
```

**Fix:**
```powershell
Get-Process ngrok -ErrorAction SilentlyContinue | Stop-Process -Force
$ngrok = "C:\Users\jlemo\AppData\Local\Microsoft\WinGet\Links\ngrok.exe"
Start-Process -FilePath $ngrok -ArgumentList "start","--all" -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\ngrok-all.log"
```

---

## 4. Port 4096 ya en uso

**Síntoma:**
```
Port 4096 is already in use
```

**Diagnóstico:**
```powershell
Get-NetTCPConnection -LocalPort 4096 -State Listen
```

**Fix:**
```powershell
$pid = (Get-NetTCPConnection -LocalPort 4096 -State Listen).OwningProcess
Stop-Process -Id $pid -Force
```

---

## 5. opencode CLI crashea (vs serve funciona)

**Síntoma:**
- `opencode serve` funciona vía API
- `opencode` CLI/TUI crashea con error de validación

**Causa:** `serve` NO valida strict, `CLI` SÍ. Mi `ensure-config.ps1` (v3.9.0–v3.9.2) introdujo bloque `_diligencia` que solo crashea en CLI.

**Fix:** ver ICT-DIL-20260731-01 en `doc/arch/incidentes.md`. Asegurar versión ≥ v3.10.0.

---

## 6. Balance MiniMax bajo

**Síntoma:**
- `invoke-agent-task.ps1` aborta con "Balance below floor"
- `cost-tracker.ps1` muestra `balance_usd < 0.50`

**Causa:** saldo agotado.

**Fix:**
1. Usuario recarga saldo en https://platform.MiniMax.io
2. Actualiza env var `MINIMAX_API_KEY`
3. Re-ejecutar `/connect` desde TUI opencode

---

## 7. ngrok URL cambia después de restart

**Síntoma:**
- URL conocida ya no responde
- `curl https://antiguo.ngrok-free.dev` da 404

**Causa:** free tier rota URL en cada restart.

**Fix:**
- Si quieres URL estable: plan pago de ngrok
- O usar Tailscale (IP fija 100.120.192.43)

---

## 8. Agent custom no aparece en `/agent` API

**Síntoma:**
- Archivo `.md` existe en `~/.config/opencode/agents/`
- Pero `curl ... /agent | jq` no lo lista

**Causas comunes:**
1. **Provider en frontmatter no existe** → el agent se DROPEA silenciosamente. Ver R-numbers: `minimax` no es provider built-in, usar `minimax-coding-plan`
2. **Frontmatter syntax inválido** → revisar YAML
3. **`mode: primary` conflict** → `build` y `plan` son únicos primary. Usar `subagent`

**Diagnóstico:**
```bash
# Ver config cargado (agents)
curl -u "..." http://localhost:4096/config | jq '.agent'
```

---

## 9. WARN "BOM found" en JSONC

**Síntoma:**
- JSONC parsea en algunos parsers pero no en otros
- `opencode debug config` falla sin error visible

**Causa:** PowerShell `Out-File` o `Set-Content` a veces escribe BOM UTF-8 (3 bytes al inicio). opencode strict rechaza.

**Fix:**
```powershell
$utf8 = [System.Text.UTF8Encoding]::new($false)
$content = [System.IO.File]::ReadAllText($path, $utf8)
# Forzar rewrite sin BOM
[System.IO.File]::WriteAllText($path, $content, $utf8)
```

**Prevención:** usar `:Encoding utf8` o `.NET UTF-8 Encoding(false)` siempre.

---

## 10. PowerShell cuelga shell

**Síntoma:**
- Comando Bash no retorna
- Output timeout
- Shell trabado

**Causa:** PowerShell no soporta bien `Stop-Process` o algunos procesos con subprocess.

**Fix:** esperar o `Cancel-Process`. **NO** reintentar el mismo comando — delegar al usuario.

**Mitigación:** v3.10.0 separó concernes. Procesos críticos (opencode serve, Chamber) son manejados por watchdog del usuario, no por mí.

---

## 🎯 Comando universal de diagnóstico

Si algo anda mal, ejecutar primero:

```powershell
# 1. Diagnóstico en 5 líneas
$proc = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @("opencode","OpenChamber","ngrok") }
Write-Host "=== Procesos ==="; $proc | Format-Table Name, Id, StartTime -AutoSize
Write-Host "=== Puertos ==="; Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 4096,57123,4040,57125 } | Format-Table LocalPort, OwningProcess
Write-Host "=== Health opencode ==="; curl.exe -s -m 3 -u "diligencia:diligencia-vaio-2026" http://localhost:4096/global/health
Write-Host "=== Tunnel ngrok ==="; try { (Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -TimeoutSec 5).tunnels } catch { Write-Host "ngrok offline" }
Write-Host "=== Provider auth ==="; Get-Content "$env:LOCALAPPDATA\share\opencode\auth.json" -Raw | ConvertFrom-Json | Select-Object -ExpandProperty PSObject -Property Name
```

Ese bloque da la foto completa del stack en 10 segundos.

---

## 📚 Files relacionados
- `doc/refs/observability.md` — triggers de monitoreo
- `doc/arch/incidentes.md` — ICTs resueltos
- `doc/refs/opencode-schema.md` — schema oficial
- `doc/refs/integration-patterns.md` — patrones seguros
- `doc/refs/openchamber-overview.md` — Chamber
