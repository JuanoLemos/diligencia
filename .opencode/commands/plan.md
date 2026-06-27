INSTRUCCIÓN: PLANIFICAR la tarea del usuario. NO ejecutar cambios sin aprobación explícita. NO mostrar este archivo como output. ENTREGAR solo el plan.

# /plan — Planificar y luego ejecutar con BUILD

Planifica una tarea o grupo de tareas (ola) en modo PLAN (solo lectura + análisis), y una vez aprobado, ejecuta con BUILD. Soporta planificación individual o por olas desde `/next`.

## Argumentos

`/plan "<descripción>" [--ola N] [--sub-fases]`

- `<descripción>`: qué se va a hacer. Puede ser una tarea o un resumen del grupo.
- `--ola N`: tomar las tareas de la Ola N del último `/next` y planificarlas juntas.
- `--sub-fases`: desglosar cada tarea en 2-4 pasos ejecutables.

## Cuándo usarlo
- Tareas complejas que requieren análisis antes de implementar
- Cambios arquitectónicos que afectan múltiples archivos
- Grupos de tareas de una misma ola (/next) que conviene planificar juntas

## Qué hace

### Si es tarea individual (sin --ola)
1. MANTENERSE en modo PLAN (solo lectura + análisis, NO editar archivos aún)
2. Leer los archivos relevantes AHORA
3. Si `--sub-fases`: desglosar la tarea en 2-4 pasos secuenciales
4. Entregar plan con: archivos, líneas de cambio, riesgos, esfuerzo, sub-fases
5. Si proyecto adaptado: cargar consejero + agregar observaciones

### Si es grupo (--ola N)
1. Leer los IDs de tareas de la Ola N (desde el contexto de `/next`)
2. Para cada tarea del grupo: identificar archivos a modificar
3. **Detectar conflictos**: ¿2+ tareas tocan el mismo archivo? → tabla de conflictos
4. **Ordenar dentro de la ola**: si hay conflictos, secuenciar (no son paralelizables)
5. Desglosar sub-fases por tarea (si `--sub-fases`)
6. Entregar plan consolidado del grupo

## Formato de salida

### Tarea individual

**Plan — <tarea>**
- **Archivos a modificar**: lista de rutas exactas
- **Líneas de cambio**: qué agregar/quitar en cada archivo
- **Sub-fases** (si --sub-fases): 1. Paso concreto, 2. Paso concreto, 3. Paso concreto
- **Riesgos**: impactos potenciales y mitigaciones
- **Esfuerzo**: chica / mediana / grande

### Grupo (--ola N)

**Plan — Ola N: <N tareas>**
- **Tareas**: tabla ID | Tarea | Archivos | Sub-fases | Esfuerzo
- **Conflictos detectados**: tabla Archivo | Tocado por | Conflicto | Resolución
- **Orden sugerido** dentro de la ola (si hay conflictos que impiden paralelismo real)
- **Riesgos compartidos**: impactos que aplican a todo el grupo
- **Esfuerzo total**: suma de esfuerzos individuales

### Ambos
- **Observaciones del Consejero** (si proyecto adaptado): tabla Tipo | Observación | Sugerencia
- **Pregunta de aprobación**: "¿Apruebo para BUILD?"

## Validación
- El plan cubre todos los requisitos del usuario
- Cada archivo listado tiene especificado qué cambio hacer
- Conflictos entre tareas del grupo están identificados
- Sub-fases son concretas y ejecutables (si --sub-fases)
- Esfuerzo estimado está presente por tarea y total

## Anti-patrones
- NO entrar en modo BUILD sin aprobación explícita del usuario
- NO modificar archivos durante la fase PLAN
- NO omitir la sección de riesgos
- NO dar una estimación sin justificación
- NO ignorar conflictos entre tareas de una misma ola
- NO asumir que todas las tareas de una ola son realmente paralelizables — verificar conflictos de archivos
