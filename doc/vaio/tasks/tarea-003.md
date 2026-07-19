# Tarea 003 — Resolver DNS + Activar cloudflared (resolución automática)

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.
>
> **⚠️ IMPORTANTE:** PowerShell como ADMINISTRADOR para todos los pasos.

## Objetivo

Que `cloudflared tunnel --url http://localhost:57123` funcione y devuelva una URL de trycloudflare.com.

El DNS ya está configurado (`1.1.1.1`, `8.8.8.8`) pero cloudflared sigue sin resolver `api.trycloudflare.com`. Se probarán múltiples soluciones en cascada.

---

## Procedimiento en cascada

Ejecutar los pasos en orden. Si un paso resuelve el problema, SALTAR los siguientes.
Si falla, pasar al siguiente paso inmediatamente.

---

### Paso A — Limpiar caché DNS

```powershell
ipconfig /flushdns
```

Verificar:
```powershell
nslookup api.trycloudflare.com
```

Luego:
```powershell
cloudflared tunnel --url http://localhost:57123
```

**Si funciona →** anotar URL, ir a "Escribir resultado". Si falla → Paso B.

---

### Paso B — Resetear y reasignar DNS

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Verificar que solo queden IPv4:
```powershell
Get-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -AddressFamily IPv4
```

Probar cloudflared:
```powershell
cloudflared tunnel --url http://localhost:57123
```

**Si funciona →** anotar URL, ir a "Escribir resultado". Si falla → Paso C.

---

### Paso C — Reiniciar adaptador de red

```powershell
Restart-NetAdapter -Name "Wi-Fi"
```

Esperar 15 segundos. Luego verificar conexión:
```powershell
nslookup google.com
```

Probar cloudflared:
```powershell
cloudflared tunnel --url http://localhost:57123
```

**Si funciona →** anotar URL, ir a "Escribir resultado". Si falla → Paso D.

---

### Paso D — Forzar resolver nativo de Go + deshabilitar IPv6

cloudflared usa Go para resolver DNS. Forzar el resolver puro de Go bypassando el del sistema:

```powershell
$env:GODEBUG = "netdns=go"
cloudflared tunnel --url http://localhost:57123
```

Si falla, probar deshabilitando IPv6 en el adaptador:
```powershell
Disable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6
ipconfig /flushdns
cloudflared tunnel --url http://localhost:57123
```

**Si funciona →** anotar URL, RE-HABILITAR IPv6, ir a "Escribir resultado". Si falla → Paso E.

```powershell
# Re-habilitar IPv6 (ejecutar solo si el paso anterior funcionó)
Enable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6
```

---

### Paso E — Alternativa: usar netsh en vez de PowerShell

```powershell
netsh interface ip delete dnsservers name="Wi-Fi" all
netsh interface ip set dns name="Wi-Fi" source=static addr=1.1.1.1
netsh interface ip add dns name="Wi-Fi" addr=8.8.8.8 index=2
ipconfig /flushdns
```

Verificar:
```powershell
nslookup api.trycloudflare.com
```

Probar cloudflared:
```powershell
cloudflared tunnel --url http://localhost:57123
```

**Si funciona →** anotar URL, ir a "Escribir resultado". Si falla → Paso F.

---

### Paso F — Reiniciar la VAIO

```powershell
Restart-Computer -Force
```

Al volver del reinicio:
1. Abrir PowerShell como Administrador
2. Verificar DNS: `nslookup api.trycloudflare.com`
3. Si resuelve: `cloudflared tunnel --url http://localhost:57123`
4. Si no resuelve: ejecutar Paso B y reintentar

---

## Escribir resultado

Crear `doc/vaio/results/resultado-003.md` con este formato:

```
# Resultado 003

**Fecha:** [fecha/hora UTC]

## Resumen

DNS reparado: [SI/NO]
cloudflared funcionando: [SI/NO]
URL trycloudflare: [pegar URL o "NO"]
Paso que funcionó: [A/B/C/D/E/F o "NINGUNO"]

## Detalle por paso

### Paso A — flushdns
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]

### Paso B — reset DNS
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]

### Paso C — reiniciar adaptador
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]

### Paso D — GODEBUG/IPv6
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]

### Paso E — netsh
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]

### Paso F — reinicio
Resultado: [FUNCIONO/FALLO]
Error: [si falló, pegar mensaje]
```

Si ningún paso funcionó, incluir output completo de:
```powershell
ipconfig /all | Select-String -Pattern "DNS|Wi-Fi|Adapter"
```

---

## Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 003"
git pull --rebase
git push
```

**IMPORTANTE:** Si tuviste que reiniciar (Paso F), asegurate de commitear y pushear ANTES de reiniciar el resultado parcial. Luego, después del reinicio, actualizá el resultado y volvé a commitear + pushear.
