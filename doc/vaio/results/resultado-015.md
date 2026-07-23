# Resultado 015 — Diagnóstico instalación Chamber

**Fecha:** 2026-07-23 13:07:37 UTC

## Resultados

| Check | Valor |
|---|---|
| app.asar existe | SI |
| packages/ existe (source plano) | NO |
| runtime.js plano existe | NO |
| Contenido de resources/ | [app.asar.unpacked, icons, opencode-cli, web-dist, app-update.yml, app.asar, elevate.exe] |

## Conclusión

Chamber está empaquetado en ASAR.
El runtime.js NO se puede modificar directamente (no hay source plano).
