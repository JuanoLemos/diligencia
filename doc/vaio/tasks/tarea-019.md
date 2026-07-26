# Tarea 019 — Activar tasks en Chamber source (puerto 57124)

> **NO matar procesos de Chamber.** El worker corre dentro de Chamber. Matarlo = matarse a sí mismo.
> En vez de unificar puertos, usamos el source (57124) como principal y redirigimos cloudflared.

## Objetivo

| # | Acción |
|---|---|
| 1 | Verificar Chamber source en 57124 |
| 2 | Recrear check-tareas + publish-url en 57124 |
| 3 | Fijar sessionId |
| 4 | Redirigir cloudflared → 57124 |
| 5 | Verificar + reportar |

---

## Paso 1 — Verificar Chamber source en 57124

```powershell
$status = curl.exe -s http://localhost:57124/api/openchamber/tunnel/status 2>$null
if ($status) { "Chamber source en 57124 OK" } else {
    # Si no está corriendo, iniciarlo
    cd C:\Users\USUARIO\openchamber
    Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
    Start-Sleep -Seconds 15
    curl.exe -s http://localhost:57124/api/openchamber/tunnel/status
}
```

---

## Paso 2 — Recrear scheduled tasks en 57124

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

function New-VAIO-Task($name, $cron, $prompt) {
    $body = @{task=@{name=$name;enabled=$true;schedule=@{kind="cron";cron=$cron;timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-$name.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-$name.json" | Out-Null
    Write-Host "Creada: $name"
}

# 1. check-tareas
New-VAIO-Task "VAIO: check-tareas" "* * * * *" "Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado en doc/vaio/results/`n4. git add + commit -m 'VAIO: resultado tarea NNN' + push`n5. DONE"

# 2. publish-url
New-VAIO-Task "VAIO: publish-url" "0 * * * *" "Usá la API de Chamber para obtener la URL del túnel.`n1. curl.exe -s http://localhost:57124/api/openchamber/tunnel/status`n2. Extraé el campo 'url' del JSON`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"
```

---

## Paso 3 — Fijar sessionId

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

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

## Paso 4 — Redirigir cloudflared → 57124

```powershell
# Detener cloudflared actual (apunta al Electron en 57123)
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Iniciar cloudflared apuntando al Chamber source (57124)
Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57124 --no-autoupdate"
Start-Sleep -Seconds 10

# Verificar
$cloudProc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if ($cloudProc) { "cloudflared OK — PID $($cloudProc.Id) — apuntando a :57124" } else { "ERROR: cloudflared no arrancó" }
```

---

## Paso 5 — Verificar y reportar

```powershell
$ok = @"
# Resultado 019 — Tasks activas en Chamber source (:57124)

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Chamber source en 57124 | SI/NO |
| check-tareas activa | SI/NO |
| publish-url activa | SI/NO |
| sessionId fijado | SI/NO |
| cloudflared → 57124 | SI/NO |

## Notas

- Electron EXE (57123) sigue corriendo pero sin tasks. Se apaga cuando estés frente a la VAIO.
- Chamber source (57124) es el principal con las 2 tasks activas.
- cloudflared tunela al source (57124) para que Chamber remoto funcione.
- Para unificar puertos, manualmente: cerrar Electron → iniciar source en 57123 → actualizar cloudflared → 57123.
"@
Set-Content -Path "doc\vaio\results\resultado-019.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-019.md
git commit -m "VAIO: resultado tarea 019 — tasks activas en source :57124"
git pull --rebase
git push
```
