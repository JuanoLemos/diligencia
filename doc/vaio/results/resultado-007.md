# Resultado 007

**Fecha:** 2026-07-22 01:20 UTC

---

## Resumen

| Campo | Valor |
|---|---|
| startup-tunnel.ps1 creado | **SI** ✅ |
| Primera URL capturada | **SI** ✅ |
| cloudflared-url.md | **SI** ✅ (commiteado + pusheado) |
| Scheduled Task | **NO** ⚠️ (UAC denegado — fallback a Startup folder) |
| Startup folder (fallback) | **SI** ✅ |
| Worker loop extendido | **SI** ✅ (watchdog cloudflared + restart auto) |

---

## URL actual

```
https://accuracy-sept-remain-replaced.trycloudflare.com
```

---

## Detalle

### startup-tunnel.ps1
Creado en `doc/vaio/startup-tunnel.ps1`. Funciona correctamente:
1. Git pull
2. Mata cloudflared previo (ignora errores de sesión ajena)
3. Inicia cloudflared con `--no-autoupdate`
4. Captura URL de stderr (cloudflared escribe ahí)
5. Genera `cloudflared-url.md`
6. Commit + push automático
7. Commit `ef88f03` ya en origin: `VAIO: URL cloudflared = https://accuracy-sept-remain-replaced.trycloudflare.com`

### Scheduling
- Scheduled Task con `Register-ScheduledTask` requirió Admin → UAC denegado (sesión headless)
- **Fallback:** `C:\Users\USUARIO\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VAIO-CloudflareTunnel.lnk`
- El script se ejecuta automáticamente al iniciar sesión del usuario

### Worker loop
- `worker-loop.md` extendido con sección **Watchdog cloudflared**
- Cada ciclo del loop verifica si cloudflared está vivo
- Si no → ejecuta `startup-tunnel.ps1` para reiniciar y publicar nueva URL

## Errores
- Scheduled Task no instalada por UAC bloqueado. Startup folder es un reemplazo aceptable para sesión de usuario siempre logueada.
- `Stop-Process` falla para cloudflared de otras sesiones (acceso denegado) — el script lo ignora y sigue.

---

## Archivos creados/modificados

| Archivo | Acción |
|---|---|
| `doc/vaio/startup-tunnel.ps1` | Creado |
| `doc/vaio/cloudflared-url.md` | Creado (actualizable automáticamente) |
| `doc/vaio/worker-loop.md` | Modificado (watchdog) |
| `doc/vaio/results/resultado-007.md` | Este archivo |
