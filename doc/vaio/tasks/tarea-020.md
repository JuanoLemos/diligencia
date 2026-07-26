# Tarea 020 — Ubicar repo Chamber + reactivar source en 57124

> **Usar $env:USERPROFILE, no paths literales.** La tarea 019 falló porque buscó en C:\Users\jlemo pero el repo está en C:\Users\USUARIO.
> Esta tarea encuentra el repo automáticamente y reactiva todo.

## Objetivo

| # | Acción |
|---|---|
| 1 | Buscar el repo openchamber en cualquier carpeta de C:\Users |
| 2 | Si no existe, clonar fresco en $env:USERPROFILE\openchamber |
| 3 | npm install |
| 4 | Iniciar source en 57124 |
| 5 | Recrear check-tareas + publish-url |
| 6 | Fijar sessionId |
| 7 | Redirigir cloudflared → 57124 |
| 8 | Reportar |

---

## Paso 1 — Buscar el repo

```powershell
# Buscar en rutas comunes y en $env:USERPROFILE
$candidates = @(
    "$env:USERPROFILE\openchamber",
    "$env:USERPROFILE\OneDrive\Desktop\openchamber",
    "C:\Users\USUARIO\openchamber",
    "C:\Users\jlemo\openchamber"
)

$repoPath = $null
foreach ($c in $candidates) {
    if (Test-Path "$c\package.json") {
        $repoPath = $c
        Write-Host "ENCONTRADO: $repoPath"
        break
    }
}

# Si no se encuentra, buscar en todo C:\Users (limitado a profundidad 3)
if (-not $repoPath) {
    $found = Get-ChildItem -Path "C:\Users" -Filter "package.json" -Recurse -Depth 4 -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -like "*openchamber*" } | Select-Object -First 1
    if ($found) { $repoPath = $found.DirectoryName; Write-Host "ENCONTRADO (búsqueda): $repoPath" }
}

# Si sigue sin encontrarse, clonar
if (-not $repoPath) {
    Write-Host "No encontrado — clonando..."
    git clone --depth 1 --branch v1.16.3 https://github.com/openchamber/openchamber.git "$env:USERPROFILE\openchamber"
    $repoPath = "$env:USERPROFILE\openchamber"
}

cd $repoPath
"Repo en: $repoPath"
```

---

## Paso 2 — Instalar dependencias

```powershell
cd $repoPath
if (-not (Test-Path "node_modules")) {
    npm install 2>&1 | Select-Object -Last 3
    if ($LASTEXITCODE -ne 0) {
        npm install --ignore-scripts 2>&1 | Out-Null
        npm rebuild 2>&1 | Out-Null
    }
}
"npm install OK"
```

---

## Paso 3 — Iniciar source en 57124

```powershell
cd $repoPath

# Matar cualquier cosa en 57124
$port = netstat -ano | Select-String ":57124.*LISTENING"
if ($port) {
    $oldPid = ($port -split '\s+')[-1]
    Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Iniciar
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57124"
Start-Sleep -Seconds 15

curl.exe -s http://localhost:57124/api/openchamber/tunnel/status 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) { "Chamber source en 57124 OK" } else { "ERROR: Chamber no responde en 57124" }
```

---

## Paso 4 — Recrear scheduled tasks

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

function New-VAIO-Task($name, $cron, $prompt) {
    $body = @{task=@{name=$name;enabled=$true;schedule=@{kind="cron";cron=$cron;timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-$name.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-$name.json" | Out-Null
    Write-Host "Creada: $name"
}

New-VAIO-Task "VAIO: check-tareas" "* * * * *" "Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado en doc/vaio/results/`n4. git add + commit -m 'VAIO: resultado tarea NNN' + push`n5. DONE"

New-VAIO-Task "VAIO: publish-url" "0 * * * *" "Usá la API de Chamber para obtener la URL del túnel.`n1. curl.exe -s http://localhost:57124/api/openchamber/tunnel/status`n2. Extraé el campo 'url' del JSON`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit -m 'VAIO: URL cloudflared' + push`n5. DONE"
```

---

## Paso 5 — Fijar sessionId

```powershell
Start-Sleep -Seconds 65

$tasks = curl.exe -s $api | ConvertFrom-Json
$checkTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$sessionId = $checkTask.state.lastSessionId
Write-Host "SessionId: $sessionId"

if ($sessionId) {
    foreach ($t in $tasks.tasks) {
        $body = @{task=@{name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt;sessionId=$sessionId}}} | ConvertTo-Json -Depth 10
        $body | Set-Content "$env:TEMP\vaio-fix-$($t.id).json" -Encoding UTF8
        curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-fix-$($t.id).json" | Out-Null
    }
    Write-Host "sessionId fijado en todas las tasks"
}
```

---

## Paso 6 — Redirigir cloudflared → 57124

```powershell
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57124 --no-autoupdate"
Start-Sleep -Seconds 10

$cloudProc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if ($cloudProc) { "cloudflared → :57124 OK" } else { "ERROR: cloudflared no arrancó" }
```

---

## Paso 7 — Reportar

```powershell
$ok = @"
# Resultado 020 — Chamber source reactivado

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Repo encontrado | [buscar en logs del paso 1] |
| Chamber source en 57124 | SI/NO |
| check-tareas activa | SI/NO |
| publish-url activa | SI/NO |
| sessionId fijado | SI/NO |
| cloudflared → 57124 | SI/NO |

## Lección

Usar `$env:USERPROFILE` en vez de paths literales (USUARIO, jlemo).
"@
Set-Content -Path "doc\vaio\results\resultado-020.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-020.md
git commit -m "VAIO: resultado tarea 020 — source reactivado"
git pull --rebase
git push
```
