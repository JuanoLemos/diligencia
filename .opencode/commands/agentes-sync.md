INSTRUCCION: INVOCAR a @documentador para sincronizar agentes y escanear $PROYECTOS. NO modificar archivos sin confirmacion. NO ejecutar cambios sin preguntar.

# /agentes-sync — Sincronizar agentes + escanear $PROYECTOS

Ejecuta dos fases secuenciales. Fase 1: sincroniza agentes con nuevas mecanicas/guias.
Fase 2: escanea $PROYECTOS buscando desviaciones estructurales no reportadas.

## Argumentos

`/agentes-sync [--dry-run] [--fase "1|2"]`

Sin argumentos: modo interactivo — ejecuta ambas fases y pregunta antes de aplicar.
`--dry-run`: solo mostrar tablas sin modificar nada.
`--fase 1`: solo sincronizar agentes.
`--fase 2`: solo escanear $PROYECTOS.

---

## Fase 1 — Sincronizar agentes con mecanicas y guias

1. LEER `doc/mecanicas/*.md` y `doc/guias/*.md` — listar docs disponibles
2. LEER `~/.config/opencode/agents/*.md` — para cada agente:
   - Buscar seccion `## Documentacion relacionada` existente
   - Si no existe, anotar que no tiene
3. CLASIFICAR docs por relevancia para cada agente segun:
   - `doc/mecanicas/MANDATO.md` (mandatos)
   - `MECANICA-LLM.md` (multi-modelo)
   - `MECANICA-TASK-ROUTER.md` (tipo de tarea)
4. MOSTRAR tabla: `| Agente | Docs existentes | Docs nuevos a agregar |`
5. PREGUNTAR: "Aplicar cambios en N agentes? [si/no]"
6. Si si: actualizar `## Documentacion relacionada` en cada agente

---

## Fase 2 — Escanear $PROYECTOS por desviaciones

1. LEER `AGENTS.md` -> extraer `$PROYECTOS`
2. LEER `DILIGENCIA.md` -> version actual
3. LEER `doc/arch/catalogo-proyectos.md` -> ultima revision por proyecto

4. POR CADA proyecto en `$PROYECTOS`:
   a. LEER `DILIGENCIA.md` del proyecto -> version heredada
   b. LEER `AGENTS.md` del proyecto -> variables actuales
   c. Verificar directorios estandar: `doc/guias/`, `doc/mecanicas/`, `doc/arch/`
   d. LEER `ROADMAP.md` del proyecto -> secciones actuales
   e. Comparar con lo esperado para su version heredada (segun `adaptar.md`)
   f. Si hay desviaciones:
      - Anotar como M## (M101, M102...)
      - Clasificar por tipo: variables_extra, folder_extra, roadmap_change, doc_orphan
      - Mostrar en tabla

5. MOSTRAR tabla:
   ```
   | Proyecto | Version | Ultima revision | Desviaciones | WT |
   ```

6. ACTUALIZAR `doc/arch/catalogo-proyectos.md` con:
   - Fecha de ultima revision
   - Conteo de desviaciones detectadas
   - WT actual

7. PREGUNTAR: "Registrar desviaciones como pendientes en catalogo-proyectos.md? [si/no]"

---

## Formato de salida

```
Fase 1: agentes...
N agentes revisados, M necesitan actualizacion
@agente1: +2 docs
@agente3: sin cambios

Fase 2: $PROYECTOS...
Diligencia vX.Y.Z -> N proyectos escaneados
| Proyecto | Desviaciones | WT |
| Nemesis | +1 variable, +1 seccion ROADMAP | limpio |
```

## Validacion

- Los docs de agentes deben existir en disco
- No duplicar un doc que el agente ya referencia
- `MECANICA-TASK-ROUTER.md` siempre se agrega a MAIN
- `MANDATO.md` siempre se agrega a todos los agentes
- Las desviaciones son comparativas, no juicios de valor

## Anti-patrones

- NO agregar docs que ya existen en la seccion del agente
- NO sobrescribir la seccion completa
- NO modificar proyectos sin mostrar la tabla de desviaciones primero
- NO ejecutar /adaptar en proyectos con desviaciones — solo reportar

## Archivos que modifica
- `~/.config/opencode/agents/*.md` — seccion `## Documentacion relacionada`
- `doc/arch/catalogo-proyectos.md` — ultima revision y desviaciones
