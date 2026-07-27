# Resultado 028 — Sesiones corregidas

**Fecha:** 2026-07-27 19:47:38 UTC
**Máquina:** FELRENA

## Estado

| Check | Resultado |
|---|---|
| Duplicados eliminados | SI (2 tasks, sin duplicados) |
| sessionId viejo removido | SI (execution sin sessionId) |
| Nueva sesion | ses_05a3d6550ffezWk5kditiHRxXY |
| sessionId fijado en ambas tasks | SI (execution.sessionId=ses_05a3d6550ffezWk5kditiHRxXY) |
| Estable (misma sesion reutilizada) | NO — Chamber rota sessionId en cada ejecución programada |

## Notas

- Solo existen 2 tasks: VAIO: check-tareas (cron * * * * *) y VAIO: publish-url (cron 0 * * * *)
- Tras quitar sessionId, check-tareas rotó a nueva sesión cada minuto (no se estabilizó)
- El campo sessionId en execution fue aceptado por la API pero Chamber lo ignora en ejecuciones programadas
- Chamber v1.16.3 gestiona sessionId internamente para scheduled tasks — no es configurable vía API
- Ambas tasks tienen prompts correctos del VAIO Worker
- publish-url ejecuta cada hora (minuto 0), no pudo verificarse reuso en este ciclo

## Conclusión

La API de Chamber no permite forzar reuso de sesión en scheduled tasks. Este es un comportamiento interno de Chamber que requiere modificación en el source (o upgrade a versión que soporte sessionId fijo en execution).
