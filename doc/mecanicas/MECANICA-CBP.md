# MECANICA-CBP — Circuito de trabajo cíclico v1.16.3

Define los workflows multi-comando del ecosistema. El orquestador `/CBP` ejecuta los encadenamientos; los comandos individuales ya no contienen "Próximo paso" propio.
Referencia de hábitos de usuario: `GUIA_DE_BUENAS_PRACTICAS.md §9`.

---

## Meta-PLAN y modelo de separación razonamiento/ejecuci�n

Cada workflow se divide en dos fases:

| Fase | Modelo | Acción |
|---|---|---|
| **Meta-PLAN** | modelo de razonamiento | Ejecuta PLAN de todos los comandos (lectura + auditoría). NO modifica archivos. Muestra tabla consolidada con divisiones por comando. Pide UNA SOLA confirmación. |
| **BUILD** | modelo de ejecuci�n | Ejecuta BUILD de todos los comandos (escritura). BUILD* omite PLAN porque los datos se heredan del Meta-PLAN. |

El Meta-PLAN corre siempre en razonamiento sin importar el modo de invocación. BUILD corre siempre en ejecuci�n.

## Diagrama del circuito

```
SESSIONWORK
    │
    ├── /CBP updoc ────────────────────────────────────┐
    │                                                       │
    ▼                                                       │
META-PLAN (razonamiento)                                             │
    │                                                       │
    ├── /updoc Fases A→E+H (PLAN)                          │
    ├── /doctor Fases 1→2 (PLAN)                            │
    ├── /salud preview (datos heredados)                    │
    ├── Calcular bump type                                  │
    └── "¿Ejecutar BUILD?" (UNA confirmación)               │
    │                                                       │
    ▼ (ejecuci�n)                                               │
BUILD                                                       │
    │                                                       │
    ├── /updoc Fase F                                       │
    ├── /salud BUILD* (status-salud.md)                     │
    ├── /version BUILD* (CHANGELOG, INDEX, template, commit)│
    ├── /pushgh BUILD* (git push)                           │
    └── /doctor Fase 3 (si correcciones)                    │
    │                                                       │
    └── SESSIONWORK                                         │
                                                           │
┌────────────────────────────────────────────────────────────┘
│
├── /CBP doctor ───────────────────────────────────────┐
│   META-PLAN (razonamiento) → BUILD (ejecuci�n)                         │
│   /doctor Fases 1→2 → /salud BUILD* → /version patch*     │
│   → /pushgh BUILD* (si correcciones)                      │
│                                                           │
├── /CBP version ──────────────────────────────────────┤
│   META-PLAN (razonamiento) → BUILD (ejecuci�n)                         │
│   /version Steps 1→5 → Steps 6→8 → /pushgh BUILD*         │
│   → sugiere /doctor                                        │
│                                                           │
├── /CBP commit (sin despacho) ────────────────────────┘
│   git add -A → commit → /pushgh
│   Sin Meta-PLAN, sin doc sync, sin versión.
│
├── /CBP parcial (sin despacho) ──────────────────────┘
│   /updoc Fases A→F → /version patch* → /pushgh*
│   Sin Meta-PLAN profundo, sin /salud, sin /doctor.
│
└── /CBP completo ─────────────────────────────────────┘
    META-PLAN (razonamiento) → BUILD (ejecuci�n)
    Agentes/skills sugeridos → /updoc → /salud* → /version* → /pushgh* → /doctor
```

## Estados y transiciones

| N° | Estado | Entry | Acción | Exit | Próximo paso (via /CBP) |
|---|---|---|---|---|---|
| 1 | SESSIONWORK | Circuito inicia o reinicia | Usuario edita, agrega RM items, modifica código | Working tree dirty | `/CBP updoc` |
| 2 | META-PLAN | `/CBP` invocado | Fase razonamiento: PLAN de todos los comandos del workflow, tabla consolidada, UNA confirmación | Confirmación aceptada | BUILD (ejecuci�n) |
| 3 | BUILD | META-PLAN confirmado | Fase ejecuci�n: BUILD de todos los comandos (escritura) | BUILD completo | SESSIONWORK o sugiere siguiente paso |
| 4 | `/updoc` PLAN (en META-PLAN) | SESSIONWORK completo | Fases A→E+H: audita INDEX, stale, gaps, cross-ref | Plan auditado | Continúa META-PLAN con /doctor PLAN |
| 5 | `/doctor` PLAN (en META-PLAN) | `/updoc` PLAN completado | Fases 1→2: diagnóstico estructura, código, tracking, limpieza, deprecación | Diagnóstico completo | Continúa META-PLAN con /salud preview |
| 6 | `/salud` BUILD* | META-PLAN confirmado | Genera `doc/arch/status-salud.md`, actualiza INDEX | Reporte generado | `/version BUILD*` |
| 7 | `/version` (minor/patch) BUILD* | META-PLAN confirmado | Steps 6→8: CHANGELOG, INDEX, template, commit → /pushgh | BUILD + commit clean | pushgh BUILD* o SESSIONWORK |
| 8 | `/pushgh` BUILD* | /version BUILD* completado | git push al remoto $REPO | Push completado | /doctor Fase 3 o SESSIONWORK |
| 9 | `/doctor` BUILD | META-PLAN confirmado | Fase 3: aplicar correcciones (si hay) | Correcciones aplicadas | `/version patch BUILD*` + `/pushgh*` si correcciones, SESSIONWORK si no |

## Workflows del orquestador

Los encadenamientos se definen en `~/.config/opencode/commands/CBP.md`:

| Workflow | Secuencia |
|---|---|---|
| `updoc` | META-PLAN (razonamiento): /updoc PLAN + /doctor PLAN + /salud preview → BUILD (ejecuci�n): /updoc Fase F + /salud* + /version* + /pushgh* + /doctor BUILD |
| `doctor` | META-PLAN (razonamiento): /doctor PLAN → BUILD (ejecuci�n): /doctor Fase 3 + /salud* + /version patch* + /pushgh* (si correcciones) |
| `version` | META-PLAN (razonamiento): /version Steps 1→5 → BUILD (ejecuci�n): /version Steps 6→8 → /pushgh* → sugiere /doctor |
| `commit` | EJECUCI�N DIRECTA (sin Meta-PLAN): git add -A → commit → /pushgh |
| `parcial` | EJECUCI�N SECUENCIAL (sin Meta-PLAN): /updoc A→F → /version patch* → /pushgh* |
| `completo` / `full` | META-PLAN (razonamiento): **4 workers paralelos** (W1 docs + W2 diag + W3 ver + W4 agt) → sintetizar OLA 2-3 → tabla consolidada OLA 4 → BUILD (ejecuci�n): agentes + /updoc Fase F + /salud* + /version* + /pushgh* + /doctor |

Ver `CBP.md` para la especificación completa de cada workflow.

## Contrato Meta-PLAN → BUILD

Cada workflow del circuito cumple:

1. **Meta-PLAN (razonamiento)**: leer, auditar, diagnosticar, calcular para TODOS los comandos del workflow. NO modificar archivos.
2. **Mostrar plan al usuario**: tabla consolidada con divisiones por comando (updoc, version, salud, doctor), hallazgos, cambios propuestos, impacto.
3. **Usuario confirma una sola vez** (sí).
4. **BUILD (ejecuci�n)**: aplicar cambios de todos los comandos. Modificar archivos solo aquí.
5. **BUILD\***: pasos que omiten PLAN porque los datos ya fueron auditados en el Meta-PLAN.
6. **Output**: resumen de lo aplicado por cada comando.

## Agentes y skills en el circuito

Solo aplica al workflow `completo`. El Meta-PLAN analiza el working tree y sugiere:

| Condición | Agente/Skill sugerido | Orden en BUILD |
|---|---|---|
| git diff >20 líneas de código | `@sdd-reviewer` | 1ero (revisar antes de versionar) |
| Cambios de arquitectura detectados | `@sdd-architect` | 1ero (explorar antes de aplicar) |
| Tests en el proyecto | `skill("tdd-strict")` + `@sdd-verify` | 2do (verificar después de revisar) |
| ROADMAP.md con SDD items | `skill("sdd-workflow")` | — (cargar en contexto, no ejecuta) |

Los agentes se ejecutan en BUILD antes de los comandos documentales. El usuario puede rechazar cada agente individualmente sin abortar el workflow.

## Vinculante

- El encadenamiento vinculante lo controla `/CBP`, no los comandos individuales.
- El orquestador DEBE ejecutar Meta-PLAN primero, luego BUILD.
- El usuario puede rechazar el Meta-PLAN (rompiendo el circuito), pero el orquestador no puede saltar Meta-PLAN.
- Los agentes/skills sugeridos son opcionales — el usuario decide si incluirlos.
- Los comandos individuales ejecutados standalone NO tienen encadenamiento — solo ejecutan su propio PLAN→BUILD.

## Variantes del ciclo

| Escenario | Comando |
|---|---|
| Post-sesión con cambios documentales | `/CBP updoc` |
| Diagnóstico post-versionado | `/CBP doctor` |
| Versionado rápido sin /updoc | `/CBP version` |
| Ciclo completo con agentes + documentación | `/CBP completo` |
| Pushear después de versionar | `/pushgh` (invocado automáticamente por /CBP) |
| Sin cambios en working tree | No inicia circuito — salta a sessionwork o fin |

## Archivos que referencian esta mecánica

- `~/.config/opencode/commands/CBP.md` — orquestador (SSOT de encadenamiento)
- `~/.config/opencode/commands/updoc.md`
- `~/.config/opencode/commands/version.md`
- `~/.config/opencode/commands/doctor.md`
- `~/.config/opencode/commands/salud.md`
- `~/.config/opencode/commands/pushgh.md`
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — diagrama de referencia

## Archivos relacionados
- `doc/mecanicas/MECANICA-DOCUMENTAL.md` — mecánica documental general
- `doc/mecanicas/MECANICA-FLUJO.md` — documentación del circuito
