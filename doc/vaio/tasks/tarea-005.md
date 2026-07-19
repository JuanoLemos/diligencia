# Tarea 005 — Diagnosticar Error 1033 + instalar cloudflared como servicio

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.
>
> **IMPORTANTE:** Mantener la terminal ABIERTA durante toda la tarea. No cerrar hasta el final.

## Objetivo

Resolver el error 1033 ("Cloudflare Tunnel error") y dejar cloudflared corriendo como servicio 24/7.

---

## Paso 1 — Verificar que cloudflared sigue corriendo

```powershell
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
```

Si NO aparece → el túnel se cayó otra vez. Reactivar:
```powershell
cloudflared tunnel --url http://localhost:57123
```
Anotar la nueva URL y continuar.

Si SÍ aparece → el túnel está vivo pero Chamber no responde. Continuar diagnóstico.

---

## Paso 2 — Verificar Chamber localmente (desde INSIDE la VAIO)

```powershell
curl -v http://localhost:57123 2>&1
```

Debe mostrar `HTTP/1.1 200 OK`. Si da error → Chamber se cayó. Reiniciarlo.

---

## Paso 3 — Probar el túnel desde adentro de la VAIO

Esto imita exactamente lo que hace un navegador externo, pero corre en la VAIO misma:

```powershell
curl -v https://URL_TUNNEL.trycloudflare.com 2>&1
```

Reemplazar `URL_TUNNEL` por la URL actual (ej: `recipients-tattoo-invalid-clicking.trycloudflare.com`).

**Interpretar resultado:**
- `HTTP/2 200` o `HTTP/1.1 200` → funciona ✅
- `HTTP/1.1 502 Bad Gateway` → cloudflared no puede hablar con Chamber
- `curl: (56) Recv failure` + logs de cloudflared muestran error → posible problema de chunked encoding
- `curl: (35) schannel` → problema SSL/TLS

---

## Paso 4 — Si falla: probar sin chunked encoding

Detener cloudflared actual (Ctrl+C en su ventana) y reactivar:

```powershell
cloudflared tunnel --url http://localhost:57123 --no-chunked-encoding
```

Anotar la nueva URL. Probar de nuevo con curl y desde navegador.

---

## Paso 5 — Si falla: verificar Windows Firewall

```powershell
# Ver si cloudflared está bloqueado
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*cloudflare*" -or $_.DisplayName -like "*cloudflared*" }

# Ver reglas que afectan el puerto 57123
Get-NetFirewallRule | Where-Object { $_.LocalPort -eq 57123 }
```

Si no hay reglas, crear una para permitir cloudflared → localhost:
```powershell
New-NetFirewallRule -DisplayName "cloudflared outbound" -Direction Outbound -Program "C:\Program Files (x86)\cloudflared\cloudflared.exe" -Action Allow
```

También verificar que el firewall no esté bloqueando conexiones loopback:
```powershell
# Verificar si el firewall bloquea loopback
netsh advfirewall firewall show rule name=all | Select-String "loopback" -Context 2
```

---

## Paso 6 — Prueba definitiva desde navegador

Abrir navegador en la VAIO y cargar la URL del túnel. Si carga Chamber → el problema era firewall o chunked encoding.

Si todo lo anterior falla, capturar los logs completos de cloudflared mientras se hace un request:
```powershell
# Ejecutar cloudflared en modo verbose
cloudflared tunnel --url http://localhost:57123 --loglevel debug 2>&1 | Tee-Object -FilePath "$env:TEMP\cloudflared-debug.log"
```

Hacer el request desde otra terminal:
```powershell
curl -v https://URL_TUNNEL.trycloudflare.com 2>&1
```

---

## Paso 7 — Instalar cloudflared como servicio

Una vez que el túnel funcione:

```powershell
cloudflared service install
```

Esto instala cloudflared como servicio de Windows que corre automáticamente al iniciar. Verificar:
```powershell
Get-Service cloudflared
```

Debe mostrar `Running`.

**Nota:** El servicio usa una configuración diferente al quick tunnel. Si `service install` no funciona con quick tunnel, crear un tunnel con nombre:

```powershell
cloudflared tunnel login
cloudflared tunnel create vaio-chamber
```

Seguir las instrucciones en pantalla (requiere cuenta Cloudflare gratuita).

---

## Paso 8 — Túnel VS Code como servicio

```powershell
code tunnel service install
```

Verificar:
```powershell
code tunnel status
```

Debe mostrar `service_installed: true`.

---

## Escribir resultado

Crear `doc/vaio/results/resultado-005.md`:

```
# Resultado 005

**Fecha:** [fecha/hora UTC]

## Resumen

Error 1033 resuelto: [SI/NO]
Causa: [explicación]
URL final: [URL funcional]
cloudflared como servicio: [SI/NO]
VS Code tunnel como servicio: [SI/NO]

## Detalle por paso

### Paso 1 — cloudflared vivo
[resultado]

### Paso 2 — Chamber local
[resultado]

### Paso 3 — curl al túnel
[resultado]

### Paso 4 — no-chunked-encoding
[resultado si se probó]

### Paso 5 — Firewall
[resultado]

### Paso 6 — Navegador
[¿carga?]

### Paso 7 — Servicio cloudflared
[resultado]

### Paso 8 — Servicio VS Code tunnel
[resultado]

## Logs de cloudflared (si hubo error)
[pegar logs relevantes]
```

---

## Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 005"
git pull --rebase
git push
```
