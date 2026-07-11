# MECANICA-OLAS — Sistema de oleadas de tareas v1.0

Define el formato de wave manifest, reglas de ejecucion y manejo de errores
para ejecucion masiva de tareas por agentes autonomos.

---

## Formato del wave manifest

Los manifests viven en `doc/olas/<proyecto>-ola-NN.md`.

```markdown
# <proyecto> Ola NN — v1.0
> Planificada: YYYY-MM-DD | Agentes: @a, @b

| ID | Tarea | Agente | Proyecto | Depende | OnFail | Estado |
|----|-------|--------|----------|---------|--------|--------|
| T1 | ... | @narrador | Nemesis | — | skip | ⚪ Pendiente |
| T2 | ... | @trader | MarketAI | — | skip | ⚪ Pendiente |
| T3 | ... | @sdd-implement | Nemesis | T1 | escalate | ⚪ Pendiente |
```

## Reglas OnFail

| OnFail | Comportamiento |
|---|---|
| `skip` | Fallo -> se marca rojo. La ola sigue sin pausa. |
| `retry:N` | Reintentar hasta N veces. Si todas fallan -> skip. |
| `escalate` | Fallo -> pausar SOLO tareas que dependen de esta. Las independientes siguen. |
| `fallback:T2` | Si falla, ejecutar la tarea alternativa T2. |

## Ejecucion

- Tareas sin dependencias y de DISTINTO proyecto -> paralelo
- Tareas del MISMO proyecto -> secuencial (R1: 1 agente por proyecto a la vez)
- Cada tarea completada actualiza su Estado en el manifest
- Si falla: se aplica la regla OnFail declarada
- Las tareas fallidas con `skip` generan entrada en `$BUGS` via `/reportar`

## Estados

| Estado | Significado |
|---|---|
| ⚪ Pendiente | No iniciada |
| 🟡 En progreso | Agente trabajando |
| 🟢 OK | Completada exitosamente |
| 🔴 Fallo | Fallo tras agotar reintentos |
| ⏭️ Saltado | No ejecutada por dependencia fallida |

## Archivos relacionados
- `.opencode/commands/ola.md` — comando de invocacion
- `doc/olas/_template.md` — template para nuevas olas
- `MECANICA-TASK-ROUTER.md` — mapeo tarea -> agente -> modelo
