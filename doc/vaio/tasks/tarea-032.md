# Tarea 032 — Automatización definitiva VAIO

> **Última tarea.** Corrige 3 bugs simultáneos que impiden la automatización.
> Prompt destruido + EPERM + doble Chamber. Todo en un solo paso.

## Paso 1 — Restaurar prompt real (NO "DONE")

```powershell
$realPrompt = "Ejecutá secuencialmente sin interpretar. Si falla, reportá el error exacto.`n1. cd C:\xampp\htdocs\Diligencia && git pull --rebase`n2. Buscá tareas sin resultado en doc/vaio/tasks/`n3. Si hay: leé la tarea, ejecutá los comandos exactamente como están, escribí resultado`n4. git add doc/vaio/results/ && git commit -m 'VAIO: check-tareas' && git push"

$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

# Eliminar duplicados
$seen = @{}
foreach ($t in $tasks | Sort-Object {if($_.state.createdAt){$_.state.createdAt}else{0}}) {
    if ($seen.ContainsKey($t.name)) { curl.exe -s -X DELETE "$api/$($t.id)" | Out-Null; Write-Host "dup eliminado: $($t.name)" }
    else { $seen[$t.name] = $t }
}

# Volver a capturar
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

# Fijar sessionId + prompt real para check-tareas
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$sid = $ct.state.lastSessionId

$body = @{task=@{id=$ct.id;name=$ct.name;enabled=$true;schedule=$ct.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$realPrompt}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\ct-fix.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\ct-fix.json" | Out-Null
"check-tareas: prompt RESTAURADO + sessionId=$sid"

# publish-url
$pu = $tasks | Where-Object {$_.name -eq "VAIO: publish-url"}
$puPrompt = "Leé la URL del túnel desde cloudflared.`n1. Get-Content -Raw `$env:TEMP\cloudflared-url.log`n2. Extraé la URL con regex`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit -m 'VAIO: URL cloudflared VAIO' + push`n5. DONE"
$body = @{task=@{id=$pu.id;name=$pu.name;enabled=$true;schedule=$pu.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$puPrompt}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\pu-fix.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\pu-fix.json" | Out-Null
"publish-url: prompt restaurado"
```

## Paso 2 — Fix EPERM en project-config.js

```powershell
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"
$c = Get-Content $pc -Raw

# Reemplazar write-temp→rename por writeFile directo
$c = $c -replace 'await fsPromises\.writeFile\(tmpPath, data,? .utf.8.\);\s+await fsPromises\.rename\(tmpPath, destPath\);', 'await fsPromises.writeFile(destPath, data, "utf-8");'
# Fallback: si el patrón exacto no matchea, buscar variante
if ($c -notmatch 'await fsPromises\.writeFile\(destPath') {
    # Buscar las líneas del rename y reemplazar
    $c = $c -replace "await fsPromises\.writeFile\(tmpPath, data\);", 'await fsPromises.writeFile(destPath, data);'
    $c = $c -replace "`n\s+await fsPromises\.rename\(tmpPath, destPath\);", ''
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($pc, $c, $utf8)
Write-Host "EPERM fix aplicado (writeFile directo + sin BOM)"
```

## Paso 3 — Unificar puertos (source en 57123)

```powershell
# Matar Electron EXE
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Matar source actual en 57124
$proc = netstat -ano | Select-String ":57124.*LISTENING"
if ($proc) {
    $pid = ($proc -split '\s+')[-1]
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}

# Iniciar source en 57123
cd C:\Users\USUARIO\openchamber
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57123"
Start-Sleep -Seconds 15
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | Out-Null
if ($LASTEXITCODE -eq 0) { Write-Host "Chamber unificado en :57123" } else { Write-Host "ERROR: no responde" }

# Actualizar cloudflared para que apunte a 57123
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Where-Object {$_.SI -ne 0} | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57123 --no-autoupdate" -RedirectStandardError "$env:TEMP\cloudflared-url.log"
Start-Sleep -Seconds 12
Write-Host "cloudflared reiniciado → :57123"
```

## Paso 4 — Recrear tasks en puerto unificado (prompt REAL + sessionId)

```powershell
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

$realPrompt = "Ejecutá secuencialmente sin interpretar. Si falla, reportá el error exacto.`n1. cd C:\xampp\htdocs\Diligencia && git pull --rebase`n2. Buscá tareas sin resultado en doc/vaio/tasks/`n3. Si hay: leé la tarea, ejecutá los comandos exactamente como están, escribí resultado`n4. git add doc/vaio/results/ && git commit -m 'VAIO: check-tareas' && git push"

# Crear check-tareas
$body = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$realPrompt}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\new-check.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\new-check.json" | Out-Null
"check-tareas creada"

# Crear publish-url
$puPrompt = "Leé la URL del túnel desde cloudflared.`n1. Get-Content -Raw `$env:TEMP\cloudflared-url.log`n2. Extraé la URL con regex`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit -m 'VAIO: URL cloudflared VAIO' + push`n5. DONE"
$body = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$puPrompt}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\new-publish.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\new-publish.json" | Out-Null
"publish-url creada"

# Crear deadman-switch (heartbeat cada 5 min)
$body = @{task=@{name="VAIO: heartbeat";enabled=$true;schedule=@{kind="cron";cron="*/5 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Escribí la fecha UTC actual en doc/vaio/heartbeat.md. git add + commit + push. Respondé OK."}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\new-heartbeat.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\new-heartbeat.json" | Out-Null
"heartbeat creada"

# Esperar y fijar sessionId
Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$newSid = $ct.state.lastSessionId
"SessionId: $newSid"

# Fijar sessionId en las 3 tasks SIN tocar el prompt
foreach ($t in $tasks) {
    $existingPrompt = $t.execution.prompt  # PRESERVAR prompt real
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$newSid;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$existingPrompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
}
"sessionId fijado en todas las tasks (prompt PRESERVADO)"
```

## Paso 5 — Verificar

```powershell
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$stable = $ct.state.lastSessionId -eq $newSid
$tasks | Select-Object name, enabled, @{n="promptLen";e={$_.execution.prompt.Length}}, @{n="sid";e={$_.state.lastSessionId}} | Format-Table
Write-Host "$(if($stable){'ESTABLE'}else{'REVISAR'}) - $($ct.state.lastDurationMs)ms"
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 032 — Automatización definitiva

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado final

| Check | Resultado |
|---|---|
| Prompt restaurado (NO "DONE") | SI/NO |
| EPERM fix (writeFile directo) | SI/NO |
| Puertos unificados (solo :57123) | SI/NO |
| 3 tasks: check-tareas + publish-url + heartbeat | SI/NO |
| sessionId fijado sin tocar prompt | SI/NO |
| check-tareas estable | $(if($stable){'SI'}else{'NO'}) |

## Arquitectura final

- 1 solo Chamber (source, v1.16.3, puerto 57123)
- 3 tasks con sessionId fijo y prompt completo
- heartbeat cada 5 min (deadman-switch)
- cloudflared tunnel → 57123
"@
Set-Content -Path "doc\vaio\results\resultado-032.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-032.md
git commit -m "VAIO: resultado tarea 032 — automatizacion definitiva"
git pull --rebase
git push
```
