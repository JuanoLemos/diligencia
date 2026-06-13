# MECANICA-FLUJO — Circuito completo de CBP v1.0

Flujo detallado de cada sub-workflow de `/CBP`, reglas que aplican, dependencias y gaps conocidos.
Complementa a `MECANICA-CBP.md` (modelo Meta-PLAN/BUILD).

---

## §1 — Diagrama del circuito completo

```
                            ┌──────────────────────────────────────┐
                            │   PRE-FLIGHT (paso 0, siempre)        │
                            │   a: ver versión proyecto             │
                            │   b: ver versión global               │
                            │   c: si no hay DILIGENCIA → /adaptar  │
                            │   d: si proyecto < global → /adaptar  │
                            │   e: si match → ok                    │
                            │   f: leer PENDING.md                  │
                            └──────────┬───────────────────────────┘
                                       │
                         ┌─────────────┴─────────────┐
                         │            │               │
                    sin argumento    argumento      PENDING
                    (detección)     explícito      detectado → offer bump
                         │               │               │
                 ┌───────┴───────┐       │               │
                 │               │       │               │
            solo código    1-5 docs     │               │
            → commit path  → parcial    │               │
                 │               │       │               │
                 ▼               ▼       ▼               │
           ┌─────────┐  ┌──────────┐  ┌──────────────┐  │
           │ commit  │  │ parcial  │  │ full/completo │  │
           │(sin META)│  │(META     │  │ (META OLA    │  │
           │invoca   │  │ ligero)  │  │  1-4 + 4 wks)│  │
           │/commit  │  │+ pre-flt │  │ + agentes    │  │
           └────┬────┘  └────┬─────┘  └──────┬───────┘  │
                │            │                │          │
                ▼            ▼                ▼          ▼
           ┌────────────────────────────────────────────────┐
           │    SUB-COMANDOS INVOCADOS EN BUILD              │
           │                                                 │
           │  /updoc   (Fases A→H)                           │
           │  /doctor  (Fases 1→3)                           │
           │  /version (Steps 1→12)                          │
           │  /salud   (BUILD* → status-salud.md)            │
           │  /pushgh  (push a $REPO)                        │
           │  /commit  (validación Conventional Commits)     │
           │  task("explore") (4 workers en full)            │
           └────────────────────────────────────────────────┘

         POST-WORKFLOW:
         updoc   → sugiere /CBP doctor (si correcciones)
         version → sugiere /CBP doctor (diagnóstico post)
         full    → sugiere /CBP doctor (si correcciones)
         commit  → sugiere git push manual (si $REPO no definido)
         parcial → no sugiere nada
         doctor  → terminado (loop corregido en v1.17.5)
```

---

## §2 — Ficha de cada sub-workflow

### `updoc` — Post-sesión completo

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP updoc` (argumento explícito) |
| **Meta-PLAN** | OLA 1: 19 fases paralelas via `task`. OLA 2: stale + huérfanas + scope. OLA 3: gaps→plan + confirmación. OLA 4: tabla consolidada + pregunta |
| **BUILD** | /updoc Fase F + /salud BUILD* + /version BUILD* Steps 6→12 + /pushgh BUILD* + /doctor Fase 3 (si hay issues) |
| **Reglas** | #1, #2, #3, #4, #5, #6, #7, #9-#12, #17, #18, #19 |
| **Post** | WT limpio. CHANGELOG, INDEX, DILIGENCIA actualizados. status-salud generado. Sugiere /CBP doctor si correcciones |
| **Llama a** | /updoc, /doctor, /salud, /version, /pushgh |

### `doctor` — Diagnóstico y corrección

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP doctor` (argumento). También delegado desde updoc/version/full |
| **Meta-PLAN** | LEER doctor.md, version.md, salud.md. /doctor Fases 1→2 (diagnóstico). Tabla división única. Preguntar |
| **BUILD** | /doctor Fase 3 (correcciones) + /salud BUILD* + /version patch BUILD* Steps 6→12 (si correcciones) + /pushgh BUILD* |
| **Reglas** | #1, #2, #3, #4, #5, #6, #7, #17, #18, #19 |
| **Post** | WT limpio si hubo correcciones. Sugiere /CBP updoc o /CBP version |
| **Llama a** | /doctor, /salud, /version, /pushgh |

### `version` — Versionado standalone

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP version` (argumento explícito) |
| **Meta-PLAN** | LEER version.md. /version Steps 1→5 (detectar, colectar, clasificar, CHANGELOG auto, pre-flight). Safe-path: ¿updoc primero? |
| **BUILD** | /version Steps 6→12 (insertar CHANGELOG, commit + tag, push) |
| **Reglas** | #1, #4, #5, #6, #7, #17, #18, #19 |
| **Post** | WT limpio. CHANGELOG, INDEX, DILIGENCIA actualizados. Tag creado. Sugiere /CBP doctor |
| **Llama a** | /version, /pushgh |

### `commit` — Commit rápido

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP commit` (argumento) o dispatch automático (solo código, 0 docs) |
| **Meta-PLAN** | No tiene. Ejecución directa |
| **BUILD** | Invoca `/commit` (validación Conventional Commits + diff). Push directo `git push origin <branch>` |
| **Reglas** | #6, #17, #18, #19 |
| **Post** | WT limpio. Sin CHANGELOG ni INDEX actualizados |
| **Llama a** | /commit, git push directo |

### `parcial` — Sync documental ligero

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP parcial` (argumento) o dispatch automático (1-5 docs tocados) |
| **Meta-PLAN** | Ligero: /updoc Fases A→E+H (solo auditoría) + /version Steps 1→5 (pre-flight) + tabla + una confirmación |
| **BUILD** | /updoc Fase F (correcciones) + /version BUILD* Steps 6→12 + /pushgh BUILD* |
| **Reglas** | #1, #3 (con META ligero, ahora válido), #4, #5, #6, #7, #17, #18, #19 |
| **Post** | WT limpio. CHANGELOG actualizado (patch). Sin /salud, sin /doctor |
| **Llama a** | /updoc, /version, /pushgh |

### `full` / `completo` — Ciclo completo con meta-orquestador

| Dimensión | Descripción |
|---|---|
| **Entry** | `/CBP full` (argumento) o dispatch automático (5+ docs, milestones) |
| **Meta-PLAN** | OLA 1: 4 workers via `task` (docs, diag, ver, agt). OLA 2: sintetizar. OLA 3: consolidar. OLA 4: tabla + pregunta |
| **BUILD** | Agentes (si aceptados) + /updoc Fase F + /salud BUILD* + /version BUILD* Steps 6→12 + /pushgh BUILD* + /doctor Fase 3 |
| **Reglas** | **Todas las 19 reglas** |
| **Post** | WT limpio. Todos los documentos sincronizados. Agentes ejecutados si fueron aceptados. Sugiere /CBP doctor si correcciones |
| **Llama a** | task explore (4 workers), /updoc, /salud, /version, /pushgh, /doctor |

---

## §3 — Dependencias inter-workflow

```
PRE-FLIGHT (paso 0) ──┬── CBP commit → /commit → git push
                      ├── CBP parcial → /updoc → /version → /pushgh
                      ├── CBP updoc   → /updoc + /doctor + /salud + /version + /pushgh
                      ├── CBP doctor  → /doctor + /salud + /version + /pushgh
                      ├── CBP version → /version + /pushgh
                      └── CBP full    → task workers + /updoc + /salud + /version + /pushgh + /doctor

DELEGACIONES:
  /CBP version (safe-path) → pregunta ¿/CBP updoc primero? → si sí: aborta y ejecuta updoc
  /CBP updoc (step 3)     → sugiere /CBP doctor (si quedaron correcciones sin aplicar)
  /CBP version (step 3)   → sugiere /CBP doctor (diagnóstico post-versionado)
  /CBP full (step 3)      → sugiere /CBP doctor (si correcciones sin aplicar)
```

---

## §4 — Reglas del orquestador por workflow

| # | Regla | updoc | doctor | version | commit | parcial | full |
|---|---|---|---|---|---|---|---|
| 1 | Cada paso lee su .md | ✅ | ✅ | ✅ | ❌ (usa `/commit`) | ✅ | ✅ |
| 2 | BUILD* solo escritura | ✅ | ✅ | n/a | n/a | ✅ | ✅ |
| 3 | BUILD* requiere Meta-PLAN | ✅ | ✅ | n/a | n/a | ✅ | ✅ |
| 4 | Tabla con divisiones | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| 5 | `--yes` omite confirmación | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| 6 | Fail → DETENER | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 7 | PLAN razonam./BUILD ejec. | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| 8 | Agentes opcionales | n/a | n/a | n/a | ❌ | ❌ | ✅ |
| 9-12 | Olas paralelas | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 13-14 | Detección adaptativa | n/a | n/a | n/a | n/a | n/a | n/a |
| 15 | Pre-flight Diligencia | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 16 | Bump al editar globales | n/a | n/a | n/a | n/a | n/a | n/a |
| 17 | Solo 3 comandos commit | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 18 | Ambigüedad → pausar | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 19 | Proyecto ajeno → confirm | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

✅ = aplica | ❌ = no aplica | n/a = fuera de scope del workflow

---

## §5 — Gaps conocidos

### Resueltos (v1.17.5)

| ID | Gap | Fix |
|---|---|---|
| G12 | commit duplicaba `git add -A` + `git commit` inline | Ahora invoca `/commit` |
| G13 | `/pushgh BUILD*` sin Meta-PLAN | Push directo `git push origin <branch>` |
| G16 | `parcial` ejecutaba /version BUILD* sin Meta-PLAN | Meta-PLAN ligero agregado |
| G18 | Sin confirmación entre PLAN y BUILD en parcial | Confirmación única agregada |
| G10 | Doble confirmación en version | Meta-PLAN muestra CHANGELOG y pregunta una vez |
| G11 | Steps 6→8 no cubría pasos reales del command 6→12 | Todas las referencias corregidas |
| G9 | Handoff version→updoc no especificado | ABORT → updoc → reanudar version |
| G7 | Bucle autoreferencial /CBP doctor | Terminado correctamente |
| G14 | Sin sugerencia de push manual | Mensaje con comando explícito |

### Pendientes

| ID | Gap | Prioridad | Estado |
|---|---|---|---|
| G1 | "20 fases" en OLA 1 de updoc pero son 19 | Bajo | ⏳ Pendiente |
| G2 | Nomenclatura V1-V4 inventada vs version.md | Medio | ⏳ Pendiente |
| G4 | /CBP AGT en updoc nunca se usa | Medio | ⏳ Pendiente |
| G19 | Workers full usan `task("explore")` no probado | Medio | ⏳ Pendiente |
| G21 | `full` vs `completo` inconsistencia nominal | Bajo | ⏳ Pendiente |
| G5 | MECANICA-CBP.md sin /version ni /CBP AGT | Bajo | ⏳ Pendiente |
| G15 | META-ESCALABILIDAD.md usa `git status --porcelain` vs `git diff HEAD` | Bajo | ⏳ Pendiente |
| G20 | W4 necesita tag de release que W3 obtiene (son paralelos) | Bajo | ⏳ Pendiente |

---

## Archivos relacionados
- `MECANICA-CBP.md` — modelo Meta-PLAN/BUILD y estados del circuito
- `CBP.md` — especificación completa del orquestador
- `META-ESCALABILIDAD.md` — detección de camino adaptativa
- `guia/docs/GUIA_DE_BUENAS_PRACTICAS.md` §9 — hábitos de usuario
