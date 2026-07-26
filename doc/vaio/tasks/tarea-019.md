# Tarea 019 — Unificar Chamber en puerto 57123

> **Tarea de consolidación.** Elimina la doble instancia de Chamber en VAIO.
> Fuente (port 57124) debe reemplazar Electron (port 57123).

## Objetivo

| # | Acción |
|---|---|
| 1 | Detener Electron EXE (OpenChamber*) |
| 2 | Detener source en 57124 |
| 3 | Iniciar source en 57123 |
| 4 | Recrear check-tareas + publish-url en 57123 |
| 5 | Fijar sessionId |
| 6 | Actualizar cloudflared para apuntar a 57123 |
| 7 | Verificar + reportar |

---

## Paso 1 — Detener Electron EXE

```powershell
# Detener todas las instancias de OpenChamber.exe (Electron viejo)
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Verificar
$remaining = Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue
if ($remaining) { "ERROR: Electron sigue corriendo" } else { "Electron DETENIDO" }
```

---

## Paso 2 — Detener source en 57124

```powershell
# Buscar proceso node en 57124
$portProc = netstat -ano | Select-String ":57124.*LISTENING"
if ($portProc) {
    $pid = ($portProc -split '\s+')[-1]
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    "Source en 57124 detenido"
} else {
    "57124 ya libre"
}
```

---

## Paso 3 — Iniciar source en 57123

```powershell
cd C:\Users\USUARIO\openchamber

# Verificar puerto 57123 libre
$portCheck = netstat -ano | Select-String ":57123.*LISTENING"
if ($portCheck) { "ERROR: 57123 ocupado" } else { "57123 libre" }

# Iniciar
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57123"
Start-Sleep -Seconds 15

# Verificar
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status
if ($LASTEXITCODE -eq 0) { "Chamber source en 57123 OK" } else { "ERROR" }
```

---

## Paso 4 — Recrear scheduled tasks en 57123

```powershell
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# Función para crear task
function New-VAIO-Task($name, $cron, $prompt) {
    $body = @{task=@{name=$name;enabled=$true;schedule=@{kind="cron";cron=$cron;timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-$name.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-$name.json" | Out-Null
    Write-Host "Creada: $name"
}

# 1. check-tareas
New-VAIO-Task "VAIO: check-tareas" "* * * * *" "Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado en doc/vaio/results/`n4. git add + commit -m 'VAIO: resultado tarea NNN' + push`n5. DONE"

# 2. publish-url
New-VAIO-Task "VAIO: publish-url" "0 * * * *" "Usá la API de Chamber para obtener la URL del túnel.`n1. curl.exe -s http://localhost:57123/api/openchamber/tunnel/status`n2. Extraé el campo 'url' del JSON`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"
```

---

## Paso 5 — Fijar sessionId

```powershell
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# Esperar que check-tareas ejecute una vez
Start-Sleep -Seconds 65

# Capturar sessionId
$tasks = curl.exe -s $api | ConvertFrom-Json
$checkTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$sessionId = $checkTask.state.lastSessionId
Write-Host "SessionId: $sessionId"

# Fijar en ambas tasks
foreach ($t in $tasks.tasks) {
    $body = @{task=@{name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt;sessionId=$sessionId}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-fix-$($t.id).json" | Out-Null
}
Write-Host "sessionId fijado"
```

---

## Paso 6 — Actualizar cloudflared

```powershell
# Detener cloudflared actual (apuntaba a 57123 del Electron)
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Iniciar cloudflared apuntando al Chamber unificado
Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57123 --no-autoupdate"
Start-Sleep -Seconds 5

# Verificar
$cloudProc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if ($cloudProc) { "cloudflared OK — PID $($cloudProc.Id)" } else { "ERROR: cloudflared no arrancó" }
```

---

## Paso 7 — Verificar y reportar

```powershell
# Verificación rápida
$chamberStatus = curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | ConvertFrom-Json
$tasksStatus = curl.exe -s http://localhost:57123/api/openchamber/scheduled-tasks/status | ConvertFrom-Json

$ok = @"
# Resultado 019 — Chamber unificado en 57123

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Electron EXE detenido | SI/NO |
| Source en 57123 | SI/NO |
| check-tareas activa | $($tasksStatus.hasEnabledScheduledTasks) |
| publish-url activa | $($tasksStatus.hasEnabledScheduledTasks) |
| sessionId fijado | SI/NO |
| cloudflared apuntando a 57123 | SI/NO |
| Tunnel activo | $($chamberStatus.active) |

## Unificación completada

Una sola instancia de Chamber (source, v1.16.3) en puerto 57123.
Solo 2 tasks: check-tareas (1 min) + publish-url (1 hora).
cloudflared-watchdog deprecado definitivamente.
Electron EXE no se usa más — reemplazado por node desde source.
"@
Set-Content -Path "doc\vaio\results\resultado-019.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-019.md
git commit -m "VAIO: resultado tarea 019 — Chamber unificado en 57123"
git pull --rebase
git push
```
