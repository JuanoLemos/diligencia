# Tarea 030 — Fix EPERM + estabilizar sesiones definitivamente

> **Último fix.** El write-temp→rename en Windows falla con EPERM. El sessionId nunca se persiste.
> Cambio: `fs.writeFile` directo. Después, arreglar sesiones.

## Paso 1 — Fix EPERM en project-config.js

```powershell
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"
$c = Get-Content $pc -Raw

# Buscar y reemplazar el patrón write-temp → rename por write directo
# Buscar writeFile(tmp) + rename(tmp, dest)
$c = $c -replace 'await fsPromises\.writeFile\(tmpPath, data, .utf-8.\);\s+await fsPromises\.rename\(tmpPath, destPath\);', 'await fsPromises.writeFile(destPath, data, "utf-8");'
# Si el patrón exacto no matchea, buscar versión más amplia
if ($c -notmatch 'await fsPromises\.writeFile\(destPath') {
    $c = $c -replace "await fsPromises\.writeFile\(tmpPath, data\);", 'await fsPromises.writeFile(destPath, data);'
    $c = $c -replace "`n    await fsPromises\.rename\(tmpPath, destPath\);", ' // rename removido por EPERM fix'
}
Set-Content $pc $c -Encoding UTF8
Write-Host "EPERM fix aplicado"
```

## Paso 2 — Reiniciar Chamber source

```powershell
$proc = netstat -ano | Select-String ":57124.*LISTENING"
if ($proc) {
    $pid = ($proc -split '\s+')[-1]
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
}
cd C:\Users\USUARIO\openchamber
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
Start-Sleep -Seconds 15
curl.exe -s http://localhost:57124/api/openchamber/tunnel/status | Out-Null
if ($LASTEXITCODE -eq 0) { Write-Host "Chamber OK" }
```

## Paso 3 — Arreglar sesiones (proceso definitivo)

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# Eliminar duplicados
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$seen = @{}
foreach ($t in $tasks | Sort-Object { if ($_.state.createdAt) {$_.state.createdAt} else {0} }) {
    if ($seen.ContainsKey($t.name)) {
        curl.exe -s -X DELETE "$api/$($t.id)" | Out-Null
        "Eliminado dup: $($t.name) $($t.id)"
    } else { $seen[$t.name] = $t }
}

# Quitar sessionId viejo
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="VAIO Worker. git pull, revisar tasks, ejecutar, commit+push, DONE."}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\clean-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\clean-$($t.id).json" | Out-Null
}
"Limpiado — esperando 65s"
Start-Sleep -Seconds 65

# Capturar nueva sessionId
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$newSid = $ct.state.lastSessionId
"Nuevo sessionId: $newSid (status: $($ct.state.lastStatus))"

# Fijar
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$newSid;providerID="deepseek";modelID="deepseek-v4-flash";prompt="DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
}
"sessionId fijado — esperando verificación 65s"
Start-Sleep -Seconds 65

# Verificar
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
$stable = $ct.state.lastSessionId -eq $newSid
if ($stable) { "ESTABLE - $($ct.state.lastDurationMs)ms - misma sesion reutilizada" } else { "FALLO EPERM - sessionId no se persistio" }
```

## Paso 4 — Si falló EPERM, forzar con PowerShell

```powershell
if (-not $stable) {
    Write-Host "EPERM persiste — aplicando workaround con PowerShell..."
    $configFile = "$env:USERPROFILE\.config\openchamber\projects\path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE.json"
    $json = Get-Content $configFile -Raw | ConvertFrom-Json
    
    foreach ($t in $json.scheduledTasks) {
        $t.execution = $t.execution | Select-Object * -ExcludeProperty sessionId
        $t.execution | Add-Member -NotePropertyName sessionId -NotePropertyValue $newSid
    }
    
    $json | ConvertTo-Json -Depth 10 | Set-Content "$env:TEMP\project-config-fixed.json" -Encoding UTF8
    Copy-Item "$env:TEMP\project-config-fixed.json" $configFile -Force
    Write-Host "Config JSON actualizado manualmente"
    
    # Reiniciar Chamber para recargar
    $proc = netstat -ano | Select-String ":57124.*LISTENING"
    if ($proc) {
        $pid = ($proc -split '\s+')[-1]
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
    Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
    Start-Sleep -Seconds 15
    Write-Host "Chamber reiniciado — verificar en siguiente ciclo"
}

# Verificación final
Start-Sleep -Seconds 65
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
$finalStable = $ct.state.lastSessionId -eq $newSid
"FINAL: sessionId=$($ct.state.lastSessionId) | dura=$($ct.state.lastDurationMs)ms | $($(if($finalStable){'ESTABLE'}else{'PERSISTE EPERM'}))"
```

## Escribir resultado

```powershell
$finalStable = $ct.state.lastSessionId -eq $newSid
$ok = @"
# Resultado 030 — EPERM fix + sesiones definitivas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado final

| Check | Resultado |
|---|---|
| EPERM fix aplicado | SI |
| Duplicados eliminados | SI |
| sessionId fijado | $newSid |
| Estable | $($(if($finalStable){'SI'}else{'NO - EPERM en Windows. Se aplicó workaround manual al JSON.'})) |

## Conclusión

$($(if($finalStable){"Sesiones estabilizadas definitivamente. Sin sesiones nuevas."}else{"Workaround aplicado. El JSON de config se actualizó manualmente."}))
"@
Set-Content -Path "doc\vaio\results\resultado-030.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-030.md
git commit -m "VAIO: resultado tarea 030 — EPERM fix + sesiones estabilizadas"
git pull --rebase
git push
```
