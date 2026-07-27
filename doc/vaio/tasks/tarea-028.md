# Tarea 028 — Corregir sesiones duplicadas en VAIO

> **Urgente.** check-tareas está abriendo sesiones nuevas cada ciclo. Mismo bug que arreglamos en PC Principal.
> Solución: quitar sessionId viejo, esperar, capturar nuevo, fijarlo.

```powershell
cd C:\xampp\htdocs\Diligencia
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# 1. Eliminar duplicados
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$seen = @{}
foreach ($t in $tasks | Sort-Object { $_.state.createdAt }) {
    if ($seen.ContainsKey($t.name)) {
        curl.exe -s -X DELETE "$api/$($t.id)" | Out-Null
        Write-Host "Duplicado eliminado: $($t.name) $($t.id)"
    } else { $seen[$t.name] = $t }
}

# 2. Quitar sessionId viejo de las que quedan
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Actuá como el VAIO Worker.`n1. git pull`n2. Revisá doc/vaio/tasks/`n3. Ejecutá tareas sin resultado`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\clean-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\clean-$($t.id).json" | Out-Null
    Write-Host "sessionId removido: $($t.name)"
}

# 3. Esperar un ciclo
Write-Host "Esperando 65s..."
Start-Sleep -Seconds 65

# 4. Capturar nueva sessionId de check-tareas
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$newSid = $ct.state.lastSessionId
Write-Host "SessionId: $newSid | Status: $($ct.state.lastStatus)"

# 5. Fijar en todas
foreach ($t in $tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$newSid;providerID="deepseek";modelID="deepseek-v4-flash";prompt="DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
}

# 6. Verificar tras otro ciclo
Start-Sleep -Seconds 65
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object { $_.name -eq "VAIO: check-tareas" }
Write-Host "Final: sessionId=$($ct.state.lastSessionId) | dura=$($ct.state.lastDurationMs)ms | status=$($ct.state.lastStatus)"
if ($ct.state.lastSessionId -eq $newSid) { Write-Host "ESTABLE" } else { Write-Host "REVISAR" }
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 028 — Sesiones corregidas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Duplicados eliminados | SI/NO |
| sessionId viejo removido | SI/NO |
| Nueva sesion | $newSid |
| sessionId fijado | SI/NO |
| Estable (misma sesion reutilizada) | SI/NO |
"@
Set-Content -Path "doc\vaio\results\resultado-028.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-028.md
git commit -m "VAIO: resultado tarea 028 — sesiones corregidas"
git pull --rebase
git push
```
