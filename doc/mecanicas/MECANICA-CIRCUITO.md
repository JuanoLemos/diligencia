# MECANICA-CIRCUITO — Circuito de trabajo cíclico v1.11.0

Define los workflows multi-comando del ecosistema. El orquestador `/circuito` ejecuta los encadenamientos; los comandos individuales ya no contienen "Próximo paso" propio.
Referencia de hábitos de usuario: `GUIA_DE_BUENAS_PRACTICAS.md §9`.

---

## Meta-PLAN y modelo de separación PRO/FLASH

Cada workflow se divide en dos fases:

| Fase | Modelo | Acción |
|---|---|---|
| **Meta-PLAN** | DeepSeek PRO | Ejecuta PLAN de todos los comandos (lectura + auditoría). NO modifica archivos. Muestra tabla consolidada con divisiones por comando. Pide UNA SOLA confirmación. |
| **BUILD** | DeepSeek FLASH | Ejecuta BUILD de todos los comandos (escritura). BUILD* omite PLAN porque los datos se heredan del Meta-PLAN. |

El Meta-PLAN corre siempre en PRO sin importar el modo de invocación. BUILD corre siempre en FLASH.

## Diagrama del circuito

```
SESSIONWORK
    │
    ├── /circuito updoc ────────────────────────────────────┐
    │                                                       │
    ▼                                                       │
META-PLAN (PRO)                                             │
    │                                                       │
    ├── /updoc Fases A→E+H (PLAN)                          │
    ├── /doctor Fases 1→2 (PLAN)                            │
    ├── /salud preview (datos heredados)                    │
    ├── Calcular bump type                                  │
    └── "¿Ejecutar BUILD?" (UNA confirmación)               │
    │                                                       │
    ▼ (FLASH)                                               │
BUILD                                                       │
    │                                                       │
    ├── /updoc Fase F                                       │
    ├── /salud BUILD* (status-salud.md)                     │
    ├── /version BUILD* (CHANGELOG, INDEX, template, commit)│
    └── /doctor Fase 3 (si correcciones)                    │
    │                                                       │
    └── SESSIONWORK                                         │
                                                           │
┌────────────────────────────────────────────────────────────┘
│
├── /circuito doctor ───────────────────────────────────────┐
│   META-PLAN (PRO) → BUILD (FLASH)                         │
│   /doctor Fases 1→2 → /salud BUILD* → /version patch*     │
│   (si correcciones)                                        │
│                                                           │
├── /circuito version ──────────────────────────────────────┤
│   META-PLAN (PRO) → BUILD (FLASH)                         │
│   /version Steps 1→5 → Steps 6→8 → sugiere /doctor        │
│                                                           │
└── /circuito completo ─────────────────────────────────────┘
    META-PLAN (PRO) → BUILD (FLASH)
    Agentes/skills sugeridos → /updoc → /salud* → /version* → /doctor
```

## Estados y transiciones

| N° | Estado | Entry | Acción | Exit | Próximo paso (via /circuito) |
|---|---|---|---|---|---|
| 1 | SESSIONWORK | Circuito inicia o reinicia | Usuario edita, agrega RM items, modifica código | Working tree dirty | `/circuito updoc` |
| 2 | META-PLAN | `/circuito` invocado | Fase PRO: PLAN de todos los comandos del workflow, tabla consolidada, UNA confirmación | Confirmación aceptada | BUILD (FLASH) |
| 3 | BUILD | META-PLAN confirmado | Fase FLASH: BUILD de todos los comandos (escritura) | BUILD completo | SESSIONWORK o sugiere siguiente paso |
| 4 | `/updoc` PLAN (en META-PLAN) | SESSIONWORK completo | Fases A→E+H: audita INDEX, stale, gaps, cross-ref | Plan auditado | Continúa META-PLAN con /doctor PLAN |
| 5 | `/doctor` PLAN (en META-PLAN) | `/updoc` PLAN completado | Fases 1→2: diagnóstico estructura, código, tracking, limpieza, deprecación | Diagnóstico completo | Continúa META-PLAN con /salud preview |
| 6 | `/salud` BUILD* | META-PLAN confirmado | Genera `doc/arch/status-salud.md`, actualiza INDEX | Reporte generado | `/version BUILD*` |
| 7 | `/version` (minor/patch) BUILD* | META-PLAN confirmado | Steps 6→8: CHANGELOG, INDEX, template, commit | BUILD + commit clean | sugiere /doctor o SESSIONWORK |
| 8 | `/doctor` BUILD | META-PLAN confirmado | Fase 3: aplicar correcciones (si hay) | Correcciones aplicadas | `/version patch BUILD*` si correcciones, SESSIONWORK si no |

## Workflows del orquestador

Los encadenamientos se definen en `~/.config/opencode/commands/circuito.md`:

| Workflow | Secuencia |
|---|---|
| `updoc` | META-PLAN (PRO): /updoc PLAN + /doctor PLAN + /salud preview → BUILD (FLASH): /updoc Fase F + /salud* + /version* + /doctor BUILD |
| `doctor` | META-PLAN (PRO): /doctor PLAN → BUILD (FLASH): /doctor Fase 3 + /salud* + /version patch* (si correcciones) |
| `version` | META-PLAN (PRO): /version Steps 1→5 → BUILD (FLASH): /version Steps 6→8 → sugiere /doctor |
| `completo` | META-PLAN (PRO): agentes/skills sugeridos + /updoc PLAN + /doctor PLAN → BUILD (FLASH): agentes + /updoc Fase F + /salud* + /version* + /doctor |

Ver `circuito.md` para la especificación completa de cada workflow.

## Contrato Meta-PLAN → BUILD

Cada workflow del circuito cumple:

1. **Meta-PLAN (PRO)**: leer, auditar, diagnosticar, calcular para TODOS los comandos del workflow. NO modificar archivos.
2. **Mostrar plan al usuario**: tabla consolidada con divisiones por comando (updoc, version, salud, doctor), hallazgos, cambios propuestos, impacto.
3. **Usuario confirma una sola vez** (sí).
4. **BUILD (FLASH)**: aplicar cambios de todos los comandos. Modificar archivos solo aquí.
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

- El encadenamiento vinculante lo controla `/circuito`, no los comandos individuales.
- El orquestador DEBE ejecutar Meta-PLAN primero, luego BUILD.
- El usuario puede rechazar el Meta-PLAN (rompiendo el circuito), pero el orquestador no puede saltar Meta-PLAN.
- Los agentes/skills sugeridos son opcionales — el usuario decide si incluirlos.
- Los comandos individuales ejecutados standalone NO tienen encadenamiento — solo ejecutan su propio PLAN→BUILD.

## Variantes del ciclo

| Escenario | Comando |
|---|---|
| Post-sesión con cambios documentales | `/circuito updoc` |
| Diagnóstico post-versionado | `/circuito doctor` |
| Versionado rápido sin /updoc | `/circuito version` |
| Ciclo completo con agentes + documentación | `/circuito completo` |
| Sin cambios en working tree | No inicia circuito — salta a sessionwork o fin |

## Archivos que referencian esta mecánica

- `~/.config/opencode/commands/circuito.md` — orquestador (SSOT de encadenamiento)
- `~/.config/opencode/commands/updoc.md`
- `~/.config/opencode/commands/version.md`
- `~/.config/opencode/commands/doctor.md`
- `~/.config/opencode/commands/salud.md`
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — diagrama de referencia
