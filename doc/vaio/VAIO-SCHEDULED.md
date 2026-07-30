# VAIO-SCHEDULED — Worker autónomo via Chamber Scheduled Tasks v3.0

> ⚠️ **FALLBACK (2026-07-30).**
> El sistema principal ahora es `opencode serve` API directa (vía `invoke-agent-task.ps1`).
> Chamber Scheduled Tasks son solo para health checks y watchdog.
> Ver `doc/mecanicas/MECANICA-API-COMUNICACION.md` para el sistema activo.

---

## Arquitectura actual (post-R78)

```
PC Personal ←──HTTP/SSE──→ VAIO: opencode serve :4096  ←── Motor principal (NUEVO)
                                   │
PC Personal ←──Tunnel──→ VAIO: Chamber :57123      ←── Fallback + health
                                   │
                                   └── Scheduled Task: server-health (cada 5 min)
                                       Verifica que opencode serve responda.
```

---

## Scheduled Tasks activas

### 1. server-health (NUEVA — reemplaza check-tareas + publish-url)

| Campo | Valor |
|---|---|
| Name | VAIO: server-health |
| Project | Diligencia |
| Schedule | `*/5 * * * *` (cada 5 minutos) |
| Agent | build |
| Model | deepseek-v4-flash |
| Auto-approve | On |
| Prompt | Verifica que opencode serve este respondiendo. `curl.exe -s http://localhost:4096/global/health`. Si responde: responde "OK — server online". Si NO responde: ejecuta `doc\vaio\scripts\start-opencode-server.ps1 -Port 4096 -Lan -Kill -Password $env:OPENCODE_SERVER_PASSWORD` para reiniciarlo. Reporta "REINICIADO" o "ERROR". |

---

## Scheduled Tasks deprecadas

### 2. check-tareas 🔴 DEPRECADA (2026-07-29, REFORZADA 2026-07-30 R79.1)

| Campo | Valor |
|---|---|
| Name | VAIO: check-tareas |
| Estado | **ELIMINADA + auto-resurrector deshabilitado** — Reemplazada por `scripts/check-tareas.ps1` (pure PowerShell, 0 tokens) |
| Motivo | Causo incidente de burn rate USD 10/dia (cron `* * * * *` con `deepseek-v4-pro`). R79.1 burn rate discipline. |

### 3. publish-url 🔴 DEPRECADA (2026-07-29, REFORZADA 2026-07-30 R79.1)

| Campo | Valor |
|---|---|
| Name | VAIO: publish-url |
| Estado | **ELIMINADA** — Reemplazada por `doc/vaio/watchdog-tunnel.ps1` (pure PowerShell, publica URL en cada cambio) |
| Motivo | La URL del tunnel se publica via git auto-commit en watchdog cada 30s. Sin LLM. |

### 4. cloudflared-watchdog 🗑️ ELIMINADA (2026-07-26)

> Chamber gestiona el túnel nativamente desde OLA-CHAMBER-100.

---

## Troubleshooting

| Problema | Causa | Solución |
|---|---|---|
| server-health falla | opencode serve caido | La misma tarea intenta reiniciarlo. Si persiste: acceso fisico a VAIO |
| Tunnel caido | Chamber no corriendo | Acceso fisico. `start-opencode-server.ps1 -Kill` |
| Sin acceso a VAIO | Ambos canales caidos | Acceso fisico. Ver `GUIA_RECUPERACION_VAIO.md` |

---

## Archivos relacionados

- `doc/mecanicas/MECANICA-SERVIDOR-AUTONOMO.md` — nueva arquitectura (sistema principal)
- `doc/vaio/scripts/start-opencode-server.ps1` — lanzador de opencode serve
- `scripts/invoke-agent-task.ps1` — cliente para enviar tareas desde PC
- `scripts/watch-server.ps1` — dashboard/monitoreo desde PC
- `doc/vaio/GUIA_RECUPERACION_VAIO.md` — recovery checklist completo
- `doc/vaio/tasks/DEPRECADO.md` — flag de deprecacion del sistema viejo
- `AGENTS.md` — reglas R14-R15
