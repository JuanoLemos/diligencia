# GUIA_VAIO_DNS — Reparar DNS para tuneles v1.0

> ⚠️ DEPRECADO — Reemplazado por `GUIA_CONTROL_REMOTO.md` (sección DNS Troubleshooting)

> Para ejecutar en la VAIO. Arregla el DNS para que cloudflared y los tuneles funcionen.
> No toca ningun otro programa. Solo cambia la configuracion de DNS.

---

## Paso 1 — PowerShell como Administrador

Click derecho en el boton Inicio -> "Windows PowerShell (Administrador)"
o "Terminal (Administrador)".

---

## Paso 2 — Ver interfaces de red activas

```powershell
Get-NetAdapter | Where-Object Status -eq "Up"
```

Anotar el nombre en la columna **Name**. Normalmente es "WiFi", "Wi-Fi", o "Ethernet".

---

## Paso 3 — Cambiar DNS

Reemplazar `<NOMBRE>` por el nombre que anotaste:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "<NOMBRE>" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Ejemplo real:
```powershell
Set-DnsClientServerAddress -InterfaceAlias "WiFi" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

---

## Paso 4 — Verificar que funciona

```powershell
nslookup google.com
```

Debe devolver una direccion IP (ej: 142.250.x.x).

Si dice "Non-existent domain" o "No such host", avisar.

---

## Paso 5 — Probar cloudflared

```powershell
cloudflared tunnel --url http://localhost:3000
```

Debe mostrar una URL de `trycloudflare.com`. Anotarla.

---

## Paso 6 — En la PC principal

Abrir en el navegador la URL de trycloudflare.com. Debe mostrar Chamber.

---

## Troubleshooting

| Problema | Solucion |
|---|---|
| "cloudflared: command not found" | Cerrar PowerShell y abrir uno nuevo. Reintentar. |
| "No such host" despues de cambiar DNS | Reiniciar el adaptador: `Restart-NetAdapter -Name "<NOMBRE>"` |
| Chamber no carga en el navegador | Esperar 30 segundos. Si no funciona, verificar que Chamber.exe este corriendo en la VAIO. |

## Archivos relacionados
- `GUIA_CONTROL_REMOTO.md` — guia completa de control remoto
- `GUIA_RED_LOCAL.md` — SSH y VS Code Remote en red local
