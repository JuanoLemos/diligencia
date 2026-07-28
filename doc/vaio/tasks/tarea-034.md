# Tarea 034 — Crear sesión dedicada de build en VAIO

> **Objetivo:** 1 sesión DEDICADA con permisos de build. No se borra. check-tareas y publish-url la comparten. Igual que en PC Principal.

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

"=== Quitando execSid viejo ==="
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
foreach ($t in $tasks | Where-Object {$_.enabled}) {
    $prompt = $t.execution.prompt
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-clean-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-clean-$($t.id).json" | Out-Null
    "execSid removido: $($t.name)"
}

"Esperando 65s..."
Start-Sleep -Seconds 65

"=== Capturando sesion dedicada ==="
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$dedicatedSid = $ct.state.lastSessionId
"SESION DEDICADA VAIO: $dedicatedSid"

"=== Fijando ==="
foreach ($t in $tasks | Where-Object {$_.enabled}) {
    $prompt = $t.execution.prompt
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$dedicatedSid;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-fix-$($t.id).json" | Out-Null
}

Start-Sleep -Seconds 65
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
if ($ct.state.lastSessionId -eq $dedicatedSid -and $ct.state.lastStatus -eq "success") { "ESTABLE" }
else { "FALLO: status=$($ct.state.lastStatus)" }
```

**IMPORTANTE:** La sesión `$dedicatedSid` es la sesión dedicada de build para VAIO. **NO la borres.** Las tasks la necesitan para funcionar.
