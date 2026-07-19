# Resultado 003

**Fecha:** 2026-07-19 01:28 UTC

---

## Resumen

| Campo | Valor |
|---|---|
| DNS reparado | **SI** ✅ |
| cloudflared funcionando | **SI** ✅ |
| URL trycloudflare | `https://ambien-voltage-editors-currently.trycloudflare.com` |
| Paso que funcionó | **B** (reset + reasignar DNS IPv4 + IPv6) |
| Puerto Chamber | `57123` |

---

## Detalle por paso

### Paso A — flushdns
**Resultado:** FALLO
- `ipconfig /flushdns` se ejecutó sin error, pero nslookup seguía usando `dev.opt` y no resolvía `api.trycloudflare.com`.
- No era problema de caché, era el servidor DNS mismo.

### Paso D (anticipado) — GODEBUG=netdns=go
**Resultado:** FALLO
- Cloudflared intentó resolver vía `fe80::1:53` (dev.opt IPv6) y falló.
- Go respeta la configuración DNS del sistema, GODEBUG=netdns=go no bypassa el resolver del SO.

### Paso B — Reset + reasignar DNS ✅
**Resultado:** FUNCIONÓ

**Problema real:** El DNS IPv6 estaba en `fe80::1` (dev.opt). Aunque IPv4 se configuró con Cloudflare, Windows prefirió resolver vía IPv6 y siguió fallando.

**Solución aplicada (2 intentos):**

1. **Intento 1:** Solo IPv4 (`1.1.1.1`, `8.8.8.8`) → FALLO (IPv6 `fe80::1` seguía teniendo prioridad)
2. **Intento 2:** IPv4 + IPv6 Cloudflare → **FUNCIONÓ**

Comando final:
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2606:4700:4700::1001")
```

**DNS final:**
| Familia | Servidores |
|---------|------------|
| IPv4 | `1.1.1.1`, `8.8.8.8` |
| IPv6 | `2606:4700:4700::1111`, `2606:4700:4700::1001` |

### Cloudflared — túnel establecido

```
2026-07-19T01:27:55Z INF |  Your quick Tunnel has been created! Visit it at:
                         |  https://ambien-voltage-editors-currently.trycloudflare.com
```

**Connectivity pre-checks (todos PASS):**
| Componente | Target | Status |
|---|---|---|
| DNS Resolution | region1.v2.argotunnel.com | PASS |
| DNS Resolution | region2.v2.argotunnel.com | PASS |
| UDP Connectivity | region1.v2.argotunnel.com | PASS |
| UDP Connectivity | region2.v2.argotunnel.com | PASS |
| TCP Connectivity | region1.v2.argotunnel.com | PASS |
| TCP Connectivity | region2.v2.argotunnel.com | PASS |
| Cloudflare API | api.cloudflare.com:443 | PASS |

- Protocolo: QUIC
- Connector ID: `4cafcc96-eee0-45a5-9e1c-1a2b0f657bff`
- Location: `eze04` (Buenos Aires)

---

## ⚠️ Nota importante

El túnel **NO es persistente**. cloudflared se cierra al terminar el proceso. Para mantenerlo 24/7, se necesita:

1. Instalarlo como servicio de Windows: `cloudflared service install`
2. O usar un tunnel con nombre (requiere cuenta Cloudflare + `cloudflared tunnel create`)
3. O dejarlo corriendo en una ventana de terminal abierta

El objetivo inmediato de la tarea (activar el túnel y capturar la URL) está cumplido. La persistencia requeriría otro paso.
