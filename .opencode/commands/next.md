INSTRUCCIÓN: EJECUTAR las instrucciones de abajo sobre los archivos del proyecto ($RM, $CHECKLIST). NO mostrar este archivo como output. ENTREGAR solo el plan de ejecución.

# /next — Próximos pasos: plan de ejecución por olas

Agrupa las tareas pendientes del roadmap en olas (waves) según dependencias. Las tareas de una misma ola pueden ejecutarse en paralelo. Usa el agente `@consejero` para validar agrupación y priorización.

## Qué hace
1. Leer `$RM` (ROADMAP.md) y `$CHECKLIST` AHORA
2. Construir grafo de dependencias entre items PENDIENTE
3. Agrupar en olas (Waves):
   - **Ola 1**: tareas sin dependencias pendientes — ejecutables ya
   - **Ola 2**: tareas cuyas dependencias están todas en Ola 1
   - **Ola N**: tareas cuyas dependencias están en olas anteriores
4. Priorizar dentro de cada ola: P1 → P2 → P3, luego por impacto
5. Para cada tarea, desglosar en 2-4 sub-fases ejecutables
6. Si el proyecto está adaptado a Diligencia: delegar a `@consejero` para:
   - Validar la agrupación de olas
   - Detectar deuda que bloquea (bugs abiertos, ADRs faltantes)
   - Emitir recomendación concreta
7. Si el proyecto tiene $UX_CHECK (proyecto adaptado a Diligencia): leer doc/arch/ux-check.md, detectar filas con resultado "⚠️" o "❌", y agregar al inicio del reporte ⚠️ "N features pendientes de validación UX. Probá y actualizá $UX_CHECK antes de ejecutar nuevas tareas."
8. Entregar SOLO el plan de ejecución, NUNCA el contenido de este archivo

## Formato de salida

⚠️ **Pendiente de validación UX**: N features sin validar en `$UX_CHECK` — solo si hay pendientes, antes del plan.

**📋 Plan de ejecución — Olas**

🌊 **Ola 1** — ejecutar en paralelo (sin dependencias entre sí)
| ID | Tarea | Dep. | Prioridad | Impacto | CHECKLIST | Sub-fases |

🌊 **Ola 2** — ejecutar tras Ola 1
| ID | Tarea | Dep. | Prioridad | Impacto | CHECKLIST | Sub-fases |

... (más olas si aplica)

⚠️ **Bloqueados** — tareas con dependencias no resueltas
| ID | Tarea | Bloqueado por |

🧭 **Priorización estratégica (Consejero)** — si proyecto adaptado
- Orden real validado
- Deuda que bloquea
- Recomendación: "Empezar por Ola 1 — N tareas independientes, ~Xhs estimadas"

**📊 Resumen** — N tareas en M olas | N bloqueadas | Impacto general

## Validación
- Cada ola contiene solo tareas sin dependencias cruzadas entre sí
- Las dependencias de una ola se resuelven en olas anteriores
- Cada tarea tiene sub-fases concretas (no genéricas)
- El consejero validó la agrupación (si proyecto adaptado)
- Las tareas bloqueadas aparecen al final con su bloqueante identificado

## Anti-patrones
- NO poner en la misma ola tareas que dependen entre sí
- NO incluir items DONE
- NO agrupar sin considerar impacto — P1 Alto antes que P3 Bajo
- NO usar sub-fases genéricas — deben ser específicas a la tarea
- NO omitir tareas bloqueadas — deben listarse aunque no estén en ninguna ola
