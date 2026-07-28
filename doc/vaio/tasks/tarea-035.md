# Tarea 035 — Usar deepseek-v4-pro en scheduled tasks

> **Cambio:** Las scheduled tasks de VAIO deben usar `modelID: "deepseek-v4-pro"` en vez de `deepseek-v4-flash`.
> El modelo PRO tiene mejor razonamiento para ejecutar tareas de mantenimiento.

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

foreach ($t in $tasks | Where-Object {$_.enabled}) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$t.state.lastSessionId;providerID="deepseek";modelID="deepseek-v4-pro";prompt=$t.execution.prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-pro-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-pro-$($t.id).json" | Out-Null
    Write-Host "$($t.name): → deepseek-v4-pro"
}

$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$tasks | Select-Object name, @{n="model";e={$_.execution.modelID}}
```
