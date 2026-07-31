# observability.md — Triggers de monitoreo Diligencia ↔ opencode/Chamber

**Versión:** v3.10.0
**Propósito:** definir QUÉ vigilar, CUÁNDO, CÓMO alertar, y DÓNDE mirar.
**Última actualización:** 2026-07-31

---

## 🔴 Alta prioridad — Chequear CADA sesión

### Trigger 1 — Estado opencode serve

**Cuándo:** siempre antes de actuar
**Cómo:** `curl http://localhost:4096/global/health` o `curl http://100.120.192.43:4096/global/health` (Tailscale)
**Esperado:** `{"healthy":true,"version":"1.18.9"}`
**Si falla:** matar zombies, relanzar `opencode serve`, validar JSONC (`opencode debug config`)

### Trigger 2 — Provider MiniMax auth

**Cuándo:** antes de tareas costosas
**Cómo:** `cat ~/.local/share/opencode/auth.json | jq`
**Esperado:** clave presente bajo `minimax-coding-plan` (o `minimax` según versión)
**Si falla:** el usuario debe renovar token o `/connect` desde TUI

### Trigger 3 — Working tree Diligencia

**Cuándo:** siempre
**Cómo:** `git status --short --branch` en `C:\xampp\htdocs\Diligencia`
**Esperado:** limpio, sincronizado con `origin/master`
**Si falla:** avisar y proponer resolución con `/CBP version`

### Trigger 4 — Tunnel ngrok dual

**Cuándo:** antes de ofrecer acceso público
**Cómo:** `curl http://localhost:4040/api/tunnels`
**Esperado:** 2 tunnels activos (`chamber` → :57123, `opencode` → :4096)
**Si falla:** relanzar `ngrok start --all`

---

## 🟡 Media prioridad — Chequear semanalmente

### Trigger 5 — Validación de JSONC contra schema

**Cuándo:** después de CUALQUIER cambio a `~/.config/opencode/opencode.jsonc`
**Cómo:** ejecutar `opencode debug config` desde terminal
**Esperado:** exit 0, sin warnings
**Si falla:** ICT bloqueante (ICT-DIL-20260731-01). Restaurar manualmente.

### Trigger 6 — BOM check (riesgo latente)

**Cuándo:** después de escribir JSONC con PowerShell
**Cómo:** `[System.IO.File]::ReadAllBytes($path)[0..2]` debe ser `0x7B 0x0A 0x20` o `0x7B 0x0D 0x0A`. **Nunca** `0xEF 0xBB 0xBF` (BOM UTF-8 rompe JSON).
**Si aparece BOM:** reescribir con encoding UTF-8 sin BOM o con `:PSDefaultParameterValues` no.

### Trigger 7 — Agentes custom válidos

**Cuándo:** después de crear/editar agents en `~/.config/opencode/agents/`
**Cómo:** reiniciar opencode serve + `curl ... /agent | jq` y verificar que aparezca
**Esperado:** cada agent nuevo visible en `/agent` API
**Si falla:** revisar frontmatter (modo, modelo, provider built-in)

### Trigger 8 — Drift fork Chamber vs upstream

**Cuándo:** mensualmente o cuando Chamber publique release
**Cómo:** `cd openchamber fork; git log --oneline HEAD..origin/main | wc -l`
**Esperado:** <50 commits de drift (revisar selectivamente)
**Si falla:** mergear cambios upstream críticos (security patches)

### Trigger 9 — Saldo MiniMax

**Cuándo:** antes de tareas largas
**Cómo:** `curl -H "Authorization: Bearer $MINIMAX_API_KEY" https://api.minimax.io/user/balance`
**Esperado:** `balance > $1 USD` (alerta si < $0.50)
**Si falla:** circuit breaker en `invoke-agent-task.ps1` ya lo bloquea

---

## 🟢 Baja prioridad — Chequear mensualmente

### Trigger 10 — Free tier ngrok bandwidth

**Cuándo:** mensualmente
**Cómo:** `ngrok --help` o dashboard web
**Esperado:** <80% bandwidth usado
**Si falla:** upgrade a plan pago o usar Tailscale

### Trigger 11 — Documentos sincronizados

**Cuándo:** mensualmente (o antes de cerrar sesión)
**Cómo:** comparar `DILIGENCIA.md` header con `AGENTS.md` R-numbers
**Esperado:** consistente
**Si falla:** `/version` o bump correctivo

### Trigger 12 — `.old/` backup growth

**Cuándo:** mensualmente
**Cómo:** `Get-ChildItem .old/salud-backups/ | Measure-Object`
**Esperado:** ≤ 5 backups (per `$BACKUP_KEEP`)
**Si falla:** pruning activo en install-services.ps1

---

## ⚠️ Cuándo alertar al usuario inmediatamente

| Disparo | Acción del agente |
|---|---|
| `opencode debug config` retorna error | STOP + avisar — ICT bloqueante |
| `global/health` falla por >5 min | Avisar + matar zombies + relanzar |
| Saldo MiniMax < $0.50 | Avisar — circuit breaker próximo |
| Working tree Diligencia con cambios sin commit | Avisar + sugerir commit |
| ngrok URL cambió | Avisar + actualizar bookmarks del usuario |
| Fork Chamber diverge >100 commits | Sugerir merge selective |
| Auth.json no tiene MiniMax | Avisar — provider sin credenciales |

---

## 🔄 Checklist de inicio de sesión

Para cualquier acción en Diligencia/opencode/Chamber:

```
1. pwd → confirmar CWD
2. git status --short --branch → confirmar clean + origin/master synced
3. curl http://localhost:4096/global/health → confirmar server vivo
4. curl -H "..." https://api.minimax.io/user/balance → confirmar saldo
5. opencode debug config → confirmar JSONC válido
6. curl http://localhost:4040/api/tunnels → confirmar tunnels activos
7. Test 1 sesión API → confirmar e2e pipeline funcional
8. Proceder con la tarea solicitada
```

---

## 📂 Dónde mirar primero

| Si el problema es... | Archivo |
|---|---|
| opencode no arranca | `doc/refs/opencode-schema.md`, `doc/refs/opencode-troubleshooting.md` |
| Chamber tunnel falla | `doc/refs/openchamber-overview.md`, `~/.config/ngrok/ngrok.yml` |
| MiniMax no responde | `opencode.jsonc` provider config, `auth.json`, R79.1 burn rate docs |
| Diligencia scripts fallan | `scripts/ensure-config.ps1`, `scripts/invoke-agent-task.ps1` |
| Schema custom keys | `doc/refs/integration-patterns.md` #1, #2 |
| ICT reportado en incidentes | `doc/arch/incidentes.md` |

---

## 🤖 Monitoreo automático (siguiente fase)

Una vez instalada la skill `@diligencia-ops`, el agente opencode ejecutará este checklist en cada sesión. Por ahora lo ejecuto manualmente.

---

## 📚 Files relacionados

- `doc/refs/opencode-schema.md` — schema oficial
- `doc/refs/openchamber-overview.md` — arquitectura Chamber
- `doc/refs/opencode-troubleshooting.md` — issues frecuentes
- `doc/refs/integration-patterns.md` — 7 patrones + 6 anti-patrones
- `doc/arch/incidentes.md` — historial ICTs
- `AGENTS.md` R79.1 — burn rate discipline (referencia)
