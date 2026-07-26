# MECANICA-CHAMBER-FIRST — Migración a funcionalidades nativas de Chamber v1.0

> Plan estratégico. Chamber ya tiene muchas de las herramientas que construimos manualmente.
> El objetivo es migrar hacia lo nativo de Chamber donde tenga sentido, sin romper lo que funciona.

---

## Principio

> Si Chamber ya lo tiene, lo usamos. Si no lo tiene, lo construimos sin salir de Chamber.

---

## Auditoría: lo nuestro vs lo de Chamber

| Sistema nuestro | Chamber ofrece | Decisión | Estado |
|---|---|---|---|
| `startup-tunnel.ps1` + `cloudflared-url.md` | **Tunnel System**: Cloudflare quick/managed-remote/managed-local, Ngrok, API status | **Migrar** | ✅ OLA-CHAMBER-100 |
| `worker-loop.md` (deprecado) | **Scheduled Tasks**: cron/daily/weekly, concurrencia 4/2, SSE events, persistencia | ✅ Ya migrado | ✅ |
| `watchdog cloudflared` (cada 5 min) | **Scheduled Task** `cloudflared-watchdog` | ✅ Ya migrado → 🗑️ Deprecado | 🗑️ |
| `GUIA_CONTROL_REMOTO.md` (VS Code Remote) | **SSH Remote Instances**: desktop SSH manager, managed/external | **Evaluar** | ⏳ |
| vscode.dev para terminal | **Terminal integrado**: WebSocket WS protocol, en misma UI que el chat | **Migrar** | ✅ OLA-CHAMBER-100 |
| `worker-log.md` manual | **SSE events** + Scheduled Tasks status API | **Migrar** | ✅ OLA-CHAMBER-100 |
| `codebase-memory-mcp` localhost | **MCP Servers**: UI completa, local/remote, scopes, OAuth | **Migrar** | ⏳ Pendiente (sin source) |
| Skills locales en `~/.config/opencode/skills/` | **Skills Catalog** en Chamber (UI + publish) | **Migrar** | ✅ OLA-CHAMBER-100 |
| `doc/vaio/tasks/` + `doc/vaio/results/` (git bridge) | **Scheduled Tasks** ejecutan prompts directamente | **Mantener** (universal) | ✅ |
| `AGENTS.md` + R14/R15 | Gobierno de Diligencia, no de Chamber | **Mantener** | ✅ |

---

## Fases

---

### Fase 1 — Túneles nativos de Chamber ✅ COMPLETADO

| Tarea | Estado |
|---|---|
| Reemplazar `startup-tunnel.ps1` por tunnel nativo de Chamber | ✅ Quick mode activado (sin Zero Trust) |
| Obtener URL vía API en vez de archivo | ✅ `GET /api/openchamber/tunnel/status` |
| Deprecar `cloudflared-url.md` — campo PID reemplazado por Fuente | ✅ Documentación actualizada |

**Logro:** Tunnel quick mode funcionando. `startup-tunnel.ps1` deprecado. URL accesible vía API.
**Pendiente:** `managed-remote` requiere cuenta Cloudflare Zero Trust.

**Detalle:** Se usó `mode: "quick"` (trycloudflare). Para URL persistente migrar a `mode: "managed-remote"` cuando haya cuenta Zero Trust.

---

### Fase 2 — Terminal integrado ✅ COMPLETADO

Chamber tiene un terminal WebSocket (`POST /api/terminal/create` + WebSocket `/api/terminal/ws`) que permite:
- Ejecutar comandos en el servidor desde la UI de Chamber
- Sin necesidad de abrir vscode.dev
- El terminal está al lado del chat en la misma interfaz

**Logro:** Terminal API probado y funcionando. `GUIA_CONTROL_REMOTO.md` actualizada con sección dedicada.
**Documentado en:** `doc/guias/GUIA_CONTROL_REMOTO.md` (sección "Terminal Chamber").

---

### Fase 3 — Monitoreo centralizado ✅ COMPLETADO

Chamber emite eventos SSE (`GET /api/openchamber/events`) para:
- Scheduled task runs
- Túnel activo/inactivo
- Estado de sesiones

**Logro:** SSE verificado (eventos en tiempo real). `worker-log.md` deprecado.
`VAIO-SCHEDULED.md` actualizada con sección de monitoreo SSE.

---

### Fase 4 — MCP en Chamber ⏳ PENDIENTE (sin source)

**Qué es:** Model Context Protocol — permite conectar servidores externos que enriquecen el contexto del agente.

**Qué tenemos:** `codebase-memory-mcp` corriendo localmente en `localhost:9749` (grafo de código 3D).

**Qué ofrece Chamber:** UI completa para gestión de MCP servers:
- Local (comando local)
- Remote (URL)
- OAuth
- Scope personal/project

**Estado:** Pendiente. Depende de tener acceso al source de Chamber en la máquina donde corre `codebase-memory-mcp`.

---

### Fase 5 — Skills de Diligencia publicadas ✅ COMPLETADO

**Qué tenemos:** Skills en `~/.config/opencode/skills/` (tdd-strict, pr-review, sdd-workflow, etc.)

**Qué ofrece Chamber:** Skills Catalog con UI de publicación, búsqueda, instalación.

**Logro:** 3 skills publicadas en el Skills Catalog de Chamber vía `POST /api/config/skills/`.

---

### Fase 6 — Upgrade Chamber v1.13.2 → v1.16.3 🔴 PENDIENTE

| Feature en v1.16.3 | Impacto |
|---|---|
| Scheduled Tasks: permission auto-accept | Nuestras tasks ya no piden confirmación |
| Desktop: remote instance sin OpenCode local | La VAIO puede ser puro servidor OpenCode |
| SSH Windows nativo (sin connection sharing) | Remote instances más robustas |
| Performance sessions | Sesiones más rápidas para check-tareas |

**Riesgo:** Upgrade requiere rebuild y reinstalación. Hay que planificar ventana de mantenimiento.

---

## Roadmap — estado post OLA-CHAMBER-100 Sesión 1

| ID | Item | Prioridad | Fase | Estado |
|---|---|---|---|---|
| R72 | Tunnel nativo de Chamber | P2 | F1 | ✅ Quick mode activado |
| R73 | Terminal Chamber | P2 | F2 | ✅ API probada |
| R74 | Monitoreo centralizado vía SSE | P3 | F3 | ✅ SSE verificado |
| R75 | Hostear codebase-memory-mcp en Chamber | P2 | F4 | ⏳ Pendiente (sin source) |
| R76 | Skills de Diligencia en Chamber Catalog | P3 | F5 | ✅ 3 skills publicadas |
| R77 | Upgrade Chamber v1.13.2 → v1.16.3 | P2 | F6 | 🔴 Pendiente |

---

## Archivos relacionados

- `doc/vaio/VAIO-SCHEDULED.md` — sistema actual (actualizado OLA-CHAMBER-100)
- `doc/guias/GUIA_CONTROL_REMOTO.md` — acceso remoto (actualizado)
- `doc/vaio/startup-tunnel.ps1` — ⚠️ DEPRECADO
- `doc/vaio/worker-loop.md` — ⚠️ DEPRECADO
- `doc/vaio/worker-log.md` — ⚠️ DEPRECADO
- `doc/olas/OLA-CHAMBER-100.md` — plan de migración
- `ROADMAP.md` — items R72-R77 actualizados
