# Tarea 024 — Verificar estado de ambas instancias Chamber en VAIO

> **Diagnóstico.** Hay dos Chamber: Electron (57123, viejo) y Source (57124, nuevo, con tasks).
> Verificar cuál está corriendo y si las tasks existen.

## Paso 1 — Verificar procesos y puertos

```powershell
Write-Host "=== Procesos ==="
Get-Process -Name "OpenChamber*", "node*" -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, @{n="Port";e={}} | Format-Table

Write-Host "=== Puertos ocupados ==="
netstat -ano | Select-String ":57123|:57124" | Select-String "LISTENING"
```

---

## Paso 2 — Verificar tasks en cada puerto

```powershell
Write-Host "=== Tasks en 57123 (Electron) ==="
$t1 = curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks 2>$null
if ($t1) { ($t1 | ConvertFrom-Json).tasks | Select-Object name, enabled, @{n="sessionId";e={$_.execution.sessionId}} | Format-Table } else { "NO RESPONDE" }

Write-Host "=== Tasks en 57124 (Source) ==="
$t2 = curl.exe -s http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks 2>$null
if ($t2) { ($t2 | ConvertFrom-Json).tasks | Select-Object name, enabled, @{n="sessionId";e={$_.execution.sessionId}} | Format-Table } else { "NO RESPONDE" }
```

---

## Paso 3 — Si 57124 no responde, reactivar

```powershell
# Buscar el repo openchamber en C:\Users
$repo = Get-ChildItem -Path "C:\Users" -Filter "package.json" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -like "*openchamber*" -and $_.DirectoryName -notlike "*OneDrive*" } | Select-Object -First 1

if ($repo) {
    Write-Host "Repo encontrado: $($repo.DirectoryName)"
    cd $repo.DirectoryName
    
    # Iniciar source en 57124
    Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
    Start-Sleep -Seconds 15
    
    curl.exe -s http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Host "Source reactivado en 57124" }
} else {
    Write-Host "Repo openchamber NO encontrado"
}
```

---

## Paso 4 — Si no hay tasks en 57124, recrearlas

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$existing = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks

if ($existing.Count -gt 0) {
    Write-Host "Ya hay $($existing.Count) tasks. Sin cambios."
} else {
    Write-Host "Creando tasks..."
    
    # check-tareas
    $body1 = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado en doc/vaio/results/`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body1 | Set-Content "$env:TEMP\vaio-check.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-check.json" | Out-Null

    # publish-url
    $body2 = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt="Leé la URL del túnel desde el archivo de log de cloudflared.`n1. Get-Content -Raw `$env:TEMP\cloudflared-url.log`n2. Extraé la URL con regex: 'https://[a-z-]+\\.trycloudflare\\.com'`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"}}} | ConvertTo-Json -Depth 10
    $body2 | Set-Content "$env:TEMP\vaio-publish.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-publish.json" | Out-Null

    Start-Sleep -Seconds 65
    $tasks = curl.exe -s $api | ConvertFrom-Json
    $sessionId = ($tasks.tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}).state.lastSessionId
    if ($sessionId) {
        foreach ($t in $tasks.tasks) {
            $fix = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$sessionId;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt}}} | ConvertTo-Json -Depth 10
            $fix | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
            curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
        }
        Write-Host "Tasks creadas + sessionId fijado: $sessionId"
    }
}
```

---

## Escribir resultado

```powershell
$ok = @"
# Resultado 024 — Verificación Chamber VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Puertos

| Puerto | Responde | Tasks |
|---|---|---|
| 57123 (Electron) | SI/NO | [N] |
| 57124 (Source) | SI/NO | [N] |

## Acciones

- Source reactivado: SI/NO
- Tasks recreadas: SI/NO
- sessionId fijado: SI/NO
"@
Set-Content -Path "doc\vaio\results\resultado-024.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-024.md
git commit -m "VAIO: resultado tarea 024 — verificacion Chamber"
git pull --rebase
git push
```
