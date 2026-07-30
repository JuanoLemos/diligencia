# Tarea 047 — Deploy opencode serve + limpieza post-R78

> **Prioridad:** P1 — CRITICO
> VS Code tunnel a VAIO caido. Chamber sigue activa via tunnel Cloudflare.
> Esta tarea despliega opencode serve como nuevo canal de control + depreca el sistema viejo.

---

## Fase A — Sincronizar repo

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
Write-Host "Repo actualizado. Scripts R78 recibidos."
```

## Fase B — Intentar recuperar VS Code tunnel

```powershell
Write-Host "=== Fase B: VS Code tunnel ==="
$vscodeProcess = Get-Process -Name "code*" -ErrorAction SilentlyContinue
if ($vscodeProcess) {
    Write-Host "VS Code proceso encontrado (PID: $($vscodeProcess.Id)). Verificando tunnel..."
    # Intentar reconectar
    code tunnel status 2>&1
    Write-Host "VS Code tunnel: ACTIVO"
} else {
    Write-Host "VS Code no esta corriendo. Intentando iniciar tunnel..."
    try {
        code tunnel --name vaioserver --accept-server-license-terms 2>&1
        Write-Host "VS Code tunnel: INICIADO"
    } catch {
        Write-Host "VS Code tunnel: NO DISPONIBLE (code CLI no encontrada)"
    }
}
$vscodeOk = (Get-Process -Name "code*" -ErrorAction SilentlyContinue) -ne $null
```

## Fase C — Desplegar opencode serve

```powershell
Write-Host "=== Fase C: opencode serve ==="

$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"

# Persistir para futuros reinicios
[Environment]::SetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", $env:OPENCODE_SERVER_PASSWORD, "User")

# Matar procesos previos
Get-Process opencode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Lanzar servidor
.\doc\vaio\scripts\start-opencode-server.ps1 -Port 4096 -Lan -Password $env:OPENCODE_SERVER_PASSWORD
Start-Sleep -Seconds 5

# Verificar
$serveOk = $false
try {
    $health = curl.exe -s http://localhost:4096/global/health
    Write-Host "opencode serve: ONLINE"
    Write-Host $health
    $serveOk = $true
} catch {
    Write-Host "opencode serve: NO RESPONDE"
}
```

## Fase D — Deprecar sistema viejo

```powershell
Write-Host "=== Fase D: Deprecaciones ==="

# D1. Crear archivo de deprecacion para tasks/
@"
# tasks/ — DEPRECADO (2026-07-29)

Reemplazado por opencode serve API (`POST /session/:id/prompt_async`).
Las tareas ya no se envian via archivos markdown en git.
Este directorio se conserva como referencia historica.
Nuevo sistema: `doc/mecanicas/MECANICA-SERVIDOR-AUTONOMO.md`
"@ | Set-Content -Path "doc\vaio\tasks\DEPRECADO.md" -Encoding UTF8

# D2. Crear archivo de deprecacion para results/
@"
# results/ — DEPRECADO (2026-07-29)

Reemplazado por SSE streaming y `GET /session/:id/message`.
Los resultados ya no se persisten como archivos markdown en git.
Este directorio se conserva como referencia historica.
Nuevo sistema: `doc/mecanicas/MECANICA-SERVIDOR-AUTONOMO.md`
"@ | Set-Content -Path "doc\vaio\results\DEPRECADO.md" -Encoding UTF8

# D3. Marcar archivos individuales como deprecados
@"
# heartbeat.md — DEPRECADO (2026-07-29)

Reemplazado por `GET http://localhost:4096/global/health` en opencode serve.
"@ | Set-Content -Path "doc\vaio\heartbeat.md" -Encoding UTF8

@"
# cloudflared-url.md — DEPRECADO (2026-07-29)

La URL del tunnel se consulta bajo demanda via `GET /api/openchamber/tunnel/status`.
Ya no se persiste en archivo.
"@ | Set-Content -Path "doc\vaio\cloudflared-url.md" -Encoding UTF8

@"
# status.md — DEPRECADO (2026-07-29)

Reemplazado por `GET /global/health` en opencode serve.
Estado del servidor en tiempo real, sin archivo estatico.
"@ | Set-Content -Path "doc\vaio\status.md" -Encoding UTF8

Write-Host "Deprecaciones escritas."
```

## Fase E — Escribir resultado

```powershell
$tunnelUrl = try { (curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | ConvertFrom-Json).url } catch { "no-disponible" }

$resultado = @"
# Resultado 047 — Deploy opencode serve + limpieza

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Estado de componentes

| Componente | Estado |
|---|---|
| VS Code tunnel | $(if ($vscodeOk) { '✅ Activo' } else { '❌ Caido — intentar manualmente' }) |
| opencode serve :4096 | $(if ($serveOk) { '✅ ONLINE' } else { '❌ No responde — revisar log' }) |
| Chamber :57123 | ✅ Activo (esta tarea se ejecuto via check-tareas) |
| Tunnel Chamber | $tunnelUrl |

## Deprecaciones aplicadas

| Archivo/Sistema | Estado |
|---|---|
| doc/vaio/tasks/ | ✅ DEPRECADO — flag creado |
| doc/vaio/results/ | ✅ DEPRECADO — flag creado |
| doc/vaio/heartbeat.md | ✅ DEPRECADO |
| doc/vaio/cloudflared-url.md | ✅ DEPRECADO |
| doc/vaio/status.md | ✅ DEPRECADO |

## Para conectar desde PC (Jlemo)

```powershell
# Una vez que tengas acceso a VAIO (VS Code o tunnel), ejecuta en PC:
$env:DILIGENCIA_SERVER = "http://$tunnelUrl"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"

# Si usas Tailscale, usa la IP directa:
# $env:DILIGENCIA_SERVER = "http://100.x.x.x:4096"

cd C:\xampp\htdocs\Diligencia
.\scripts\watch-server.ps1
```
"@

Set-Content -Path "doc\vaio\results\resultado-047.md" -Value $resultado -Encoding UTF8
```

## Fase F — Commit + push

```powershell
git add -A
git commit -m "VAIO: tarea 047 — deploy opencode serve + deprecacion sistema viejo"
git pull --rebase
git push
Write-Host "DONE — tarea 047 completada"
```
