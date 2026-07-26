# Tarea 018 — Ola A VAIO: Node.js + Chamber source + Tasks (completa)

> **Tarea CRÍTICA.** Prepara la VAIO con Chamber v1.16.3 desde source.
> Los fixes de sessionId de PC Principal se aplican aquí también.

## Objetivo

| # | Acción |
|---|---|
| 1 | Instalar Node.js 22 LTS |
| 2 | Clonar/actualizar Chamber v1.16.3 desde upstream |
| 3 | npm install (NO Bun — CPU sin AVX2) |
| 4 | Aplicar fix de sessionId en runtime.js + project-config.js |
| 5 | Iniciar Chamber desde source con Node.js |
| 6 | Crear 3 scheduled tasks + fijar sessionId |
| 7 | Deprecar cloudflared-watchdog (Chamber gestiona el túnel) |
| 8 | Reportar resultado |

---

## Paso 1 — Instalar Node.js 22 LTS

```powershell
# Intentar con winget primero
winget install OpenJS.NodeJS.LTS --accept-package-agreements 2>$null
node --version 2>$null
if ($LASTEXITCODE -ne 0) {
    # Fallback: descarga manual
    $url = "https://nodejs.org/dist/v22.0.0/node-v22.0.0-x64.msi"
    Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\node-install.msi"
    Start-Process msiexec -ArgumentList "/i $env:TEMP\node-install.msi /qn" -Wait
}
node --version
npm --version
```

---

## Paso 2 — Clonar Chamber v1.16.3

```powershell
# Si ya existe el repo clonado de tarea-016, solo actualizar
if (Test-Path "C:\Users\USUARIO\openchamber") {
    cd C:\Users\USUARIO\openchamber
    git remote add upstream https://github.com/openchamber/openchamber.git 2>$null
    git fetch upstream
    git checkout v1.16.3 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Si no se puede checkout directo, reset a la tag
        git reset --hard v1.16.3
    }
} else {
    git clone --depth 1 --branch v1.16.3 https://github.com/openchamber/openchamber.git C:\Users\USUARIO\openchamber
}

cd C:\Users\USUARIO\openchamber
$v = (Select-String -Path "package.json" -Pattern '"version"').Line -replace '.*"version": "|".*' -replace ' ',''
"Version clonada: $v"
```

---

## Paso 3 — Instalar dependencias con npm (NO Bun)

```powershell
cd C:\Users\USUARIO\openchamber
npm install 2>&1 | Select-Object -Last 3
if ($LASTEXITCODE -ne 0) {
    "npm install falló — intentando con --ignore-scripts"
    npm install --ignore-scripts 2>&1 | Out-Null
    npm rebuild 2>&1 | Out-Null
}
"npm install completado"
```

---

## Paso 4 — Aplicar fix de sessionId (2 archivos)

```powershell
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"

# runtime.js
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
    "runtime.js PARCHADO"
} else {
    "runtime.js ya tiene el fix"
}

# project-config.js
$c = Get-Content $pc -Raw
if ($c -notmatch 'const sessionId = value\.sessionId') {
    $c = $c -replace 'const variant = asNonEmptyString\(value\.variant\);', 'const variant = asNonEmptyString(value.variant);
    const sessionId = value.sessionId || null;'
    $c = $c -replace '\.\.\.\(variant \? \{ variant \} : \{\}\)', '...(variant ? { variant } : {}),
      ...(sessionId ? { sessionId } : {})'
    Set-Content $pc $c -Encoding UTF8
    "project-config.js PARCHADO"
} else {
    "project-config.js ya tiene el fix"
}
```

---

## Paso 5 — Iniciar Chamber desde source

```powershell
cd C:\Users\USUARIO\openchamber

# Detener Chamber instalado si existe
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Iniciar con Node.js
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57123"
Start-Sleep -Seconds 15

# Verificar
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status
if ($LASTEXITCODE -eq 0) { "Chamber corriendo desde source OK" } else { "ERROR" }
```

---

## Paso 6 — Crear 3 scheduled tasks con sessionId

```powershell
$api = "http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# Función para crear task + capturar sessionId
function New-VAIO-Task($name, $cron, $prompt) {
    $body = @{task=@{name=$name;enabled=$true;schedule=@{kind="cron";cron=$cron;timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-$name.json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-$name.json" | Out-Null
    Write-Host "Creada: $name"
}

# 1. check-tareas
New-VAIO-Task "VAIO: check-tareas" "* * * * *" "Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado en doc/vaio/results/`n4. git add + commit -m 'VAIO: resultado tarea NNN' + push`n5. DONE con resumen"

# 2. publish-url
New-VAIO-Task "VAIO: publish-url" "0 * * * *" "Usá la API de Chamber para obtener la URL del túnel.`n1. curl.exe -s http://localhost:57123/api/openchamber/tunnel/status`n2. Extraé el campo 'url' del JSON`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"

# Esperar que check-tareas ejecute una vez para obtener sessionId
Start-Sleep -Seconds 65

# Leer lastSessionId
$tasks = curl.exe -s $api | ConvertFrom-Json
$checkTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$sessionId = $checkTask.state.lastSessionId
Write-Host "SessionId capturado: $sessionId"

# Fijar sessionId en ambas tasks
foreach ($t in $tasks.tasks) {
    $body = @{task=@{name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt;sessionId=$sessionId}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\vaio-fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\vaio-fix-$($t.id).json" | Out-Null
}
Write-Host "sessionId fijado en todas las tasks"
```

---

## Paso 7 — Verificar y escribir resultado

```powershell
$ok = @"
# Resultado 018 — Ola A VAIO completada

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Paso | Resultado |
|---|---|
| Node.js instalado | SI/NO |
| Chamber v1.16.3 clonado | SI/NO |
| npm install | SI/NO |
| Fix runtime.js | SI/NO |
| Fix project-config.js | SI/NO |
| Chamber corriendo desde source | SI/NO |
| Scheduled tasks creadas | SI/NO |
| SessionId fijado | SI/NO |

## Chamber desde source

C:\Users\USUARIO\openchamber
node packages/web/bin/cli.js serve --port 57123

## Notas

La PC Principal ya tiene OLA-CHAMBER-100 Sesión 1 completada (tunnel quick mode, SSE, skills, docs).
startup-tunnel.ps1 y worker-log.md están deprecados.
cloudflared-watchdog se desactiva (Chamber gestiona el túnel nativamente).
"@
Set-Content -Path "doc\vaio\results\resultado-018.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-018.md
git commit -m "VAIO: resultado tarea 018 — Ola A completada"
git pull --rebase
git push
```
