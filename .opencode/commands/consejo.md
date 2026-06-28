INSTRUCCIÓN: EJECUTAR las instrucciones de abajo. NO mostrar este archivo como output. ENTREGAR solo las observaciones del consejero.

# /consejo — Consultar al Consejero

Consulta al consejero del proyecto sobre cualquier duda, idea o decisión. El consejero no codea — observa, pregunta, sugiere.

## Argumentos

`/consejo <duda o idea>`
`/consejo --explorar <url|término>`

Ejemplos:
- `/consejo ¿debería expandir a CEDEARs antes de validar paper trading?`
- `/consejo estoy pensando en agregar un analizador de order flow`
- `/consejo ¿qué me falta para pasar a producción?`
- `/consejo --explorar https://github.com/usuario/repo`
- `/consejo --explorar "best practices documentation structure"`

Sin argumento: el consejero hace una revisión general del estado del proyecto.
`--explorar`: el consejero explora una fuente externa (repo GitHub, docs, API) y propone mejoras concretas para el proyecto.

## Qué hace

1. Leer AGENTS.md del proyecto para mapear $RM, $CHECKLIST, $MANDATO, $BUGS, $ADRS
2. Cargar `skill("diligencia-consejo")` y aplicar las 6 preguntas del checklist
3. Leer ROADMAP.md, CHECKLIST.md, MANDATO.md, bugs.md, ADR_SUMMARY.md
4. Si el usuario pasó argumento, enfocar el análisis en esa duda/idea
5. Si no hay argumento, hacer revisión general del estado del proyecto
6. Entregar SOLO las observaciones (NUNCA el contenido de este archivo)

### Modo --explorar

1. LEER el argumento `--explorar <url|término>` AHORA
2. CARGAR `skill("diligencia-consejo")` para contexto del proyecto
3. SI es una URL: WebFetchear la URL para obtener su contenido
   SI es un término: WebFetchear resultados de búsqueda relevantes
4. ANALIZAR el recurso externo con las 6 preguntas del consejero enfocadas en el proyecto:
   - ¿Qué patrón externo contradice un supuesto del proyecto?
   - ¿Qué técnica del recurso externo aplica al dominio del proyecto?
   - ¿Qué item del ROADMAP podría acelerarse con lo aprendido?
   - ¿Qué deuda técnica se detecta comparando con el recurso externo?
   - ¿Hay algún principio del MANDATO que el recurso externo refuerza o contradice?
   - ¿Qué puede aprender el proyecto del recurso externo?
5. CRUZAR hallazgos con el estado actual del proyecto (ROADMAP, CHECKLIST, AGENTS.md)
6. PROPONER sugerencias concretas: cada una debe ser accionable (un ROADMAP item, un cambio de estructura, un nuevo comando)
7. ENTREGAR SOLO la tabla de sugerencias

## Formato de salida

**Consulta:** [duda/idea del usuario o "Revisión general"]

**Observaciones del Consejero** — tabla:

| # | Tipo | Observación | Sugerencia |
|---|------|-------------|------------|
| 1 | Supuesto | ... | ... |
| 2 | Dominio | ... | ... |
| 3 | Roadmap | ... | ... |
| 4 | Deuda | ... | ... |
| 5 | Mandato | ... | ... |
| 6 | Aprender | ... | ... |

Si una categoría no aplica a la consulta, poner "—".

**Veredicto** — una frase: "Adelante con cautela" / "Sugiero validar X antes" / "Riesgo alto: reconsiderar" / "Proyecto estable, seguir roadmap".

### Salida modo --explorar

**Exploración:** <URL o término>

**Sugerencias del Consejero** — tabla:

| # | Dimensión | Hallazgo externo | Estado Diligencia | Sugerencia concreta |
|---|-----------|-----------------|-------------------|---------------------|
| 1 | Estructura | Usan X para Y | Diligencia usa Z | Adoptar X como R56 |
| 2 | Comandos | Tienen /abc | No existe | Agregar comando /abc |
| 3 | Workflow | Flujo A→B→C | Flujo similar pero manual | Automatizar paso B |
| ... | ... | ... | ... | ... |

**📊 Resumen:** N sugerencias concretas para el proyecto

## Validación

- Las 6 filas de la tabla están presentes (aunque digan "—")
- Si el usuario pasó argumento, la consulta se refleja en las observaciones
- Si se usó `--explorar`, la URL o término se WebFetcheó antes de analizar
- Las sugerencias del modo `--explorar` son accionables (no genéricas)
- El veredicto es una frase concreta, no genérica

## Anti-patrones

- NO sugieras código ni implementaciones
- NO decidas por el usuario — sugerí, no ordenes
- NO repitas el ROADMAP sin agregar perspectiva
- NO emitas observaciones sin haber leído el estado real del proyecto
- NO uses prosa larga — tabla + veredicto, nada más
- NO uses `--explorar` sin tener AGENTS.md, ROADMAP.md y MANDATO.md del proyecto
- NO propongas sugerencias que contradigan el MANDATO del proyecto
