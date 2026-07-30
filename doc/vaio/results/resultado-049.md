# Resultado 049 — Diagnostico de red completo + Servicios como Scheduled Task

**Fecha:** 2026-07-30
**Hostname:** Felrena

## Diagnostico final

| Componente | Estado | Detalle |
|---|---|---|
| opencode serve :4096 | ONLINE v1.18.3 | `0.0.0.0:4096` LISTENING, PID 11436 |
| Health check localhost | 200 OK | `{"healthy":true}` |
| Health check Tailscale | 200 OK | `http://100.120.192.43:4096/global/health` |
| Firewall 4096 | Creado | `opencode serve 4096 (Tailscale)` dir=in TCP |
| Tailscale IP | 100.120.192.43 | Hostname: felrena |
| VS Code tunnel | Activo | `vaioserver` con 2 procesos code-tunnel |

## Solucion implementada

**Causa raiz de los 401 previos:** `OPENCODE_SERVER_USERNAME` no estaba en el entorno del proceso que lanzaba `opencode serve`. Al setear ambas variables (`USERNAME` + `PASSWORD`) en el scope del proceso, la auth funciona correctamente.

**Servicios como Scheduled Task:** Creada `Diligencia-VAIO-Services` en Windows Task Scheduler:
- Watchdog: `scripts/vaio-services.ps1` — health check cada 30s, auto-restart si algo muere
- Triggers: `At Startup` + `At LogOn`
- Corre con highest privileges, invisible (WindowStyle Hidden)
- Auto-restart: 5 intentos cada 1 minuto si falla
- Log: `%USERPROFILE%\AppData\Local\Temp\opencode\vaio-services.log`

**Instalador:** `scripts/install-services.ps1` — ejecutar UNA SOLA VEZ como Admin para crear la tarea.

## Informacion de conexion para MAIN

```powershell
$env:DILIGENCIA_SERVER = "http://100.120.192.43:4096"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
cd C:\xampp\htdocs\Diligencia

# Probar conexion:
curl.exe -s http://100.120.192.43:4096/global/health -u diligencia:diligencia-vaio-2026

# Dashboard:
.\scripts\watch-server.ps1
```

## Archivos creados

| Archivo | Proposito |
|---|---|
| `scripts/vaio-services.ps1` | Watchdog — mantiene opencode serve + VS Code tunnel vivos |
| `scripts/install-services.ps1` | Instalador — crea la Scheduled Task (ejecutar 1 vez) |
