# Tarea 017 — Ola A: Recuperar Chamber desde source (Node.js)

> **Tarea CRÍTICA.** Instala Node.js, npm install, aplica fix 2 archivos, inicia Chamber desde source.
> La PC Principal ya tiene estos cambios. Esta tarea sincroniza la VAIO.

## Objetivo

| Paso | Acción |
|---|---|
| 1 | Instalar Node.js 22 LTS |
| 2 | `npm install` en el openchamber clonado |
| 3 | Aplicar fix de `sessionId` en 2 archivos |
| 4 | Iniciar Chamber desde source con Node.js |
| 5 | Verificar scheduled tasks |

---

## Paso 1 — Instalar Node.js 22 LTS

```powershell
# Verificar si ya está instalado
$nodeVer = node --version 2>$null
if ($nodeVer) { "Node.js ya instalado: $nodeVer" } else {
    "Instalando Node.js 22 LTS..."
    winget install OpenJS.NodeJS.LTS --accept-package-agreements 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Fallback: descarga manual
        $url = "https://nodejs.org/dist/v22.0.0/node-v22.0.0-x64.msi"
        Invoke-WebRequest -Uri $url -OutFile "$env:TEMP\node-install.msi"
        Start-Process msiexec -ArgumentList "/i $env:TEMP\node-install.msi /qn" -Wait
    }
}
node --version
npm --version
```

---

## Paso 2 — Instalar dependencias del openchamber

```powershell
cd C:\Users\USUARIO\openchamber
npm install 2>&1

# Si falla por dependencias nativas:
if ($LASTEXITCODE -ne 0) {
    "Fallback: npm install --ignore-scripts + rebuild"
    npm install --ignore-scripts 2>&1 | Out-Null
    npm rebuild 2>&1 | Out-Null
}
"npm install completado"
```

---

## Paso 3 — Aplicar fix de sessionId (2 archivos)

```powershell
# runtime.js — soporte para sessionId
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$c = Get-Content $rt -Raw
$c = $c -replace 'const sessionResponse = await client.session.create', 'let sessionID;
    const reuseSessionId = task.execution?.sessionId;
    if (reuseSessionId) { sessionID = reuseSessionId; } else {
      const sessionResponse = await client.session.create'
$c = $c -replace 'const sessionID = sessionResponse\?\.data\?\.id;', 'const sessionID = sessionResponse?.data?.id;
    }'
Set-Content $rt $c -Encoding UTF8
"runtime.js OK"

# project-config.js — persistir sessionId
$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"
$c = Get-Content $pc -Raw
$c = $c -replace 'const variant = asNonEmptyString\(value\.variant\);', 'const variant = asNonEmptyString(value.variant);
    const sessionId = value.sessionId || null;'
$c = $c -replace '\.\.\.\(variant \? \{ variant \} : \{\}\)', '...(variant ? { variant } : {}),
      ...(sessionId ? { sessionId } : {})'
Set-Content $pc $c -Encoding UTF8
"project-config.js OK"

"AMBOS FIXES APLICADOS"
```

---

## Paso 4 — Iniciar Chamber desde source

Detener Chamber instalado e iniciar desde source:

```powershell
cd C:\Users\USUARIO\openchamber

Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Iniciar con Node.js (no Bun)
Start-Process -WindowStyle Hidden -FilePath "node.exe" -ArgumentList "packages/web/bin/cli.js serve --port 57123"
Start-Sleep -Seconds 15
```

Verificar que arrancó:
```powershell
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | ConvertFrom-Json
if ($LASTEXITCODE -eq 0) { "Chamber corriendo desde source OK" } else { "ERROR: Chamber no responde" }
```

---

## Paso 5 — Actualizar scheduled task con sessionId

```powershell
$update = @'
{
  "task": {
    "name": "VAIO: check-tareas",
    "enabled": true,
    "schedule": { "kind": "cron", "cron": "* * * * *", "timezone": "UTC" },
    "execution": {
      "sessionId": "ses_08860b1f7ffeGQftllZ2pt6OL0",
      "providerID": "deepseek",
      "modelID": "deepseek-v4-flash",
      "prompt": "Actuá como el VAIO Worker de Diligencia.\n\n1. git pull\n2. Revisá doc/vaio/tasks/ para tareas sin resultado\n3. Si hay tarea: ejecutala, escribí resultado\n4. git add + commit + push\n5. DONE"
    }
  }
}
'@
$update | Out-File -FilePath "$env:TEMP\vaio-check-session.json" -Encoding UTF8
curl.exe -s -X PUT http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks -H "Content-Type: application/json" -d "@$env:TEMP\vaio-check-session.json"
```

---

## Escribir resultado

```powershell
$ok = @"
# Resultado 017 — Ola A completada en VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Paso | Resultado |
|---|---|
| Node.js instalado | SI/NO |
| npm install | SI/NO |
| runtime.js fix | SI/NO |
| project-config.js fix | SI/NO |
| Chamber desde source | SI/NO |
| sessionId en check-tareas | SI/NO |

## Chamber corriendo desde

C:\Users\USUARIO\openchamber
node packages/web/bin/cli.js serve --port 57123
"@
Set-Content -Path "doc\vaio\results\resultado-017.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-017.md
git commit -m "VAIO: resultado tarea 017 — Ola A completada"
git pull --rebase
git push
```
