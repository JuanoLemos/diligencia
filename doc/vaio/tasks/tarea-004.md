# Tarea 004 — Diagnosticar conectividad Chamber + cloudflared

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.

## Objetivo

La URL de trycloudflare no carga Chamber desde ninguna máquina. Diagnosticar por qué.

---

## Paso 1 — ¿cloudflared sigue corriendo?

```powershell
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
```

Si no aparece: el túnel se cayó. Reactivarlo en Paso 5.

---

## Paso 2 — ¿Chamber sigue escuchando?

```powershell
netstat -ano | findstr 57123
```

Debe mostrar `LISTENING`. Si no: Chamber se cerró. Reiniciarlo:
```powershell
Start-Process -FilePath "C:\Users\USUARIO\AppData\Local\Programs\@openchamberelectron\OpenChamber.exe"
Start-Sleep -Seconds 5
netstat -ano | findstr 57123
```

---

## Paso 3 — ¿Chamber responde HTTP?

```powershell
curl -v http://localhost:57123 2>&1
```

**Analizar el output:**
- Si ves `HTTP/1.1 200 OK` o `HTTP/1.1 302` → Chamber es HTTP ✅
- Si ves `Connection: Upgrade` o `Sec-WebSocket` → Chamber usa WebSocket ⚠️
- Si ves `Empty reply from server` o `Connection refused` → Chamber no responde HTTP ❌
- Si curl se queda colgado → probablemente es WebSocket o IPC, no HTTP

También probar con HTTPS por si Chamber fuerza SSL:
```powershell
curl -k -v https://localhost:57123 2>&1
```

---

## Paso 4 — Inspeccionar qué está sirviendo Chamber

### 4a — Obtener headers sin cuerpo
```powershell
curl -I http://localhost:57123 2>&1
```

### 4b — Ver si hay un index.html o ruta raíz
```powershell
curl -s http://localhost:57123 2>&1 | Select-Object -First 20
```

### 4c — Buscar el puerto real de Chamber en logs/config
```powershell
Get-Process -Name "OpenChamber" | Select-Object Id, ProcessName, Path
```

Si Chamber es una app Electron, puede que tenga un parámetro de línea de comandos con el puerto:
```powershell
Get-WmiObject Win32_Process -Filter "name = 'OpenChamber.exe'" | Select-Object CommandLine
```

---

## Paso 5 — Reactivar cloudflared

Independientemente del resultado del Paso 3, reactivar el túnel para tener una URL fresca:

```powershell
cloudflared tunnel --url http://localhost:57123
```

**Anotar la nueva URL** de trycloudflare.

Si Chamber resultó NO ser HTTP (Paso 3), probar con HTTPS:
```powershell
cloudflared tunnel --url https://localhost:57123
```

O con el protocolo correcto que se descubrió en los pasos anteriores.

---

## Paso 6 — Probar desde el navegador local

En la VAIO, abrir un navegador y probar:
```
http://localhost:57123
```

Si esto SÍ funciona localmente pero NO vía trycloudflare, el problema es el túnel. Si NO funciona ni localmente, Chamber no está sirviendo contenido web.

---

## Escribir resultado

Crear `doc/vaio/results/resultado-004.md`:

```
# Resultado 004

**Fecha:** [fecha/hora UTC]

## Resumen

cloudflared corriendo: [SI/NO]
Chamber escuchando en :57123: [SI/NO — LISTENING o NO]
Chamber responde HTTP: [SI/NO — código HTTP o error]
Chamber carga en navegador local: [SI/NO]
Nueva URL trycloudflare: [URL o NO]

## Diagnóstico completo

### Paso 1 — cloudflared
[output de Get-Process]

### Paso 2 — Chamber netstat
[output de netstat]

### Paso 3 — HTTP test
[output completo de curl -v http://localhost:57123]
[output completo de curl -k -v https://localhost:57123 si se probó]

### Paso 4 — Inspección
[headers de curl -I]
[primeras 20 líneas de curl -s si hay respuesta]
[CommandLine de OpenChamber.exe]

### Paso 5 — cloudflared reactivado
[URL nueva o mensaje de error]

### Paso 6 — Navegador local
[¿Carga? ¿Qué se ve?]

## Conclusión
[¿Chamber es HTTP o no? ¿Qué falta para que funcione?]
```

---

## Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 004"
git pull --rebase
git push
```
