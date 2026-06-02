# MECANICA-CIRCUITO — Circuito de trabajo cíclico v1.10.3

Define los workflows multi-comando del ecosistema. El orquestador `/circuito` ejecuta los encadenamientos; los comandos individuales ya no contienen "Próximo paso" propio.
Referencia de hábitos de usuario: `GUIA_DE_BUENAS_PRACTICAS.md §9`.

---

## Diagrama del circuito

```
   SESSIONWORK
       │
       ├── /circuito updoc ──────────────────────────┐
       │                                             │
       ▼                                             │
   /updoc PLAN → BUILD                               │
       │                                             │
       ▼ (BUILD*)                                    │
   /version minor BUILD                              │
       │                                             │
       ▼ (sugiere)                                   │
   /doctor PLAN → BUILD                              │
       │                                             │
       ├── correcciones → /circuito doctor ──────────┘
       │                      │
       │                      ▼ (BUILD*)
       │                  /version patch BUILD
       │                      │
       │                      ▼
       └── sin correcciones ──→ SESSIONWORK

   *BUILD*: PLAN omitido — datos heredados del paso anterior
```

## Estados y transiciones

| N° | Estado | Entry | Acción | Exit | Próximo paso (via /circuito) |
|---|---|---|---|---|---|
| 1 | SESSIONWORK | Circuito inicia o reinicia | Usuario edita, agrega RM items, modifica código | Working tree dirty | `/circuito updoc` |
| 2 | `/updoc` | SESSIONWORK completo | Fases A→E→F: audita y sincroniza docs | BUILD completo | `/version minor BUILD*` |
| 3 | `/version` (minor) | `/updoc` BUILD | Steps 6→8: CHANGELOG, INDEX, commit | BUILD + commit clean | sugiere `/doctor` |
| 4 | `/doctor` | `/version` BUILD | Fases 1→2→3: diagnóstico y correcciones | BUILD completo | `/circuito doctor` si correcciones, SESSIONWORK si no |
| 5 | `/version` (patch) | `/doctor` correcciones | Steps 6→8 con bump patch, commit | BUILD + commit clean | SESSIONWORK |

## Workflows del orquestador

Los encadenamientos se definen en `~/.config/opencode/commands/circuito.md`:

| Workflow | Secuencia |
|---|---|
| `updoc` | /updoc PLAN→BUILD → /version minor BUILD* → sugiere /doctor |
| `doctor` | /doctor PLAN→BUILD → /version patch BUILD* (si correcciones) |
| `version` | /version PLAN→BUILD → sugiere /doctor |
| `completo` | workflow updoc → (opcional) workflow doctor |

Ver `circuito.md` para la especificación completa de cada workflow.

## Contrato PLAN → BUILD

Cada paso del circuito cumple:

1. **PLAN**: leer, auditar, diagnosticar, calcular. NO modificar archivos.
2. **Mostrar plan al usuario**: tabla de hallazgos, cambios propuestos, impacto.
3. **Usuario confirma explícitamente** (sí).
4. **BUILD**: aplicar cambios. Modificar archivos solo aquí.
5. **Output**: resumen de lo aplicado.

**Excepción BUILD\*:** Cuando un paso ejecuta BUILD\* (vía /circuito), los pasos 1-3 (PLAN + confirmación) se omiten. El PLAN ya fue ejecutado por el comando anterior del workflow.

## Vinculante

- El encadenamiento vinculante lo controla `/circuito`, no los comandos individuales.
- El orquestador DEBE ejecutar el siguiente paso del workflow al completar el paso actual.
- El usuario puede rechazar una sugerencia (rompiendo el circuito), pero el orquestador no puede saltar el paso siguiente.
- Los comandos individuales ejecutados standalone NO tienen encadenamiento — solo ejecutan su propio PLAN→BUILD.

## Variantes del ciclo

| Escenario | Comando |
|---|---|
| Post-sesión con cambios documentales | `/circuito updoc` |
| Diagnóstico post-versionado | `/circuito doctor` |
| Versionado rápido sin /updoc | `/circuito version` |
| Ciclo completo desde sessionwork | `/circuito completo` |
| Sin cambios en working tree | No inicia circuito — salta a sessionwork o fin |

## Archivos que referencian esta mecánica

- `~/.config/opencode/commands/circuito.md` — orquestador (SSOT de encadenamiento)
- `~/.config/opencode/commands/updoc.md`
- `~/.config/opencode/commands/version.md`
- `~/.config/opencode/commands/doctor.md`
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — diagrama de referencia
