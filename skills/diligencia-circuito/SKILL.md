# diligencia-circuito — Skill de Integridad Lógica y UX

Skill que escanea el proyecto en busca de circuitos rotos: handlers vacíos, callejones sin salida, rutas huérfanas, navegación rota, estados no manejados, y feedback faltante.

## Cuándo cargar

- `/circuito` — escaneo completo del proyecto
- `/circuito <area>` — escaneo focalizado (dashboard, ui, api, tx)
- `/doctor` Fase 1g — diagnóstico automático del circuito lógico
- Cuando el usuario pregunta "¿este botón funciona?" / "¿esto tiene sentido?"

## Checklist de 8 verificaciones

| # | Check | Patrón a buscar | Severidad |
|---|-------|-----------------|-----------|
| 1 | Handlers vacíos | `onClick={() => {}}`, `onClick={handlerInexistente}`, `onSubmit` sin lógica | P3 |
| 2 | Callejones sin salida | Modal sin cerrar, `if (loading) return null` sin spinner, página sin retorno | P3 |
| 3 | Rutas huérfanas | Endpoint backend sin `fetch` consumidor en frontend | P3 |
| 4 | Fetch sin endpoint | `fetch("/api/x")` sin ruta backend | P2 |
| 5 | Estados no manejados | `if (loading)` sin else, `.map()` sin fallback, error sin retry | P3 |
| 6 | Navegación rota | `<a href="/ruta">` sin página, `router.push` a ruta inexistente | P2 |
| 7 | Consistencia UX | Misma acción con distinto comportamiento entre componentes | P3 |
| 8 | Feedback faltante | POST/DELETE sin toast, "Eliminar" sin confirm dialog | P3 |

## Cómo escanear

1. Leer AGENTS.md para mapear archivos frontend/backend
2. Delegar a `@explore` para búsquedas masivas de patrones
3. Para checks 3-4: extraer todas las rutas backend y todos los fetch frontend, cruzar
4. Para checks 1-2 y 5-8: buscar patrones con `rg` / `grep`

## Formato de salida

**Circuito lógico** — tabla:

| # | Check | Archivo:Línea | Hallazgo | Severidad |
|---|-------|---------------|----------|-----------|

**Resumen:** N hallazgos (X P2, Y P3)

## Integración con /doctor

En `/doctor` Fase 1g, los hallazgos se reportan en la tabla consolidada de Fase 2. En Fase 3g, cada hallazgo con archivo:línea se registra como bug en `$BUGS`.

## Anti-patrones

- NO reportar sin archivo:línea
- NO sugerir implementaciones
- NO usar prosa — tabla
- NO reportar handlers que claramente funcionan
