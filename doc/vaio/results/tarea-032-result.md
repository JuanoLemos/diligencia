# Resultado Tarea 032 — Restaurar prompts VAIO

**Estado:** ✅ Completado
**Fecha:** 2026-07-28

## Acciones ejecutadas

1. Consulta API `/api/projects/.../scheduled-tasks` → 2 tareas encontradas
2. Limpieza de duplicados: 0 eliminados (sin duplicados)
3. Prompt `$realPrompt` (280 chars) restaurado en `VAIO: check-tareas`
4. Prompt `$puPrompt` (180 chars) restaurado en `VAIO: publish-url`
5. PUT request por cada tarea con `enabled=true`, `providerID=deepseek`, `modelID=deepseek-v4-flash`

## Verificación final

| Name | promptChars | enabled |
|------|-------------|---------|
| VAIO: check-tareas | 285 | True |
| VAIO: publish-url | 183 | True |

Ambos tasks activos y con prompts correctos.
