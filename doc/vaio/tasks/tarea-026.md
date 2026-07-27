# Tarea 026 — Verificar Chamber VAIO + reactivar circuito

> **Prioridad alta.** Verificar que Chamber source está corriendo, que las scheduled tasks existen, y retomar la comunicación.

## Paso 1 — Verificar Chamber source (57124)

```powershell
Write-Host "=== Chamber source en 57124 ==="
$r = curl.exe -s http://localhost:57124/api/openchamber/tunnel/status 2>$null
if ($r) {
    "Chamber source RESPONDE en 57124"
    ($r | ConvertFrom-Json | Select-Object active, url, mode | Format-List | Out-String).Trim()
} else {
    "Chamber source NO RESPONDE en 57124 — hay que iniciarlo"
    
    # Buscar repo
    $repo = Get-ChildItem -Path "C:\Users" -Filter "package.json" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Where-Object {$_.DirectoryName -like "*openchamber*" -and $_.DirectoryName -notlike "*OneDrive*"} | Select-Object -First 1
    if ($repo) {
        Write-Host "Repo: $($repo.DirectoryName)"
        cd $repo.DirectoryName
        Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
        Start-Sleep -Seconds 15
        curl.exe -s http://localhost:57124/api/openchamber/tunnel/status 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { "Source REACTIVADO en 57124" }
    }
}
```

## Paso 2 — Verificar scheduled tasks

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
Write-Host "Tasks en 57124: $($tasks.Count)"

if ($tasks.Count -eq 0) {
    Write-Host "SIN TASKS — recreando..."
    
    # check-tareas
    $body = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\t026-check.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\t026-check.json" | Out-Null
    
    # publish-url
    $body = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Leé la URL del túnel desde cloudflared.`n1. Get-Content -Raw `$env:TEMP\cloudflared-url.log`n2. Extraé URL`n3. Escribí en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\t026-publish.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\t026-publish.json" | Out-Null
    
    "Tasks recreadas"
} else {
    $tasks | Select-Object name, enabled | Format-Table
}
```

## Paso 3 — Fijar sessionId

```powershell
# Esperar que check-tareas ejecute una vez
Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$sid = $ct.state.lastSessionId

if ($sid) {
    foreach ($t in $tasks) {
        $fix = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-flash";prompt="DONE"}}} | ConvertTo-Json -Depth 10
        $fix | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
        curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
    }
    "sessionId fijado: $sid"
}
```

## Paso 4 — Procesar tareas pendientes del repo

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
$pending = Get-ChildItem "doc\vaio\tasks\tarea-*.md" | Where-Object {
    $num = $_.BaseName -replace 'tarea-',''
    -not (Test-Path "doc\vaio\results\resultado-$num.md")
}
if ($pending) {
    Write-Host "Tareas pendientes: $($pending.Count)"
    foreach ($p in $pending | Sort-Object Name) {
        Write-Host "Ejecutando: $($p.Name)"
        # Leer y ejecutar comandos de la tarea
    }
} else {
    Write-Host "Sin tareas pendientes"
}
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 026 — Verificación VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Chamber source 57124 | SI/NO |
| Tasks activas | [N] |
| sessionId fijado | SI/NO |
| Tareas pendientes ejecutadas | [N] |

## Circuito reactivado

$(if($sid){"check-tareas corriendo cada 1 min. Comunicación MAIN↔VAIO restaurada."}else{"⚠️ Revisar"})
"@
Set-Content -Path "doc\vaio\results\resultado-026.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-026.md
git commit -m "VAIO: resultado tarea 026 — verificacion y reactivacion"
git pull --rebase
git push
```
