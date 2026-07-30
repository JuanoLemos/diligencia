# Resultado 048 — Diagnostico y reparacion de canales

**Fecha:** 2026-07-30 04:53 UTC
**Hostname:** FELRENA

## Estado de componentes

| Componente | Estado |
|---|---|
| opencode serve :4096 | ONLINE — healthy, v1.18.3 |
| opencode version | 1.18.3 |
| VS Code tunnel | Activo (3 procesos) |
| Chamber | Activo (:57125, 2 tasks) |
| Tunnel Chamber | watchdog activo (ultima: merchandise-twins-bold-reports) |
| Tailscale IP VAIO | no disponible en PC |

## Log de errores

(sin errores — ambos canales respondieron)

## Para conectar desde PC (MAIN)

```powershell
$env:DILIGENCIA_SERVER = "http://localhost:4096"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
cd C:\xampp\htdocs\Diligencia

# Probar conexion:
curl.exe -s http://localhost:4096/global/health -u diligencia:diligencia-vaio-2026

# Dashboard:
.\scripts\watch-server.ps1
```
