# Tarea 049 — Diagnóstico de red + firewall + VS Code gateway

> **Prioridad:** P1 — CRITICO
> `opencode serve` responde en localhost (127.0.0.1) pero NO via Tailscale (100.x.x.x).
> VS Code tunnel reporta "gateway not running".
> Necesitamos: firewall, binding 0.0.0.0, y ver porque `tailscale ip -4` no funciona.

---

## Fase A — Sincronizar

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
Write-Host "Repo actualizado"
```

## Fase B — Diagnosticar binding de opencode serve

```powershell
Write-Host "=== Fase B: Binding del puerto 4096 ==="

# ¿En qué IP escucha realmente?
$listeners = netstat -ano | findstr ":4096" | findstr "LISTENING"
Write-Host "Listeners en :4096:"
$listeners | ForEach-Object { Write-Host "  $_" }

# Extraer IP de escucha
$listenIp = if ($listeners -match "(\d+\.\d+\.\d+\.\d+):4096") { $matches[1] } else { "no-encontrado" }
Write-Host "IP de escucha: $listenIp"
Write-Host "Esperado: 0.0.0.0 (si es 127.0.0.1, solo localhost)"
```

## Fase C — Abrir firewall + reiniciar opencode serve

```powershell
Write-Host "=== Fase C: Firewall + reinicio ==="

# Abrir puerto en Windows Firewall
$fwRuleName = "opencode serve 4096 (Tailscale)"
$existingRule = netsh advfirewall firewall show rule name="$fwRuleName" 2>&1
if ($existingRule -match "No rules match") {
    netsh advfirewall firewall add rule name="$fwRuleName" dir=in action=allow protocol=tcp localport=4096
    Write-Host "Regla de firewall creada: $fwRuleName"
} else {
    Write-Host "Regla de firewall ya existe: $fwRuleName"
}

# Matar opencode
Get-Process opencode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Matar cualquier proceso que tenga el puerto 4096
$pidOcupado = netstat -ano | findstr ":4096" | ForEach-Object { $_ -match "(\d+)$" | Out-Null; $matches[1] }
if ($pidOcupado) {
    Write-Host "Matando proceso PID $pidOcupado que retiene :4096..."
    Stop-Process -Id $pidOcupado -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Lanzar opencode serve con hostname 0.0.0.0 explicito
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
$env:OPENCODE_SERVER_USERNAME = "diligencia"
[Environment]::SetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", $env:OPENCODE_SERVER_PASSWORD, "User")

Start-Process -FilePath "opencode" `
    -ArgumentList "serve", "--port", "4096", "--hostname", "0.0.0.0" `
    -NoNewWindow -PassThru `
    -RedirectStandardOutput "$env:TEMP\opencode-server-stdout.log" `
    -RedirectStandardError "$env:TEMP\opencode-server-stderr.log"

Start-Sleep -Seconds 5

# Verificar binding post-reinicio
$listeners2 = netstat -ano | findstr ":4096" | findstr "LISTENING"
Write-Host "Listeners post-reinicio:"
$listeners2 | ForEach-Object { Write-Host "  $_" }

# Health check local
try {
    $health = curl.exe -s http://localhost:4096/global/health
    Write-Host "Health local: $health"
    $serveOk = $true
} catch {
    Write-Host "Health local: NO RESPONDE"
    $serveOk = $false
}
```

## Fase D — Diagnosticar Tailscale

```powershell
Write-Host "=== Fase D: Tailscale ==="

# Tailscale IP
$tsIp = try { (tailscale ip -4 2>$null).Trim() } catch { "" }
Write-Host "Tailscale IP: '$tsIp'"

# Si tailscale ip -4 no funciona, buscar alternativa
if (-not $tsIp) {
    Write-Host "tailscale ip -4 fallo. Buscando alternativas..."
    # Ver si tailscale esta instalado
    $tsExe = Get-Command tailscale -ErrorAction SilentlyContinue
    if (-not $tsExe) {
        Write-Host "tailscale: NO INSTALADO O NO EN PATH"
    } else {
        Write-Host "tailscale: instalado en $($tsExe.Source)"
        # Intentar status
        $tsStatus = tailscale status 2>&1
        Write-Host "tailscale status:"
        Write-Host $tsStatus
        # Extraer IP local
        $tsStatus -match "(\d+\.\d+\.\d+\.\d+)\s+felrena" | Out-Null
        if ($matches[1]) { $tsIp = $matches[1] }
    }
}

# Self-test via Tailscale
if ($tsIp) {
    Write-Host "Haciendo self-test via Tailscale $tsIp`:4096 ..."
    try {
        $tsTest = curl.exe -s "http://${tsIp}:4096/global/health" -u diligencia:diligencia-vaio-2026 -m 5
        Write-Host "Self-test Tailscale: $tsTest"
        $tsOk = $true
    } catch {
        Write-Host "Self-test Tailscale: FALLO"
        Write-Host "Error: $_"
        $tsOk = $false
    }
} else {
    $tsOk = $false
}
```

## Fase E — Reparar VS Code tunnel (kill + restart limpio)

```powershell
Write-Host "=== Fase E: VS Code tunnel ==="

# Matar TODO proceso code
Get-Process -Name "code*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "Code*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Verificar que no quede ninguno
$remaining = Get-Process -Name "code*" -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host "Aun hay $($remaining.Count) procesos code. Forzando kill con taskkill..."
    taskkill /f /im code.exe 2>$null
    taskkill /f /im Code.exe 2>$null
    Start-Sleep -Seconds 2
}

# Verificar si code CLI esta disponible
$codeCli = Get-Command code -ErrorAction SilentlyContinue
if ($codeCli) {
    Write-Host "code CLI disponible en $($codeCli.Source)"
    # Iniciar tunnel en background
    Start-Process -FilePath "code" -ArgumentList "tunnel", "--name", "vaioserver", "--accept-server-license-terms" -NoNewWindow
    Start-Sleep -Seconds 5
    $vscOk = (Get-Process -Name "code*" -ErrorAction SilentlyContinue) -ne $null
    if ($vscOk) {
        Write-Host "VS Code tunnel: INICIADO"
    } else {
        Write-Host "VS Code tunnel: proceso no detectado"
    }
} else {
    Write-Host "code CLI: NO DISPONIBLE"
    Write-Host "VS Code debe estar instalado con 'code' en PATH. Verificar: Get-Command code"
    $vscOk = $false
}
```

## Fase F — Escribir resultado con info de red completa

```powershell
$opencodeVer = try { (opencode --version 2>$null).Trim() } catch { "desconocido" }
$chamberPort = "57125"

$resultado = @"
# Resultado 049 — Diagnostico de red completo

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

## Binding de puertos

netstat :4096:
$($listeners2 -join "`n")

## Estado de componentes

| Componente | Estado |
|---|---|
| opencode serve :4096 | $(if ($serveOk) { "ONLINE v$opencodeVer" } else { "CAIDO" }) |
| Binding IP | $listenIp |
| Firewall 4096 | Creado/Verificado |
| Self-test Tailscale | $(if ($tsOk) { "OK" } else { "FALLO" }) |
| Tailscale IP | $(if ($tsIp) { $tsIp } else { "NO DISPONIBLE" }) |
| VS Code tunnel | $(if ($vscOk) { "Activo" } else { "Caido" }) |
| Chamber | Activo (:$chamberPort) |

## Informacion de conexion para MAIN

\`\`\`powershell
# Usar IP directa de Tailscale:
`$env:DILIGENCIA_SERVER = "http://$(if ($tsIp) { $tsIp } else { 'PREGUNTAR_IP' })":4096"
`$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
cd C:\xampp\htdocs\Diligencia

# Probar conexion:
curl.exe -s http://$(if ($tsIp) { $tsIp } else { 'IP' })":4096/global/health -u diligencia:diligencia-vaio-2026

# Dashboard:
.\scripts\watch-server.ps1
\`\`\`

## Log de errores

$(if ($serveOk -eq $false) { "opencode serve no responde. Contenido de log:"; try { Get-Content "$env:TEMP\opencode-server-stderr.log" -Tail 20 -ErrorAction SilentlyContinue | Out-String } catch { "" } } else { "(sin errores)" })
"@

Set-Content -Path "doc\vaio\results\resultado-049.md" -Value $resultado -Encoding UTF8
Write-Host "Resultado escrito"
```

## Fase G — Commit + push

```powershell
git add -A
git commit -m "VAIO: resultado tarea 049 — diagnostico de red completo"
git pull --rebase
git push
Write-Host "DONE — tarea 049 completada"
```
