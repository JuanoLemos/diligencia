# GUIA_CONTROL_REMOTO — Acceso remoto a la VAIO v1.0

> Controlá la VAIO (servidor 24/7) desde cualquier lugar usando dos túneles complementarios.

---

## Arquitectura

La VAIO es una laptop Windows que funciona como servidor 24/7 con:

- Chamber.exe corriendo en `localhost:57123`
- MarketAI en `C:\xampp\htdocs\MarketAI`
- Diligencia clonado en `C:\xampp\htdocs\Diligencia`
- OpenCode v1.18.3 instalado
- VS Code Tunnels y cloudflared configurados

| Túnel | Propósito | Acceso desde |
|---|---|---|
| **VS Code Remote Tunnels** | Editar código, terminal, git, abrir proyectos | VS Code en cualquier PC |
| **Cloudflare Tunnel** | Chamber en el navegador | Cualquier navegador (trycloudflare.com) |

---

## VS Code Remote Tunnels

### Conectarse desde la PC Principal

1. Abrí VS Code en la PC principal
2. En la barra inferior, hacé clic en el ícono de Remote (`> <`)
3. Elegí **"Connect to Tunnel..."**
4. Iniciá sesión con GitHub (si no lo hiciste ya)
5. Seleccioná **"VAIO-Server"** de la lista
6. VS Code se conecta — en la barra inferior dice `Tunnel: VAIO-Server`

Ya conectado:
- `File → Open Folder` → navegá a `C:\xampp\htdocs\` o cualquier proyecto
- Terminal integrada (`Ctrl+Ñ`): corre EN la VAIO
- Podés ejecutar cualquier comando, git, abrir archivos como si estuvieras ahí

### Renombrar el tunnel

Si el tunnel muestra un nombre genérico (ej. "DESKTOP-XXXXX"), renombralo:

```powershell
code tunnel rename VAIO-Server
```

### Verificar nombre actual

```powershell
code tunnel name
```

### Iniciar el tunnel (si no está corriendo)

```powershell
code tunnel
```

Esto inicia el servicio de tunnel en la VAIO. Debe quedar corriendo. Para mantenerlo después de cerrar la terminal, ejecutarlo como servicio:

```powershell
code tunnel service install
```

### Troubleshooting

| Problema | Solución |
|---|---|
| No aparece en la lista de túneles | En la VAIO: `code tunnel` (si no está corriendo, iniciarlo) |
| "Tunnel not found" | Verificar que la VAIO tenga internet y el tunnel esté corriendo |
| No reconoce el comando `code` | VS Code no está en el PATH. Abrí VS Code → `Ctrl+Shift+P` → "Shell Command: Install 'code' command in PATH" |

---

## Cloudflare Tunnel (Chamber remoto)

### Requisitos

- Chamber corriendo en la máquina remota en `localhost:57123`
- DNS funcional (ver Troubleshooting abajo)

### Verificar que Chamber está corriendo

```powershell
netstat -ano | findstr :57123
```

Si no muestra nada, Chamber no está corriendo. Iniciarlo manualmente en la máquina remota.

### Activar el tunnel

Chamber gestiona el túnel nativamente. No se necesita `cloudflared` manual:

```powershell
# Iniciar tunnel quick mode (URL efímera)
curl.exe -s -X POST http://localhost:57123/api/openchamber/tunnel/start `
  -H "Content-Type: application/json" `
  -d '{"provider":"cloudflare","mode":"quick"}'

# Obtener URL activa
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | ConvertFrom-Json | Select-Object url
```

Para URL persistente, usar modo `managed-remote` (requiere cuenta Cloudflare Zero Trust):
```powershell
curl.exe -s -X POST http://localhost:57123/api/openchamber/tunnel/start `
  -H "Content-Type: application/json" `
  -d '{"provider":"cloudflare","mode":"managed-remote"}'
```

### Verificar el tunnel desde afuera

Desde cualquier navegador, abrir la URL que devuelve `GET /api/openchamber/tunnel/status`. Debe mostrar la UI de Chamber.

### Troubleshooting

| Problema | Solución |
|---|---|
| `cloudflared: command not found` | Cerrar y reabrir PowerShell. Si persiste, reinstalar cloudflared. |
| `No such host` o error DNS | DNS roto → ejecutar reparación (sección siguiente) |
| Chamber no carga en el navegador | Verificar que Chamber.exe esté corriendo (`netstat -ano \| findstr :3000`) |
| `ERR_CONNECTION_REFUSED` en el navegador | cloudflared no puede alcanzar Chamber. Verificar puerto 3000. |
| Tunnel se cierra solo | Usar el script de Startup (ver arriba) |

---

## DNS Troubleshooting

Si los túneles fallan con errores de resolución de nombres:

### Paso 1 — Ver interfaces de red activas

```powershell
Get-NetAdapter | Where-Object Status -eq "Up" | Format-Table Name
```

Anotar el nombre en la columna **Name** (normalmente "WiFi", "Wi-Fi", o "Ethernet").

### Paso 2 — Cambiar DNS

Reemplazar `<NOMBRE>` por el nombre anotado:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "<NOMBRE>" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Ejemplo real:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "WiFi" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

### Paso 3 — Verificar

```powershell
nslookup google.com
```

Debe devolver una dirección IP (ej: `142.250.x.x`).

### Paso 4 — Si sigue fallando

```powershell
Restart-NetAdapter -Name "<NOMBRE>"
```

---

## Auto-arranque completo (24/7)

Configuraciones recomendadas para que la VAIO se recupere sola tras un reinicio:

| Componente | Método |
|---|---|
| **VS Code Tunnel** | `code tunnel service install` (se instala como servicio de Windows) |
| **Chamber.exe** | Acceso directo en `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\` |
| **Worker autónomo** | Chamber Scheduled Tasks (nativo) — ver `doc/vaio/VAIO-SCHEDULED.md` |
| **cloudflared** | Chamber gestiona el túnel nativamente — ver sección Cloudflare Tunnel más arriba |

---

## Historial

El sistema de puente via git (`doc/vaio/tasks/`) fue deprecado en favor de los túneles directos. Los archivos originales se conservan en `.old/vaio-puente/`.

---

## Terminal Chamber (reemplazo de vscode.dev)

Chamber tiene un terminal WebSocket integrado. Para comandos rápidos en la VAIO ya no hace falta abrir vscode.dev:

### Desde la UI de Chamber

1. Abrí Chamber en el navegador
2. Buscá el ícono `>_` en la barra inferior o en el panel lateral
3. Hacé clic → se abre el terminal integrado
4. Ejecutá comandos directamente en la máquina remota

### Desde API (uso programático)

```powershell
# Crear sesión terminal
$session = curl.exe -s -X POST http://localhost:57123/api/terminal/create `
  -H "Content-Type: application/json" `
  -d '{"cwd":"C:\\xampp\\htdocs\\Diligencia","shell":"powershell"}' | ConvertFrom-Json

# Conectar WebSocket a ws://localhost:57123/api/terminal/ws
# Enviar bind: {"t":"b","s":"<sessionId>","v":2}
# Enviar comandos como text frames
```

> **Recomendación:** Para uso interactivo, usar la UI de Chamber. Para automatización, usar la API.

---

## Monitoreo SSE

Chamber emite eventos en tiempo real vía Server-Sent Events. Útil para monitorear el worker desde la PC Principal:

```powershell
# Streaming de eventos (probar 5 segundos)
curl.exe -s -N --max-time 5 http://localhost:57123/api/openchamber/events

# Estado consolidado de scheduled tasks
curl.exe -s http://localhost:57123/api/openchamber/scheduled-tasks/status

# Último run de cada tarea
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks
```

Esto reemplaza el `worker-log.md` manual.

---

## URLs activas

> Estas URLs pueden cambiar. La URL del tunnel se obtiene dinámicamente vía `GET /api/openchamber/tunnel/status`.
> El worker VAIO publica la URL actual en `doc/vaio/cloudflared-url.md`.

| Acceso | URL |
|---|---|
| Chamber (Cloudflare Tunnel) | `{{CHAMBER_TUNNEL_URL}}` (obtener vía API) |
| VS Code Remote | `https://vscode.dev/tunnel/vaio-server/` |

---

## Archivos relacionados

- `GUIA_RED_LOCAL.md` — acceso SSH en red local (misma WiFi, no requiere túneles)
- `GUIA_CHAMBER_INSTALABLE.md` — build e instalación de Chamber.exe
- `VAIO-SCHEDULED.md` — sistema de worker autónomo (scheduled tasks)
- `OLA-CHAMBER-100.md` — migración a funcionalidades nativas de Chamber
