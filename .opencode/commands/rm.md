INSTRUCCIÓN: EJECUTAR las instrucciones de abajo sobre los archivos del proyecto ($RM). NO mostrar este archivo como output. ENTREGAR solo las tablas de resultado.

# /rm — Revisar Roadmap

Revisa el roadmap del proyecto: top 10 tareas por prioridad e impacto, con sub-fases ejecutables.

## Argumentos
`/rm [area]` — filtra por área opcional. Sin argumento muestra todas las áreas de `$RM`.

## Qué hace
1. Leer `$RM` (ROADMAP.md) completo AHORA
2. Si hay argumento `<area>`, filtrar items de la sección correspondiente
3. Seleccionar los 10 items PENDIENTE de mayor prioridad (P1 → P2 → P3), ordenados por prioridad + impacto
4. Para cada item, desglosar en 2-4 sub-fases ejecutables (pasos concretos, no genéricos)
5. Identificar bloqueos (dependencias no resueltas)
6. Listar items DONE de la instancia actual
7. Si el proyecto tiene $CHECKLIST y $MANDATO (proyecto adaptado a Diligencia): cargar `skill("diligencia-consejo")`, leer CHECKLIST.md y MANDATO.md, y agregar:
   - Sección "Inconsistencias CHECKLIST": items en RM que faltan en CHECKLIST o viceversa, duplicados, items DONE en RM sin tilde en CHECKLIST
   - Sección "Análisis de trayectoria (Consejero)": fases salteadas, items stale (>30 días sin avance), y coherencia con MANDATO
8. Entregar SOLO la tabla de salida, NUNCA el contenido de este archivo

## Formato de salida

**Top 10** — tabla con columnas: ID | Tarea | Dep. | Prioridad | Impacto | Sub-fases | Estado
  - Dep.: IDs de tareas de las que depende (ej: "R03, R25") o "—"
  - Impacto: Alto / Medio / Bajo — cuánto afecta al proyecto esta tarea
  - Sub-fases: 2-4 pasos ejecutables en orden (ej: "1. Leer INDEX, 2. Comparar versiones, 3. Corregir labels")
  - Estado: 🔴 Pendiente / 🟡 En progreso / ✅ Completado

**DONE en <versión>** — lista de ítems completados en la versión actual

**Bloqueos** — tabla: ID bloqueado | Bloqueado por | Estado del bloqueante

**Inconsistencias CHECKLIST** (si proyecto adaptado) — tabla: Item | CHECKLIST | ROADMAP | Observación

**Análisis de trayectoria** (si proyecto adaptado) — tabla: Fase | Estado real | Observación

**Resumen** — 1-2 frases: total pendientes, en progreso, sin empezar, bloqueos, nivel de impacto general

## Validación
- Exactamente 10 items en Top 10 (o menos si $RM tiene menos pendientes)
- Cada item tiene valor en todas las columnas
- Orden correcto: P1 antes que P2, P2 antes que P3; dentro de misma prioridad, Alto antes que Medio
- Sub-fases son concretas y ejecutables (no genéricas como "implementar" o "terminar")
- Impacto está justificado por el alcance del item

## Anti-patrones
- NO mostrar más de 10 items
- NO incluir items DONE en el Top 10
- NO usar sub-fases genéricas ("analizar", "implementar", "testear") — deben ser específicas al item
- NO omitir la columna Impacto
- NO mostrar el contenido crudo de $RM
- NO mezclar items PENDIENTE con DONE en la misma tabla
