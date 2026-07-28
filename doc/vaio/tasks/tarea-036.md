# Tarea 036 — Reactivar check-tareas en VAIO

> Chamber source cambió a :57125. Las tasks estaban en :57124. Hay que recrearlas.

## Paso 1 — Verificar Chamber source

```powershell
$r = curl.exe -s http://localhost:57125/api/openchamber/tunnel/status 2>$null
if ($r) { "Chamber source RESPONDE en 57125" } else { "ERROR: no responde" }
```

## Paso 2 — Verificar tasks en 57125

```powershell
$api = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
"Tasks en 57125: $($tasks.Count)"
$tasks | Select-Object name, enabled
```

## Paso 3 — Si no hay tasks, recrearlas

```powershell
if ($tasks.Count -eq 0) {
    $api = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
    
    # check-tareas
    $prompt = "Ejecutá secuencialmente sin interpretar.`n1. cd C:\xampp\htdocs\Diligencia && git pull --rebase`n2. Buscá tareas en doc/vaio/tasks/ sin resultado`n3. Si hay: leé la tarea, ejecutá los comandos, escribí resultado`n4. git add doc/vaio/results/ && git commit -m 'VAIO: resultado' && git push"
    $body = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\ck-new.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\ck-new.json" | Out-Null
    "check-tareas CREADA"
    
    # publish-url
    $prompt2 = "Leé URL de cloudflared.`n1. Get-Content `$env:TEMP\cloudflared-url.log`n2. Extraé https://*.trycloudflare.com`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit + push"
    $body = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt2}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\pu-new.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\pu-new.json" | Out-Null
    "publish-url CREADA"
}
```

## Paso 4 — Fijar sessionId dedicado

```powershell
$api = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
Start-Sleep -Seconds 65

$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$sid = $ct.state.lastSessionId
"Sesion dedicada: $sid"

if ($sid) {
    foreach ($t in $tasks) {
        $existingPrompt = $t.execution.prompt
        $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-pro";prompt=$existingPrompt}}} | ConvertTo-Json -Depth 10
        $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
        curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
    }
    "sessionId fijado: $sid"
}

# Verificar
Start-Sleep -Seconds 65
$ct = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
if ($ct.state.lastSessionId -eq $sid) { "ESTABLE" } else { "FALLO: sesion diferente" }
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 036 — VAIO reactivada

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Chamber source en 57125 | SI/NO |
| check-tareas activa | SI/NO |
| publish-url activa | SI/NO |
| Session dedicada | $sid |
| Estable | SI/NO |
"@
Set-Content -Path "doc\vaio\results\resultado-036.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-036.md
git commit -m "VAIO: resultado tarea 036 — reactivada"
git pull --rebase
git push
```
