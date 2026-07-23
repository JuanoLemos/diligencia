# Resultado 008 (final)

**Fecha:** 2026-07-22 14:20 UTC

---

## Resumen

| Campo | Valor |
|---|---|
| cloudflared vivo | **SI** ✅ — PID 176712 |
| Chamber local | **200** ✅ |
| Túnel desde adentro | **200** ✅ |
| URL funcional desde PC Principal | **SI** ✅ |
| Causa raíz | DNS `dev.opt` (mismo bug que tarea-003) |
| Solución | Cambiar DNS de PC Principal a Cloudflare IPv4 + IPv6 |

---

## Diagnóstico completo

### Fase 1 — Descartado: túnel roto
El túnel siempre estuvo vivo. Chamber respondía 200 local y vía cloudflared desde la VAIO.

### Fase 2 — Descartado: error 1033
Los logs de cloudflared mostraban tráfico externo entrando (`api/git/status`, `api/openchamber/events`). El error eran `stream canceled by remote` de la aplicación, no de red.

### Fase 3 — Confirmado: DNS
`nslookup` en la PC Principal reveló el mismo problema de la VAIO (tarea-003):

| Servidor DNS | Resultado |
|---|---|
| `dev.opt` (default) | `Non-existent domain` ❌ |
| `1.1.1.1` (Cloudflare) | Resuelve correctamente ✅ |

**Causa raíz:** La PC Principal, igual que la VAIO, usa `dev.opt` como DNS primario. Este servidor no resuelve dominios públicos.

### Solución aplicada por MAIN

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2606:4700:4700::1001")
```

**Clave:** Incluir IPv6 (`2606:4700:4700::1111`, `2606:4700:4700::1001`). Si no, `fe80::1` (dev.opt IPv6) sigue teniendo prioridad.

---

## URL funcional actual

```
https://accuracy-sept-remain-replaced.trycloudflare.com
```

---

## Lección aprendida

El error `DNS_PROBE_POSSIBLE` en el navegador se parece a "el sitio no existe", pero en realidad era `dev.opt` bloqueando la resolución. El mismo fix que aplicamos en la VAIO (tarea-003) aplica para cualquier máquina de la red que use `dev.opt`.
