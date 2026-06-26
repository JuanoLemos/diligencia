# MECANICA-CONSEJO — Consejero de Proyecto v1.0.0

## Propósito

Agregar una capa de revisión de decisiones a los comandos Diligencia. El consejero no revisa código (`@sdd-reviewer`) — revisa **decisiones**: ¿tiene sentido esto para el proyecto ahora?

## Agentes y skills

| Componente | Ubicación | Rol |
|---|---|---|
| `@consejero` | `~/.config/opencode/agents/consejero.md` | Agente read-only que aplica 6 preguntas |
| `diligencia-consejo` | `skills/diligencia-consejo/SKILL.md` | Skill cargable por comandos |

## Flujo

```
/consejo  → cargar skill → @consejero analiza → tabla + veredicto (standalone)
/plan     → cargar skill → @consejero analiza → plan con Observaciones
/next     → cargar skill → @consejero prioriza → Top 5 + Priorización estratégica
/RM       → cargar skill → @consejero analiza → PENDIENTE/DONE + Análisis de trayectoria
/checklist → cargar skill → @consejero detecta deuda → Inconsistencias + Deuda
/explica  → cargar skill → @consejero agrega 4ª capa → criollo/técnico/impacto/implicancia
```

## Las 6 preguntas

1. **Supuestos no validados** — ¿Qué se asume sin verificar?
2. **Conocimiento de dominio** — ¿Qué falta saber del dominio?
3. **Orden del ROADMAP** — ¿Se respeta el orden planeado?
4. **Deuda acumulada** — Bugs, fases incompletas, features sin validar
5. **Coherencia con MANDATO** — ¿El mandato respalda esta dirección?
6. **Investigar primero** — ¿Estudiar/validar antes de codificar?

## Cuándo NO aplicar

- Ediciones triviales (<5 líneas, 1 archivo, sin decisión de diseño)
- Corrección de bugs tipográficos o de formato
- Tareas puramente operativas (backup, limpieza)
- Cuando el usuario explícitamente pide "sin consejero"

## Integración con CBP

El consejero NO está en el circuito CBP. CBP es commit workflow. El consejero es planificación y revisión de decisiones. Son ortogonales:

```
/plan (+consejero) → BUILD → /CBP → COMMIT
                         ↑
                    @sdd-reviewer
                    (revisa código, no decisiones)
```

## Archivos relacionados

| Archivo | Rol |
|---|---|
| `AGENTS.md` | Mapea `$RM`, `$CHECKLIST`, `$MANDATO`, `$BUGS`, `$ADRS` |
| `ROADMAP.md` | Fuente de verdad de trayectoria |
| `CHECKLIST.md` | Estado granular de implementación |
| `MANDATO.md` | Reglas del proyecto |
| `doc/arch/bugs.md` | Deuda técnica abierta |
| `doc/arch/ADR_SUMMARY.md` | Decisiones arquitectónicas documentadas |
| `MECANICA-CONSEJO.md` | Este archivo |
