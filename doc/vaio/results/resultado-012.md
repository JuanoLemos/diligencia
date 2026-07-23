# Resultado 012 — Scheduled Tasks configuradas

**Fecha:** 2026-07-22 14:35 UTC

## Tareas creadas vía API

| ID | Tarea | Cron | Próxima ejecución | Estado |
|---|---|---|---|---|
| `3264cb0e` | VAIO: check-tareas | `* * * * *` (cada 1 min) | ~14:36 UTC | idle |
| `157f824c` | VAIO: cloudflared-watchdog | `*/5 * * * *` (cada 5 min) | ~14:40 UTC | idle |
| `dd0c341c` | VAIO: publish-url | `0 * * * *` (cada 1 hora) | ~15:00 UTC | idle |

## Método

Creadas mediante `curl -X PUT` a la API REST de Chamber en `localhost:57123/api/projects/path_.../scheduled-tasks`.

Correcciones aplicadas sobre la tarea original:
- Agregado `providerID: "deepseek"` (requerido por la API)
- Agregado `modelID: "deepseek-v4-flash"` (requerido por la API)

## Sistema anterior deprecado

| Componente | Estado |
|---|---|
| `worker-loop.md` | Deprecado (reemplazado por scheduled tasks) |
| `startup-tunnel.ps1` | Deprecado (reemplazado por tunnel nativo Chamber) |
| `VAIO-SCHEDULED.md` | Activo (nuevo sistema) |
