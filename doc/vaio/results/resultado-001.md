# Resultado 001

**Fecha:** 2026-07-18 23:33 UTC

---

## 1. Reparar DNS

- **Interfaz activa:** Wi-Fi (también vEthernet Default Switch, Tailscale)
- **Comando:** `Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8")`
- **Error:** `PermissionDenied` — "El cliente no tenía acceso disponible a un recurso CIM." Se necesita ejecutar como Administrador.
- **DNS actual:** `dev.opt` (no se pudo cambiar)

## 2. Verificar DNS

- **nslookup google.com:** OK — resuelve a `172.217.28.14` y `2800:3f0:4002:817::200e`
- **nslookup api.trycloudflare.com:** FALLA — `*** dev.opt no encuentra api.trycloudflare.com: Non-existent domain`

## 3. Activar cloudflared

- **Ruta:** `C:\Program Files (x86)\cloudflared\cloudflared.exe`
- **cloudflared:** NO
- **URL:** —
- **Error:**
  ```
  failed to request quick Tunnel: Post "https://api.trycloudflare.com/tunnel":
  dial tcp: lookup api.trycloudflare.com: no such host
  ```
- **Causa:** El servidor DNS actual (`dev.opt`) no resuelve `api.trycloudflare.com`. El cambio de DNS a `1.1.1.1` / `8.8.8.8` requiere permisos de Administrador y falló.

## Resumen

| Paso | Resultado |
|------|-----------|
| DNS repair | FALLO (permisos insuficientes) |
| nslookup google.com | OK |
| nslookup api.trycloudflare.com | FALLO |
| cloudflared tunnel | FALLO (DNS) |
