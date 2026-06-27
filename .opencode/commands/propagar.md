INSTRUCCIÓN: EJECUTAR PLAN→BUILD. Propagar actualizaciones de Diligencia a proyectos adaptados en $PROYECTOS. NO leer código fuente ni datos — solo archivos estructurales Diligencia. NO mostrar este archivo como output.

# /propagar — Propagar actualizaciones de Diligencia

Propaga actualizaciones de la metodología Diligencia a los proyectos adaptados listados en `$PROYECTOS`.
Detecta la versión actual de Diligencia, compara con la de cada proyecto, y ofrece aplicar Flujo C de `/adaptar`.

---

## Argumentos

`/propagar [--dry-run] [--notify]`

Sin argumentos: modo interactivo — muestra tabla y pregunta antes de cada acción.
`--dry-run`: solo mostrar tabla de versiones, sin modificar nada.
`--notify`: solo escribir `UPDATE-AVAILABLE.md` en cada proyecto atrasado, sin ejecutar `/adaptar`.

---

## Qué hace (PLAN→BUILD)

### PLAN

1. LEER versión actual de Diligencia:
   - Leer `DILIGENCIA.md` en el proyecto actual → extraer `vX.Y.Z` del header
   - Si no se encuentra → ⚠️ "No se detectó versión de Diligencia en este proyecto." → DETENER

2. LEER `$PROYECTOS` de `AGENTS.md`:
   - Si no está configurado (`"*(configurar)*"` o vacío) → ⚠️ "`$PROYECTOS` no configurado. Sin él, `/propagar` no puede escanear proyectos." → DETENER

3. POR CADA proyecto en `$PROYECTOS`:
   a. Verificar que la ruta existe → si no, marcar como "❌ Ruta rota"
   b. Verificar existencia de `DILIGENCIA.md` → si no, marcar como "❌ No adaptado"
   c. Extraer versión Diligencia del proyecto del header
   d. Comparar con versión actual de Diligencia
   e. Verificar `git -C <path> status --porcelain` (si no es repo git, marcar "⚠️ Sin git")
   f. Consultar `doc/arch/catalogo-proyectos.md` para detectar proyectos congelados (🧊)

4. MOSTRAR tabla:
   ```
   | Proyecto | Versión local | Diligencia actual | Atraso | WT | Estado |
   ```
   Con emojis: 🟢 al día, 🟡 atrasado, 🔴 muy atrasado (≥2 versions), 🧊 congelado, ❌ sin adaptar

5. Si `--dry-run` → DETENER aquí (solo reporte)

6. PREGUNTAR: "¿Propagar a los N proyectos atrasados? [sí/no/seleccionar]"
   - Si `seleccionar` → preguntar por cada proyecto individualmente

### BUILD (por cada proyecto atrasado seleccionado)

1. EXCLUIR proyectos congelados (🧊 en catalogo-proyectos.md)

2. Si working tree dirty → ⚠️ "WT dirty en `<proyecto>`. Commiteá antes de propagar." → SALTAR

3. ESCRIBIR `UPDATE-AVAILABLE.md` en raíz del proyecto:
   ```
   # UPDATE AVAILABLE — Diligencia vX.Y.Z
   
   Tu proyecto usa Diligencia vA.B.C.
   Hay una nueva versión disponible: **vX.Y.Z**.
   
   Ejecutá `/adaptar` para actualizar tu proyecto a la última versión de la metodología.
   
   Fecha de detección: YYYY-MM-DD
   
   ## Archivos relacionados
   - `DILIGENCIA.md` — versión actual del proyecto
   - `doc/arch/status-salud.md` — salud del proyecto
   ```

4. Si `--notify` → CONTINUAR al siguiente proyecto (solo archivo, sin /adaptar)

5. PREGUNTAR: "¿Ejecutar /adaptar Flujo C en `<proyecto>`? [sí/no]"
   - Si sí → delegar a `@sdd-architect` (explorar estructura) + `@sdd-implement` (aplicar Flujo C de /adaptar)
   - Si no → SALTAR al siguiente

6. REGISTRAR en `doc/arch/propagaciones.md`:
   ```
   | Fecha | Proyecto | Desde | Hasta | Resultado |
   ```
   - Si no existe el archivo → crearlo con header y tabla

7. REPORTAR resumen final: N proyectos escaneados, M actualizados, K con errores o saltados

---

## Formato de salida
📡 Escaneando N proyectos en $PROYECTOS...
📊 Diligencia vX.Y.Z → N proyectos atrasados, M al día, K congelados
📝 UPDATE-AVAILABLE.md escrito en N proyectos
🔄 /adaptar Flujo C ejecutado en M proyectos
⏭️ K proyectos saltados (WT dirty / congelados / sin git)

---

## Validación
- Versión de Diligencia detectada correctamente de `DILIGENCIA.md`
- `$PROYECTOS` configurado en `AGENTS.md`
- Cada proyecto verificado por existencia de `DILIGENCIA.md`
- `UPDATE-AVAILABLE.md` escrito con formato correcto
- Proyectos congelados excluidos automáticamente
- `propagaciones.md` actualizado con cada operación

## Anti-patrones
- NO propagar a proyectos con WT dirty sin advertir
- NO saltarse la verificación de `git status` antes de tocar
- NO ejecutar /adaptar sin confirmación explícita por proyecto
- NO modificar proyectos congelados
- NO propagar si `$PROYECTOS` no está configurado
- NO hardcodear rutas de proyectos — usar `$PROYECTOS`

## Archivos relacionados
- `AGENTS.md` — variable `$PROYECTOS`
- `DILIGENCIA.md` — versión actual de la metodología
- `doc/arch/catalogo-proyectos.md` — catálogo con estados
- `doc/arch/propagaciones.md` — log de propagaciones
- `.opencode/commands/adaptar.md` — Flujo C de actualización
- `.opencode/commands/version.md` — post-bump sugiere /propagar
