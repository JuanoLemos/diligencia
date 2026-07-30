# Tarea 048 — Diagnóstico y reparación de canales

> **Prioridad:** P1 — CRITICO
> `opencode serve` no responde desde PC. VS Code tunnel cayó.
> Chamber activo en VAIO. Necesitamos restaurar ambos canales.

---

## Fase A — Sincronizar

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
Write-Host "Repo actualizado"
```

## Fase B — Diagnosticar opencode serve

```powershell
Write-Host "=== Diagnostico opencode serve ==="

$openProc = Get-Process opencode -ErrorAction SilentlyContinue
if ($openProc) {
    Write-Host "opencode PID: $($openProc.Id)"
    Write-Host "Tiempo: $((Get-Date) - $($openProc.StartTime))"
} else {
    Write-Host "opencode: CAIDO (sin proceso)"
}

# Puerto 4096?
$portInfo = netstat -ano | findstr ":4096"
if ($portInfo) {
    Write-Host "Puerto 4096 ocupado:"
    Write-Host $portInfo
} else {
    Write-Host "Puerto 4096: libre"
}

# Logs de error
$logPath = "$env:TEMP\opencode-server-stderr.log"
if (Test-Path $logPath) {
    Write-Host "=== ULTIMAS 20 LINEAS DEL LOG DE ERROR ==="
    Get-Content $logPath -Tail 20 -ErrorAction SilentlyContinue
} else {
    Write-Host "Log de errores: no existe"
}

# Intentar health check local
try {
    $health = curl.exe -s http://localhost:4096/global/health
    Write-Host "Health local: $health"
    $serveOk = $true
} catch {
    Write-Host "Health local: NO RESPONDE"
    $serveOk = $false
}
```

## Fase C — Relanzar opencode serve

```powershell
Write-Host "=== Relanzando opencode serve ==="

# Matar procesos previos
Get-Process opencode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Puerto libre?
$portFree = -not (netstat -ano | findstr ":4096")
if (-not $portFree) {
    Write-Host "Puerto 4096 sigue ocupado. Esperando 5 segundos..."
    Start-Sleep -Seconds 5
}

$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
[Environment]::SetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", $env:OPENCODE_SERVER_PASSWORD, "User")

.\doc\vaio\scripts\start-opencode-server.ps1 -Port 4096 -Lan -Kill -Password "diligencia-vaio-2026"
Start-Sleep -Seconds 5

try {
    $health = curl.exe -s http://localhost:4096/global/health
    Write-Host "Post-relanzamiento: $health"
    $serveOk = $true
} catch {
    Write-Host "Post-relanzamiento: NO RESPONDE"
    $serveOk = $false
}
```

## Fase D — Reparar VS Code tunnel

```powershell
Write-Host "=== VS Code tunnel ==="

Get-Process -Name "code*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

try {
    $result = code tunnel --name vaioserver --accept-server-license-terms 2>&1
    Write-Host "Resultado: $result"
    Start-Sleep -Seconds 3
    $vscOk = (Get-Process -Name "code*" -ErrorAction SilentlyContinue) -ne $null
    if ($vscOk) {
        Write-Host "VS Code tunnel: ACTIVO"
    } else {
        Write-Host "VS Code tunnel: proceso no detectado despues del intento"
    }
} catch {
    Write-Host "VS Code CLI: NO DISPONIBLE"
    Write-Host "Error: $_"
    $vscOk = $false
}
```

## Fase E — Info de conexión

```powershell
Write-Host "=== Info de conexion ==="

$tailscaleIp = try { (tailscale ip -4 2>$null).Trim() } catch { "no-disponible" }
Write-Host "Tailscale IP: $tailscaleIp"

$chamberPort = try {
    (Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Select-Object -First 1).Id
    $ports = netstat -ano | findstr "LISTENING" | findstr "5712"
    if ($ports) { "57125" } else { "57123" }
} catch { "desconocido" }
Write-Host "Chamber en puerto: $chamberPort"

$tunnelUrl = try {
    (curl.exe -s "http://localhost:$chamberPort/api/openchamber/tunnel/status" | ConvertFrom-Json).url
} catch { "no-disponible" }
Write-Host "Tunnel URL: $tunnelUrl"
```

## Fase F — Escribir resultado

```powershell
$opencodeVer = try { (opencode --version 2>$null).Trim() } catch { "desconocido" }

$resultado = @"
# Resultado 048 — Diagnostico y reparacion de canales

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

## Estado de componentes

| Componente | Estado |
|---|---|
| opencode serve :4096 | $(if ($serveOk) { 'ONLINE' } else { 'CAIDO' }) |
| opencode version | $opencodeVer |
| VS Code tunnel | $(if ($vscOk) { 'Activo' } else { 'Caido' }) |
| Chamber | Activo (:$chamberPort) |
| Tunnel Chamber | $tunnelUrl |
| Tailscale IP VAIO | $tailscaleIp |

## Log de errores (si existe)

$(if ($serveOk -eq $false) { "opencode serve no responde. Ver logs manualmente." } else { "(sin errores)" })

## Para conectar desde PC (MAIN)

\`\`\`powershell
`$env:DILIGENCIA_SERVER = "http://$tailscaleIp`:4096"
`$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
cd C:\xampp\htdocs\Diligencia

# Probar conexion:
curl.exe -s http://$tailscaleIp`:4096/global/health -u diligencia:diligencia-vaio-2026

# Dashboard:
.\scripts\watch-server.ps1
\`\`\`
"@

Set-Content -Path "doc\vaio\results\resultado-048.md" -Value $resultado -Encoding UTF8
Write-Host "Resultado escrito"
```

## Fase G — Commit + push

```powershell
git add -A
git commit -m "VAIO: resultado tarea 048 — diagnostico y reparacion canales"
git pull --rebase
git push
Write-Host "DONE — tarea 048 completada"
```
