# <Proyecto> Ola <NN> — v1.0
> Planificada: <YYYY-MM-DD> | Agentes: <@a, @b, @c>

## Tareas

| ID | Tarea | Archivos | Agente | Proyecto | Depende | OnFail | Estado |
|----|-------|----------|--------|----------|---------|--------|--------|
| T1 | <descripcion> | <ruta> | @agente | <proyecto> | — | skip | ⚪ Pendiente |
| T2 | <descripcion> | <ruta> | @agente | <proyecto> | T1 | escalate | ⚪ Pendiente |
| T3 | <descripcion> | <ruta> | @agente | <proyecto> | — | retry:3 | ⚪ Pendiente |

## Revision pre-ejecucion

- [ ] Usuario aprobo la ola
- [ ] Sin conflictos de archivos detectados
- [ ] WT limpio en todos los proyectos involucrados
- [ ] API keys verificadas en maestro .env

## Post-ejecucion

- [ ] Todas las tareas completadas
- [ ] Fallos registrados en $BUGS
- [ ] /CBP sugerido en proyectos con cambios

---

> Generado por `/ola planear`. Agregar o quitar tareas segun prioridad.
