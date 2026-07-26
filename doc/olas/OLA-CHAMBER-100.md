# Diligencia Ola Chamber-100 — Migración completa a funcionalidades nativas de Chamber v1.0

> Plan: 2026-07-25 | Máquinas: PC Principal + VAIO
> Objetivo: Reemplazar todas las soluciones manuales por features nativas de Chamber. Sync ambas máquinas.

---

## Estado actual vs objetivo

| Sistema manual (nuestro) | Reemplazo Chamber | PC Principal | VAIO | Prioridad |
|---|---|---|---|---|
| `startup-tunnel.ps1` + cloudflared manual | Chamber Tunnel API (managed-remote) | ⚠️ cloudflared manual corriendo | ❌ | P1 |
| `worker-log.md` + `git fetch` manual | Chamber SSE Events + status API | ❌ | ❌ | P1 |
| vscode.dev aparte | Chamber Terminal WS | ❌ | ❌ | P2 |
| VS Code tunnel `vaio-server` | Chamber Remote Instances (SSH) | ❌ | ❌ | P2 |
| MCP en opencode.json | MCP en Chamber (UI + API) | ✅ PC Principal | ❌ | P2 |
| Skills locales | Skills Catalog | ❌ | ❌ | P3 |
| Scheduled tasks sesiones duplicadas | sessionId reutilizable | ⚠️ ASAR patched, tasks pausadas | ❌ Sin Chamber | P0 |
| Chamber EXE (app.asar) | Chamber desde source (editable) | ⚠️ ASAR viejo, source con cambios sin commit | ❌ | P0 |

---

## Fase 0 — Fundación (ambas máquinas)

> Estabilizar antes de migrar. Sin esto, nada funciona.

### 0.1 — PC Principal: consolidar ASAR

| Acción | Detalle |
|---|---|
| Commit source | `project-config.js` (sessionId fix) + `bun.lock` |
| Rebuild | `bun run build` |
| Rempaquetar ASAR | `npx @electron/asar pack` |
| Verificar | EXE carga el nuevo ASAR con todos los fixes |

### 0.2 — PC Principal: reactivar tasks con sessionId

| Acción | Detalle |
|---|---|
| Fijar sessionId | `ses_06e8bc4ecffeGFhCWxckgZcaYW` en execution config |
| Reactivar check-tareas | `enabled: true` — verificar que no crea sesiones nuevas |
| Reactivar watchdog y publish-url | Solo después de confirmar check-tareas estable |

### 0.3 — VAIO: Ola A (recuperación)

| Acción | Detalle |
|---|---|
| Instalar Node.js 22 LTS | `winget install OpenJS.NodeJS.LTS` |
| Clonar Chamber v1.16.3 | `git clone https://github.com/openchamber/openchamber.git` |
| npm install | `npm install` (CPU sin AVX2) |
| Aplicar fix sessionId | 2 archivos: `runtime.js` + `project-config.js` |
| Iniciar | `node packages/web/bin/cli.js serve --port 57123` |
| Recrear scheduled tasks | 3 tasks via curl |
| Fijar sessionId | Igual proceso que 0.2 |

---

## Fase 1 — Reemplazar manual por nativo

> Migrar lo que construimos manualmente a lo que Chamber ya tiene.

### 1.1 — Tunnel nativo (R72)

**Reemplaza:** `startup-tunnel.ps1`, `cloudflared-url.md`, scheduled task cloudflared-watchdog

| Máquina | Acción |
|---|---|
| PC Principal | Activar tunnel vía `POST /api/openchamber/tunnel/start` con `mode: "managed-remote"`. URL persistente (no trycloudflare). Obtener URL vía `GET /api/openchamber/tunnel/status`. Deprecar `startup-tunnel.ps1`. |
| VAIO | Igual configuración. Chamber gestiona el túnel solo — no necesita watchdog. |

**Beneficio:** URL permanente (no rotación cada reinicio), diagnóstico integrado, sin scripts externos.

### 1.2 — Monitoreo SSE (R74)

**Reemplaza:** `worker-log.md`, `git fetch` manual

| Máquina | Acción |
|---|---|
| PC Principal | Suscribirse a `GET /api/openchamber/events` (SSE) para eventos de scheduled tasks. Status vía `GET /api/openchamber/scheduled-tasks/status`. Migrar `worker-log.md` a consulta de API. |
| VAIO | Emitir eventos SSE para que MAIN los consuma. |

**Beneficio:** Monitoreo en tiempo real, sin polling git.

### 1.3 — Terminal integrado (R73)

**Reemplaza:** vscode.dev para comandos en VAIO

| Máquina | Acción |
|---|---|
| PC Principal | Probar terminal WS: `POST /api/terminal/create` + WebSocket `/api/terminal/ws`. Evaluar si reemplaza vscode.dev. |
| VAIO | Hostear servicio WS. |

**Beneficio:** Terminal + chat en la misma UI de Chamber.

---

## Fase 2 — Extender capacidades

> Features nuevas que Chamber tiene y no usamos.

### 2.1 — Remote Instances (nuevo)

**Reemplaza:** VS Code tunnel `vaio-server`

| Máquina | Acción |
|---|---|
| PC Principal | Configurar VAIO como remote instance en Chamber. Acceso SSH nativo. |
| VAIO | Activar OpenSSH. Configurar como instancia remota. |

**Beneficio:** Conectar a VAIO desde Chamber directamente, sin abrir vscode.dev.

### 2.2 — MCP en VAIO (R75)

| Máquina | Acción |
|---|---|
| VAIO | `POST /api/config/mcp/codebase-memory` con path local al binario MCP (desde PC Principal). |

**Beneficio:** Grafo de código de VAIO visible desde MAIN vía Chamber.

### 2.3 — Skills públicas (R76)

| Máquina | Acción |
|---|---|
| PC Principal | `POST /api/config/skills/tdd-strict`, `POST /api/config/skills/pr-review`, `POST /api/config/skills/sdd-workflow` |

**Beneficio:** Skills instalables desde Chamber UI.

---

## Fase 3 — Mantenimiento

> Automatizar actualizaciones y monitoreo.

### 3.1 — Auto-update

| Máquina | Acción |
|---|---|
| Ambas | Configurar `git pull upstream/main` + rebuild automático. O usar `POST /api/openchamber/update-install`. |

### 3.2 — Tray optimization

| Máquina | Acción |
|---|---|
| Ambas | Configurar Tray App con monitoreo de scheduled tasks + tunnel status. |

---

## Dependencias

```
Fase 0
├─ 0.1 PC: ASAR consolidado ────────────────────────┐
├─ 0.2 PC: Tasks reactivadas ───────────────────────┤
└─ 0.3 VAIO: Node.js + Chamber source ──────────────┤
                                                      │
Fase 1                                                │
├─ 1.1 Tunnel nativo ← 0.1 + 0.3 ───────────────────┤
├─ 1.2 Monitoreo SSE ← 0.2 ─────────────────────────┤
└─ 1.3 Terminal WS ← 0.1 + 0.3 ─────────────────────┤
                                                      │
Fase 2                                                │
├─ 2.1 Remote Instances ← 0.3 ──────────────────────┤
├─ 2.2 MCP en VAIO ← 0.3 ───────────────────────────┤
└─ 2.3 Skills ← sin dependencias ────────────────────┤
                                                      │
Fase 3 ← todo lo anterior ───────────────────────────┘
```

---

## Archivos afectados

| Archivo | Dónde | Fase |
|---|---|---|
| `packages/web/server/lib/projects/project-config.js` | Chamber source | 0.1 |
| `packages/web/server/lib/scheduled-tasks/runtime.js` | Chamber source | 0.1 |
| `app.asar` | `@openchamberelectron\resources\` | 0.1 |
| `doc/vaio/startup-tunnel.ps1` | Diligencia VAIO | 1.1 (deprecar) |
| `doc/vaio/cloudflared-url.md` | Diligencia VAIO | 1.1 (deprecar) |
| `doc/vaio/worker-log.md` | Diligencia VAIO | 1.2 (deprecar) |
| `doc/vaio/VAIO-SCHEDULED.md` | Diligencia | 1.1-1.3 |
| `doc/guias/GUIA_CONTROL_REMOTO.md` | Diligencia | 1.3, 2.1 |
| `doc/mecanicas/MECANICA-CHAMBER-FIRST.md` | Diligencia | Seguimiento |

---

## Checklist pre-ejecución

- [ ] Fase 0.1 completada (ASAR consolidado en PC)
- [ ] Fase 0.2 completada (tasks estables sin sesiones duplicadas)
- [ ] Fase 0.3 completada (VAIO con Node.js + Chamber source)
- [ ] Post-0: ambas máquinas tienen el mismo parche de sessionId

## Checklist post-ejecución

- [ ] Todas las tasks reactivadas y estables
- [ ] Tunnel nativo funcionando (URL vía API, no archivo)
- [ ] Terminal WS probado
- [ ] Remote Instances configurado
- [ ] MCP en ambas máquinas
- [ ] Skills publicadas
- [ ] SSE monitoreo activo
- [ ] /CBP sugerido en Diligencia

---

> Generado por `/ola planear`. Fase 0.1 en ejecución.
