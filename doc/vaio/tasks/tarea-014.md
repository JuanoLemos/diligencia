# Tarea 014 — check-tareas reutiliza sesión única

> Ejecutar en la VAIO. Modifica runtime.js de Chamber vía PowerShell.
> No requiere edición manual.

## Objetivo

1. Modificar `runtime.js` de Chamber por línea de comandos (PowerShell)
2. Actualizar la scheduled task `check-tareas` para usar sesión única
3. Reiniciar Chamber

---

## Paso 1 — Ubicar y modificar runtime.js

```powershell
# Buscar runtime.js en la instalación de Chamber
$paths = @(
    "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\packages\web\server\lib\scheduled-tasks\runtime.js",
    "$env:LOCALAPPDATA\Programs\@openchamberelectron\app\packages\web\server\lib\scheduled-tasks\runtime.js",
    "C:\Program Files\@openchamberelectron\resources\packages\web\server\lib\scheduled-tasks\runtime.js",
    "C:\Program Files (x86)\@openchamberelectron\resources\packages\web\server\lib\scheduled-tasks\runtime.js"
)
$target = $null
foreach ($p in $paths) {
    $exp = [System.Environment]::ExpandEnvironmentVariables($p)
    if (Test-Path $exp) { $target = $exp; break }
}
if (-not $target) {
    # Buscar recursivamente como fallback
    $target = Get-ChildItem -Path "C:\Programs" -Filter "runtime.js" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -like "*scheduled-tasks*" } | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $target) {
    $target = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs" -Filter "runtime.js" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.DirectoryName -like "*scheduled-tasks*" } | Select-Object -First 1 -ExpandProperty FullName
}

Write-Host "PATH: $target"
```

Si no encuentra el archivo, buscarlo:
```powershell
Get-ChildItem -Path "C:\" -Filter "runtime.js" -Recurse -ErrorAction SilentlyContinue -Depth 8 | Where-Object { $_.DirectoryName -like "*scheduled-tasks*" } | Select-Object FullName
```

---

## Paso 2 — Aplicar la modificación

```powershell
$content = Get-Content -Path $target -Raw

# Reemplazar el bloque de creación de sesión con soporte para sessionId
$oldBlock = '    const sessionResponse = await client.session.create\(\{\s+directory: projectPath,\s+title,\s+\}\);'
$oldBlock += '[\s\S]*?    if \(!sessionID\) \{\s+throw new Error\(\'failed to create session\'\);\s+\}'

# Más fácil: reemplazar la línea específica y el bloque que le sigue
$pattern = '    const sessionResponse = await client.session.create\(\{[\s\S]*?\n    \}\);'
$replacement = @'
    let sessionID;
    if (task.execution?.sessionId) {
      sessionID = task.execution.sessionId;
    } else {
      const sessionResponse = await client.session.create({
        directory: projectPath,
        title,
      });
      sessionID = sessionResponse?.data?.id;
      if (!sessionID) {
        throw new Error('failed to create session');
      }
    }
'@

if ($content -match $pattern) {
    $content = $content -replace $pattern, $replacement
    Set-Content -Path $target -Value $content -Encoding UTF8
    Write-Host "MODIFICADO: runtime.js actualizado con soporte para sessionId"
} else {
    # Fallback: reemplazo más simple
    $content = $content -replace 'const sessionResponse = await client.session.create', '// sessionID support
    let sessionID;
    if (task.execution?.sessionId) {
      sessionID = task.execution.sessionId;
    } else {
      const sessionResponse = await client.session.create'
    $content = $content -replace 'const sessionID = sessionResponse\?\.data\?\.id;', 'const sessionID = sessionResponse?.data?.id;
    }'
    Set-Content -Path $target -Value $content -Encoding UTF8
    Write-Host "MODIFICADO (fallback): runtime.js actualizado"
}

# Verificar el cambio
Select-String -Path $target -Pattern "sessionId" | Select-Object -First 5
```

---

## Paso 3 — Actualizar la scheduled task con sessionId

```powershell
$update = @'
{
  "task": {
    "id": "3264cb0e-0000-0000-0000-000000000000",
    "name": "VAIO: check-tareas",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "cron": "* * * * *",
      "timezone": "UTC"
    },
    "execution": {
      "sessionId": "ses_08860b1f7ffeGQftllZ2pt6OL0",
      "providerID": "deepseek",
      "modelID": "deepseek-v4-flash",
      "prompt": "Actuá como el VAIO Worker de Diligencia.\n\n1. Hacé `git pull` en `C:\\xampp\\htdocs\\Diligencia`\n2. Revisá `doc/vaio/tasks/` para tareas sin resultado\n3. Si hay tarea: ejecutala, escribí resultado en `doc/vaio/results/`\n4. `git add + commit -m \"VAIO: resultado tarea NNN\" + push`\n5. Respondé \"DONE\""
    }
  }
}
'@
$update | Out-File -FilePath "$env:TEMP\vaio-check-update.json" -Encoding UTF8

curl.exe -s -X PUT http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks -H "Content-Type: application/json" -d "@$env:TEMP\vaio-check-update.json"
```

---

## Paso 4 — Reiniciar Chamber

```powershell
Write-Host "Reiniciando Chamber..."
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

# Verificar que se detuvo
if (Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue) {
    Write-Host "ERROR: Chamber no se detuvo"
} else {
    Write-Host "Chamber detenido. Se reinicia automáticamente (Startup folder)"
}
```

Si Chamber no se reinicia solo, iniciarlo:
```powershell
$chamber = @(
    "$env:LOCALAPPDATA\Programs\@openchamberelectron\OpenChamber.exe",
    "C:\Program Files\@openchamberelectron\OpenChamber.exe"
)
foreach ($c in $chamber) {
    $exp = [System.Environment]::ExpandEnvironmentVariables($c)
    if (Test-Path $exp) { Start-Process -FilePath $exp; break }
}
Start-Sleep -Seconds 15
```

---

## Paso 5 — Verificar

```powershell
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

Confirmar que `sessionId` aparece en el execution de check-tareas.

---

## Escribir resultado

```powershell
$ok = @"
# Resultado 014 — check-tareas reutiliza sesión única

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Cambios aplicados

| Acción | Estado |
|---|---|
| runtime.js modificado | SI |
| check-tareas actualizada | SI — sessionId agregado |
| Chamber reiniciado | SI |

## Resultado

A partir de ahora, todas las ejecuciones de check-tareas van a la sesión única ses_08860b1f7ffeGQftllZ2pt6OL0.
"@
Set-Content -Path "doc\vaio\results\resultado-014.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-014.md
git commit -m "VAIO: resultado tarea 014 — check-tareas reutiliza sesion unica"
git pull --rebase
git push
```
