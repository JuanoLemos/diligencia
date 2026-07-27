# Tarea 029 — Re-aplicar fix de sessionId en Chamber source VAIO

> El fix se perdió al reclonar Chamber. Sin él, las scheduled tasks ignoran execution.sessionId y crean sesiones nuevas cada ciclo.

## Paso 1 — Verificar que los fixes faltan

```powershell
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"

if (Select-String -Path $rt -Pattern "reuseSessionId" -SimpleMatch) { "runtime.js: YA TIENE fix" } else { "runtime.js: FALTA fix" }
if (Select-String -Path $pc -Pattern "const sessionId = value.sessionId" -SimpleMatch) { "project-config.js: YA TIENE fix" } else { "project-config.js: FALTA fix" }
```

## Paso 2 — Aplicar fix a runtime.js

```powershell
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$c = Get-Content $rt -Raw

if ($c -notmatch 'reuseSessionId') {
    $c = $c -replace 'const sessionResponse = await client\.session\.create\(\{', 'let sessionID;
    const reuseSessionId = task.execution?.sessionId;
    if (reuseSessionId) {
      sessionID = reuseSessionId;
    } else {
      const sessionResponse = await client.session.create({'
    $c = $c -replace 'const sessionID = sessionResponse\?\.data\?\.id;', '      sessionID = sessionResponse?.data?.id;
    }'
    Set-Content $rt $c -Encoding UTF8
    Write-Host "runtime.js PARCHADO"
} else { Write-Host "runtime.js ya tiene fix" }
```

## Paso 3 — Aplicar fix a project-config.js

```powershell
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"
$c = Get-Content $pc -Raw

if ($c -notmatch 'const sessionId = value\.sessionId') {
    $c = $c -replace 'const variant = asNonEmptyString\(value\.variant\);', 'const variant = asNonEmptyString(value.variant);
    const sessionId = value.sessionId || null;'
    $c = $c -replace '\.\.\.\(variant \? \{ variant \} : \{\}\)', '...(variant ? { variant } : {}),
      ...(sessionId ? { sessionId } : {})'
    Set-Content $pc $c -Encoding UTF8
    Write-Host "project-config.js PARCHADO"
} else { Write-Host "project-config.js ya tiene fix" }
```

## Paso 4 — Reiniciar Chamber source

```powershell
$proc = netstat -ano | Select-String ":57124.*LISTENING"
if ($proc) {
    $pid = ($proc -split '\s+')[-1]
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Write-Host "Chamber source detenido"
}

cd C:\Users\USUARIO\openchamber
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
Start-Sleep -Seconds 15
curl.exe -s http://localhost:57124/api/openchamber/tunnel/status | Out-Null
if ($LASTEXITCODE -eq 0) { Write-Host "Chamber source REACTIVADO" }
```

## Paso 5 — Arreglar sesiones (mismo proceso que tarea-028)

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# Quitar sessionId viejo
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Actuá como el VAIO Worker.`n1. git pull`n2. Revisá doc/vaio/tasks/`n3. Ejecutá tareas sin resultado`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\clean2-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\clean2-$($t.id).json" | Out-Null
}
Write-Host "sessionIds removidos — esperando ciclo"

Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$newSid = $ct.state.lastSessionId
Write-Host "Nueva sesion: $newSid"

# Fijar
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$newSid;providerID="deepseek";modelID="deepseek-v4-flash";prompt="DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix2-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix2-$($t.id).json" | Out-Null
}
Write-Host "sessionId fijado: $newSid"

# Verificar
Start-Sleep -Seconds 65
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
if ($ct.state.lastSessionId -eq $newSid) { Write-Host "ESTABLE - $($ct.state.lastDurationMs)ms" } else { Write-Host "REVISAR - sessionId diferente" }
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 029 — Fix de sessionId re-aplicado

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| runtime.js fix aplicado | SI/NO |
| project-config.js fix aplicado | SI/NO |
| Chamber source reiniciado | SI/NO |
| sessionId fijado | $newSid |
| Estable | $(if($ct.state.lastSessionId -eq $newSid){"SI - $($ct.state.lastDurationMs)ms"}else{"NO"}) |
"@
Set-Content -Path "doc\vaio\results\resultado-029.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-029.md
git commit -m "VAIO: resultado tarea 029 — fix sessionId re-aplicado"
git pull --rebase
git push
```
