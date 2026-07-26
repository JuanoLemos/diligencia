# Diligencia Ola Chamber-100 — Migración a funcionalidades nativas de Chamber

> Plan v2.0 (refinado) | Ejecutado: 2026-07-26 | Sesión 1: PC Principal
> Objetivo: Reemplazar soluciones manuales por funcionalidades nativas de Chamber en AMBAS máquinas.

---

## Arquitectura objetivo

```
Antes:                              Después:
┌──────────────────────┐            ┌──────────────────────────┐
│ startup-tunnel.ps1   │     ──→   │ Chamber Tunnel API        │
│ vscode.dev + manual  │     ──→   │ Terminal WS integrado     │
│ worker-log.md        │     ──→   │ SSE events + status API   │
│ codebase-mcp local   │     ──→   │ MCP server en Chamber     │
│ Skills locales .md   │     ──→   │ Skills vía catalog        │
│ Chamber v1.13.2      │     ──→   │ Chamber v1.16.3           │
│ runtime.js no-editable│    ──→   │ Source code editable       │
└──────────────────────┘            └──────────────────────────┘
```

### Estado actual por máquina

| Componente | PC Principal | VAIO |
|---|---|---|
| Chamber source | ✅ `C:\Users\jlemo\OneDrive\Desktop\openchamber\` | ⚠️ Clonado en `C:\Users\jlemo\openchamber\` (Bun roto sin AVX2) |
| runtime.js | ✅ Editable (source) | ❌ No editable (empaquetado ASAR) |
| Node.js | ✅ Instalado | ❌ Pendiente de instalar |
| Scheduled tasks | ✅ 3 tasks activas | ✅ 3 tasks activas |
| Fix 2 archivos | ❌ Aplicado en ASAR | ❌ Pendiente de aplicar |
| Chamber corriendo | ✅ App instalada | ✅ App instalada (pero ASAR) |
| Chamber desde source | ❌ No probado | ❌ Pendiente (Node.js) |

---

## Tabla maestra — qué va en cada máquina

| Sub-ola | PC Principal | VAIO |
|---|---|---|
| **S1** Sesión 1 (esta) | ✅ Tunnel quick mode, SSE, Terminal, Skills, Docs | — |
| **A0** Fix 2 archivos | ✅ Aplicar en source repo | ✅ Aplicar después de Node.js |
| **A1** Node.js + npm | ❌ Ya tiene | ✅ Instalar Node.js, `npm install` |
| **A2** Chamber desde source | ⬜ Evaluar si conviene | ✅ `node bin/cli.js serve --port 57123` |
| **B1** Tunnel nativo | ❌ No necesita | ✅ Reemplazar startup-tunnel.ps1 |
| **B2** Terminal WS | ✅ Usar para conectar a VAIO | ✅ Hostear servicio WS |
| **B3** MCP | ⏳ Probar aquí primero | ⏳ Desplegar después |
| **B4** Skills | ✅ Publicado desde acá | ❌ No publica |
| **B5** Monitoreo | ✅ Consumir SSE desde acá | ✅ Emitir SSE + status API |
| **B6** Upgrade v1.16.3 | ⏳ Probar aquí primero | ⏳ Aplicar después |

---

## Sesión 1 — PC Principal (COMPLETADO ✅)

> Ejecutada el 2026-07-26. Resultados:

| Bloque | Resultado |
|---|---|
| Verificar estado | ✅ Chamber responde, 3 tasks activas |
| Ajustar publish-url | ✅ Usa `GET /api/openchamber/tunnel/status` |
| Activar tunnel quick mode | ✅ Tunnel activo vía API |
| Deprecar archivos | ✅ `startup-tunnel.ps1`, `worker-log.md`, watchdog desactivado |
| Probar SSE | ✅ Eventos recibidos |
| Probar Terminal API | ✅ Sesión creada |
| Publicar skills (3) | ✅ tdd-strict, pr-review, sdd-workflow |
| Actualizar documentación | ✅ 6 archivos actualizados |
| Commit | ✅ `feat(ola): OLA-CHAMBER-100 Sesion 1` |

---

## Sesiones pendientes

### Sesión 2 — VAIO: Recuperación + Estabilización

> Ejecutar físicamente frente a la VAIO.

| Tarea | Depende de | Esfuerzo |
|---|---|---|
| A1 — Instalar Node.js 22 LTS | — | 2 min |
| A2 — `npm install` en openchamber | A1 | 5 min |
| A3 — Aplicar fix de sessionId (2 archivos) | A2 | 3 min |
| A4 — Iniciar Chamber desde source con Node.js | A3 | 2 min |
| A5 — Verificar scheduled tasks | A4 | 2 min |

### Sesión 3 — VAIO: Migración Chamber-first

| Tarea | Depende de | Esfuerzo |
|---|---|---|
| B1 — Tunnel nativo de Chamber | Sesión 2 | 3 min |
| B2 — Terminal Chamber (host) | Sesión 2 | 2 min |
| B5 — Monitoreo SSE | B1 | 2 min |
| B6 — Upgrade v1.16.3 | B1 | 10 min |

### Sesión 4 — MCP (opcional)

| Tarea | Depende de | Esfuerzo |
|---|---|---|
| B3 — Hostear codebase-memory-mcp en Chamber | Sesión 2 | 5 min |

---

## Dependencias visuales

```
Sesión 1: PC Principal (COMPLETADO)
│
Sesión 2: VAIO Recuperación
├─ A1 Node.js ─→ A2 npm install ─→ A3 fix 2 archivos ─→ A4 iniciar Chamber ─→ A5 verificar
│
Sesión 3: VAIO Migración
├─ B1 Tunnel ─→ B5 Monitoreo
├─ B2 Terminal
└─ B6 Upgrade (depende de B1)
│
Sesión 4: MCP (opcional)
└─ B3 MCP
```

---

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Node.js 22 no disponible para CPU de VAIO | Baja | Alto | Usar Winget o MSI manual |
| `npm install` falla por `better-sqlite3` | Media | Medio | `--ignore-scripts` + `npm rebuild` |
| Fix de 2 archivos se pierde con `git merge upstream` | Alta | Medio | Documentar diff. Reaplicar post-upgrade |
| v1.16.3 cambia schema de scheduled tasks | Media | Medio | Probar en PC Principal primero |
| CPU sin AVX2 impide Bun (YA CONFIRMADO) | 100% | Alto | Ya migrado a Node.js — superado |

---

## Pre-ejecución (próxima sesión)

- [ ] Estar físicamente frente a la VAIO
- [ ] Conexión a internet estable
- [ ] Repo Diligencia actualizado (`git pull`)
- [ ] Repo openchamber clonado en `C:\Users\jlemo\openchamber`

## Post-ejecución (próxima sesión)

- [ ] Chamber corriendo desde source via Node.js en VAIO
- [ ] 3 scheduled tasks activas
- [ ] Tunnel nativo funcionando
- [ ] Terminal WS probado (VAIO host)
- [ ] SSE monitoreo activo
- [ ] /CBP sugerido en Diligencia

---

## Archivos afectados (global)

| Archivo | Sesión | Acción |
|---|---|---|
| `doc/vaio/startup-tunnel.ps1` | 1, 3 | ✅ Deprecado |
| `doc/vaio/cloudflared-url.md` | 1, 3 | ✅ Actualizado (Fuente: Chamber API) |
| `doc/vaio/worker-log.md` | 1 | ✅ Deprecado |
| `doc/vaio/GUIA_RECUPERACION_VAIO.md` | 1, 2 | ✅ Actualizado |
| `doc/vaio/VAIO-SCHEDULED.md` | 1 | ✅ Actualizado |
| `doc/guias/GUIA_CONTROL_REMOTO.md` | 1 | ✅ Actualizado |
| `doc/mecanicas/MECANICA-CHAMBER-FIRST.md` | 1 | ✅ Actualizado |
| `ROADMAP.md` | 1 | ✅ R72-R76 completados |
| `doc/olas/OLA-CHAMBER-100.md` | 1 | ✅ Refinado v2.0 |

---

> Generado por `/ola planear`. Refinado en OLA-CHAMBER-100 Sesión 1.
> Próximo paso: Sesión 2 — Recuperación VAIO (frente a la máquina).
