# Resultado 039 — Auto-curativo instalado

**Fecha:** 2026-07-28 21:06 UTC

## Estado

| Check | Resultado |
|---|---|
| start-chamber.ps1 verificado | SI |
| Chamber dev server en 57125 | SI |
| check-tareas activa | SI |
| publish-url activa | SI |
| Sesión dedicada | ses_05579046bffegYIWFzWIXqjufo |
| Tunnel URL | https://ferrari-circumstances-experienced-heaven.trycloudflare.com |
| Startup shortcut creado | SI (VAIO-Chamber-PC.lnk) |
| Script fixeado (&& → ;) | SI (PS5.1 compat) |

## Detalle

- Chamber source levantado en puerto 57125 con `OPENCHAMBER_DATA_DIR` aislado del Electron
- cloudflared redirigido a 57125
- Shortcut en `C:\Users\USUARIO\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VAIO-Chamber-PC.lnk`
- Script `start-chamber.ps1` fixeado para PowerShell 5.1 (reemplazados `&&` por `;`)
- Al reiniciar Windows, Chamber + check-tareas + publish-url + tunnel arrancan solos
