# Tarea 014 — check-tareas reutiliza sesión única

> Ejecutar en la VAIO. Modifica runtime.js de Chamber (requiere reinicio de Chamber).

## Objetivo

1. Modificar `runtime.js` de Chamber para que acepte `sessionId` en el execution config
2. Actualizar la scheduled task `check-tareas` para usar la sesión `ses_08860b1f7ffeGQftllZ2pt6OL0`
3. Reiniciar Chamber

---

## Paso 1 — Modificar runtime.js de Chamber

El `runtime.js` actual crea una sesión nueva en cada ejecución. Hay que agregar soporte para `sessionId`.

Abrir:
```
C:\Users\USUARIO\AppData\Local\Programs\@openchamberelectron\resources\packages\web\server\lib\scheduled-tasks\runtime.js
```

Buscar:
```javascript
    const sessionResponse = await client.session.create({
```

Reemplazar desde esa línea hasta `}` que cierra el bloque, por:

```javascript
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
```

---

## Paso 2 — Actualizar la tarea check-tareas con sessionId

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

## Paso 3 — Reiniciar Chamber

```powershell
# Matar procesos OpenChamber
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force

# Esperar y verificar que no está
Start-Sleep -Seconds 3
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue

# Iniciar Chamber
Start-Process -FilePath "C:\Users\USUARIO\AppData\Local\Programs\@openchamberelectron\OpenChamber.exe"
```

---

## Paso 4 — Verificar

```powershell
Start-Sleep -Seconds 10
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | ConvertTo-Json -Depth 5
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
| runtime.js modificado | SI — soporte para sessionId |
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

