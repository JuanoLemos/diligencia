# Resultado 047 — Deploy opencode serve + limpieza

**Fecha:** 2026-07-29
**Hostname:** FELRENA

## Estado de componentes

| Componente | Estado |
|---|---|
| VS Code tunnel | Activo |
| opencode serve :4096 | ONLINE — healthy, version 1.18.3 |
| Chamber :57125 | Activo (2 tasks, check-tareas + publish-url) |
| Tunnel Chamber | cloudflared activo via watchdog |

## Deprecaciones aplicadas

| Archivo/Sistema | Estado |
|---|---|
| doc/vaio/tasks/ | DEPRECADO |
| doc/vaio/results/ | DEPRECADO |
| doc/vaio/heartbeat.md | DEPRECADO |
| doc/vaio/cloudflared-url.md | DEPRECADO |
| doc/vaio/status.md | DEPRECADO |

## Para conectar desde MAIN

```
$env:DILIGENCIA_SERVER = "http://localhost:4096"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"

.\scripts\watch-server.ps1 -Server $env:DILIGENCIA_SERVER -Password $env:OPENCODE_SERVER_PASSWORD
```
