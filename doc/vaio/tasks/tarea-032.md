# Tarea 032 — Restaurar prompts en VAIO (solo eso)

> **Simple.** No tocar sessionId, EPERM ni puertos. Solo restaurar los prompts reales.

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

# Eliminar duplicados (quedarse con 1 de cada nombre)
$seen = @{}
foreach ($t in $tasks | Sort-Object {if($t.state.createdAt){$t.state.createdAt}else{0}}) {
    if ($seen.ContainsKey($t.name)) { curl.exe -s -X DELETE "$api/$($t.id)" | Out-Null; "dup: $($t.name)" }
    else { $seen[$t.name] = $t }
}

$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

# Restaurar prompt REAL en cada task (preservar todo lo demas)
$realPrompt = "Ejecutá secuencialmente sin interpretar.`n1. cd C:\xampp\htdocs\Diligencia && git pull --rebase`n2. Buscá tareas en doc/vaio/tasks/ sin resultado`n3. Si hay: leé la tarea, ejecutá comandos, escribí resultado`n4. git add doc/vaio/results/ && git commit -m 'VAIO: resultado' && git push"

$puPrompt = "Leé URL de cloudflared.`n1. Get-Content `$env:TEMP\cloudflared-url.log`n2. Extraé https://*.trycloudflare.com`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit + push"

foreach ($t in $tasks) {
    $p = if ($t.name -eq "VAIO: publish-url") {$puPrompt} else {$realPrompt}
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$p}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
    "Restaurado: $($t.name) — prompt=$($p.Length)chars"
}

# Verificar
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$tasks | Select-Object name, @{n="promptChars";e={$_.execution.prompt.Length}}, enabled
```
