INSTRUCCIÓN: INVOCAR a @documentador para sincronizar agentes con las mecánicas y guías del proyecto. NO modificar archivos sin aprobación del usuario. NO ejecutar cambios sin preguntar.

# /agentes-sync — Sincronizar agentes con mecánicas y guías del proyecto

Actualiza las referencias `## Documentación relacionada` en los agentes globales
cuando se crean nuevas mecánicas o guías. Detecta qué docs nuevos existen y
decide qué agentes deben conocerlos.

## Argumentos

`/agentes-sync [--dry-run] [--tipo "mecanica|guia"]`

Sin argumentos: modo interactivo — muestra tabla de cambios y pregunta antes de aplicar.
`--dry-run`: solo mostrar qué agentes recibirían qué docs, sin modificar nada.
`--tipo mecanica`: solo sincronizar mecánicas (MECANICA-*.md).
`--tipo guia`: solo sincronizar guías (GUIA_*.md).

## Qué hace

1. LEER `doc/` del proyecto — listar todas las mecánicas y guías disponibles
   - `doc/mecanicas/*.md` → extraer títulos
   - `doc/guias/*.md` → extraer títulos

2. LEER `~/.config/opencode/agents/*.md` — para cada agente:
   - Buscar sección `## Documentación relacionada` existente
   - Si no existe, anotar que no tiene
   - Si existe, extraer qué docs ya referencia

3. CLASIFICAR docs por relevancia para cada agente según:
   - Reglas en `doc/mecanicas/MANDATO.md` (para mandatos)
   - Reglas en `MECANICA-LLM.md` (para estrategia multi-modelo)
   - Reglas en `MECANICA-TASK-ROUTER.md` (para tipo de tarea)
   - Tipo de contenido: si es un doc que cualquier agente puede necesitar, se agrega a MAIN

4. MOSTRAR tabla:
   ```
   | Agente | Docs existentes | Docs nuevos a agregar |
   ```

5. PREGUNTAR: "¿Aplicar cambios en N agentes? [sí/no/seleccionar]"

6. Si sí: para cada agente, agregar o actualizar `## Documentación relacionada` con los docs nuevos

## Formato de salida

```
📡 Escaneando agentes en ~/.config/opencode/agents/...
📋 N agentes revisados, M necesitan actualización
✅ @agente1: +2 docs (MECANICA-X, GUIA-Y)
✅ @agente2: +1 doc (MECANICA-Z)
⏭️ @agente3: sin cambios
```

## Validación

- Los docs listados deben existir en disco
- No duplicar un doc que el agente ya referencia
- `MECANICA-TASK-ROUTER.md` siempre se agrega a MAIN
- `MANDATO.md` siempre se agrega a todos los agentes

## Anti-patrones

- NO agregar docs que ya existen en la sección del agente
- NO sobrescribir la sección completa — solo agregar los nuevos
- NO modificar agentes sin mostrar la tabla de cambios primero

## Archivos que modifica
- `~/.config/opencode/agents/*.md` — sección `## Documentación relacionada`
