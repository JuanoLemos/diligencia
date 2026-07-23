# MECANICA-CHAMBER-FIRST — Migración a funcionalidades nativas de Chamber v1.0

> Plan estratégico. Chamber ya tiene muchas de las herramientas que construimos manualmente.
> El objetivo es migrar hacia lo nativo de Chamber donde tenga sentido, sin romper lo que funciona.

---

## Principio

> Si Chamber ya lo tiene, lo usamos. Si no lo tiene, lo construimos sin salir de Chamber.

---

## Auditoría: lo nuestro vs lo de Chamber

| Sistema nuestro | Chamber ofrece | Decisión |
|---|---|---|
| `startup-tunnel.ps1` + `cloudflared-url.md` | **Tunnel System**: Cloudflare quick/managed-remote/managed-local, Ngrok, API status | **Migrar** |
| `worker-loop.md` (deprecado) | **Scheduled Tasks**: cron/daily/weekly, concurrencia 4/2, SSE events, persistencia | ✅ Ya migrado |
| `watchdog cloudflared` (cada 5 min) | **Scheduled Task** `cloudflared-watchdog` ya configurada | ✅ Ya migrado |
| `GUIA_CONTROL_REMOTO.md` (VS Code Remote) | **SSH Remote Instances**: desktop SSH manager, managed/external | **Evaluar** |
| vscode.dev para terminal | **Terminal integrado**: WebSocket WS protocol, en misma UI que el chat | **Migrar** |
| `worker-log.md` manual | **SSE events** + Scheduled Tasks status API | **Migrar** |
| `codebase-memory-mcp` localhost | **MCP Servers**: UI completa, local/remote, scopes, OAuth | **Migrar** |
| Skills locales en `~/.config/opencode/skills/` | **Skills Catalog** en Chamber (UI + publish) | **Migrar** |
| `doc/vaio/tasks/` + `doc/vaio/results/` (git bridge) | **Scheduled Tasks** ejecutan prompts directamente | **Mantener** (universal) |
| `AGENTS.md` + R14/R15 | Gobierno de Diligencia, no de Chamber | **Mantener** |

---

## Fases

---

### Fase 1 — Túneles nativos de Chamber (siguiente)

| Tarea | Estado |
|---|---|
| Reemplazar `startup-tunnel.ps1` por tunnel nativo de Chamber | ⏳ Pendiente |
| Usar `managed-remote` para URL persistente (no trycloudflare efímera) | ⏳ Pendiente |
| Deprecar `cloudflared-url.md` — Chamber expone la URL via API | ⏳ Pendiente |

**Beneficio:** URL permanente, diagnóstico integrado, sin scripts externos.

**Detalle:** Chamber tiene un `POST /api/openchamber/tunnel/start` que acepta `provider: "cloudflare"` y `mode: "managed-remote"`. Usa un hostname persistente en vez de URL efímera.

---

### Fase 2 — Terminal integrado (en vez de vscode.dev)

Chamber tiene un terminal WebSocket (`packages/web/server/TERMINAL_WS_PROTOCOL.md`) que permite:
- Ejecutar comandos en el servidor desde la UI de Chamber
- Sin necesidad de abrir vscode.dev
- El terminal está al lado del chat en la misma interfaz

**Beneficio:** Un solo lugar para todo. No más alternar entre vscode.dev y Chamber.

**Bloqueante:** El terminal de Chamber está en desarrollo. En la versión actual (v1.13.2) debería funcionar. Hay que probarlo desde la UI de Chamber.

**Acción:**
- En la UI de Chamber, abrir el terminal (icono `>_` en la barra inferior)
- Probar comandos básicos: `cd C:\xampp\htdocs\Diligencia`, `git status`
- Si funciona, documentar como reemplazo de vscode.dev

---

### Fase 3 — Monitoreo centralizado (SSE + Tray)

Chamber emite eventos SSE (`/api/openchamber/events`) para:
- Scheduled task runs
- Túnel activo/inactivo
- Estado de sesiones

El Tray App de Chamber (Windows) ya tiene:
- Health balloon cada 60s
- Submenú System (memoria, uptime, versión)
- Auto-update check cada 6h

**Acción:**
- Configurar Tray para mostrar estado de las scheduled tasks
- Monitorear eventos SSE desde la PC Principal (vía curl o script)
- Migrar `worker-log.md` a consulta de API: `GET /api/openchamber/scheduled-tasks/status`

---

### Fase 4 — MCP en Chamber

**Qué es:** Model Context Protocol — permite conectar servidores externos que enriquecen el contexto del agente.

**Qué tenemos:** `codebase-memory-mcp` corriendo localmente en `localhost:9749` (grafo de código 3D).

**Qué ofrece Chamber:** UI completa para gestión de MCP servers:
- Local (comando local)
- Remote (URL)
- OAuth
- Scope personal/project

**Acción:**
- Hostear `codebase-memory-mcp` en Chamber como servidor MCP local
- Configurar scope: solo para el proyecto Diligencia
- Acceder al grafo 3D desde cualquier lado (no solo localhost)

---

### Fase 5 — Skills de Diligencia publicadas

**Qué tenemos:** Skills en `~/.config/opencode/skills/` (tdd-strict, pr-review, sdd-workflow, etc.)

**Qué ofrece Chamber:** Skills Catalog con UI de publicación, búsqueda, instalación.

**Acción:**
- Publicar skills relevantes de Diligencia en el Skills Catalog de Chamber
- Hacerlas instalables desde la UI de Chamber
- Mantener las skills locales como fallback offline

---

### Fase 6 — Upgrade Chamber v1.13.2 → v1.16.3

| Feature en v1.16.3 | Impacto |
|---|---|
| Scheduled Tasks: permission auto-accept | Nuestras tasks ya no piden confirmación |
| Desktop: remote instance sin OpenCode local | La VAIO puede ser puro servidor OpenCode |
| SSH Windows nativo (sin connection sharing) | Remote instances más robustas |
| Performance sessions | Sesiones más rápidas para check-tareas |

**Riesgo:** Upgrade requiere rebuild y reinstalación. Hay que planificar ventana de mantenimiento.

---

## Roadmap (nuevos items en ROADMAP.md)

| ID | Item | Prioridad | Fase |
|---|---|---|---|
| R72 | Tunnel nativo de Chamber (reemplazar startup-tunnel.ps1) | P2 | F1 |
| R73 | Terminal Chamber como reemplazo de vscode.dev | P2 | F2 |
| R74 | Monitoreo centralizado vía SSE + Tray | P3 | F3 |
| R75 | Hostear codebase-memory-mcp en Chamber | P2 | F4 |
| R76 | Publicar skills de Diligencia en Chamber Catalog | P3 | F5 |
| R77 | Upgrade Chamber v1.13.2 → v1.16.3 | P2 | F6 |

---

## Archivos relacionados

- `doc/vaio/VAIO-SCHEDULED.md` — sistema actual (ya migrado a Chamber)
- `doc/guias/GUIA_CONTROL_REMOTO.md` — acceso remoto (a actualizar)
- `doc/vaio/startup-tunnel.ps1` — ⚠️ para deprecar en Fase 1
- `doc/vaio/worker-loop.md` — ⚠️ deprecado
- `ROADMAP.md` — items R72-R77
- `CHANGELOG.md` — seguimiento de migración
