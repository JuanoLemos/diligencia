# Tarea 012 — Configurar Scheduled Tasks en Chamber (automático)

> **Tarea ÚNICA de configuración.** Crea las 3 tareas programadas en Chamber vía su API REST.
> No requiere abrir la UI de Chamber. No modifica código del proyecto.

## Objetivo

Crear 3 tareas programadas en Chamber vía `curl` a `localhost:57123`:

| Tarea | Frecuencia | Propósito |
|---|---|---|
| VAIO: check-tareas | Cada 1 minuto | Revisar y ejecutar tareas pendientes en doc/vaio/tasks/ |
| VAIO: cloudflared-watchdog | Cada 5 minutos | Verificar cloudflared vivo, reiniciar si caído |
| VAIO: publish-url | Cada 1 hora | Publicar URL de cloudflared en cloudflared-url.md |

---

## Requisitos

- Chamber corriendo en `localhost:57123`
- El proyecto Diligencia ya existe en Chamber (verificado por la presencia del archivo JSON)
- La API no requiere autenticación

---

## Paso 1 — Verificar que Chamber responde

```powershell
curl.exe -s http://localhost:57123/api/openchamber/scheduled-tasks/status
```

Debe devolver un JSON con el estado del scheduler.

---

## Paso 2 — Crear tarea: VAIO: check-tareas

```powershell
# Escribir JSON de la tarea a un archivo temporal
$task1 = @'
{
  "task": {
    "name": "VAIO: check-tareas",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "cron": "* * * * *",
      "timezone": "UTC"
    },
      "execution": {
        "agent": "build",
        "prompt": "Actu\u00e1 como el VAIO Worker de Diligencia.\n\n1. Hac\u00e9 `git pull` en `C:\\xampp\\htdocs\\Diligencia`\n2. Revis\u00e1 `doc/vaio/tasks/` para tareas sin resultado correspondiente\n3. Si hay tarea pendiente: ejecutala, escrib\u00ed resultado en `doc/vaio/results/`\n4. `git add + commit -m \"VAIO: resultado tarea NNN\" + push`\n5. Respond\u00e9 \"DONE\" con resumen de lo ejecutado"
      }
  }
}
'@
$task1 | Out-File -FilePath "$env:TEMP\vaio-check-tareas.json" -Encoding UTF8

# Enviar a la API de Chamber
curl.exe -s -X PUT http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks -H "Content-Type: application/json" -d "@$env:TEMP\vaio-check-tareas.json"
```

---

## Paso 3 — Crear tarea: VAIO: cloudflared-watchdog

```powershell
$task2 = @'
{
  "task": {
    "name": "VAIO: cloudflared-watchdog",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "cron": "*/5 * * * *",
      "timezone": "UTC"
    },
      "execution": {
        "agent": "build",
        "prompt": "Verific\u00e1 que cloudflared est\u00e9 corriendo.\n\n1. `Get-Process cloudflared -ErrorAction SilentlyContinue`\n2. Si no est\u00e1 vivo: `Start-Process -FilePath \"C:\\Program Files (x86)\\cloudflared\\cloudflared.exe\" -ArgumentList \"tunnel --url http://localhost:57123\" -WindowStyle Hidden`\n3. Si est\u00e1 vivo: respond\u00e9 \"OK \u2014 cloudflared PID: [PID]\""
      }
  }
}
'@
$task2 | Out-File -FilePath "$env:TEMP\vaio-cloudflared-watchdog.json" -Encoding UTF8

curl.exe -s -X PUT http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks -H "Content-Type: application/json" -d "@$env:TEMP\vaio-cloudflared-watchdog.json"
```

---

## Paso 4 — Crear tarea: VAIO: publish-url

```powershell
$task3 = @'
{
  "task": {
    "name": "VAIO: publish-url",
    "enabled": true,
    "schedule": {
      "kind": "cron",
      "cron": "0 * * * *",
      "timezone": "UTC"
    },
      "execution": {
        "agent": "build",
        "prompt": "Actualiz\u00e1 la URL de cloudflared.\n\n1. Ejecut\u00e1 `curl.exe http://127.0.0.1:20241/metrics 2>&1 | Select-String \"https://.*trycloudflare.com\"` o verific\u00e1 el proceso cloudflared\n2. Escrib\u00ed la URL en `doc/vaio/cloudflared-url.md` con formato markdown\n3. `git add + commit -m \"VAIO: URL cloudflared\" + push`\n4. Respond\u00e9 \"URL actualizada\""
      }
  }
}
'@
$task3 | Out-File -FilePath "$env:TEMP\vaio-publish-url.json" -Encoding UTF8

curl.exe -s -X PUT http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks -H "Content-Type: application/json" -d "@$env:TEMP\vaio-publish-url.json"
```

---

## Paso 5 — Verificar que las 3 tareas se crearon

```powershell
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

Debe mostrar un array con 3 tareas.

---

## Paso 6 — Escribir resultado

```powershell
$ok = @"
# Resultado 012 — Scheduled Tasks configuradas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Tareas creadas vía API

| Tarea | Cron | Estado |
|---|---|---|
| VAIO: check-tareas | * * * * * (cada 1 min) | Activa |
| VAIO: cloudflared-watchdog | */5 * * * * (cada 5 min) | Activa |
| VAIO: publish-url | 0 * * * * (cada 1 hora) | Activa |

## Método

Creadas mediante curl a la API REST de Chamber en localhost:57123.
Sin intervención manual. Sin UI.

## Próximos pasos

- Chamber ejecuta las tareas automáticamente
- El sistema anterior (worker-loop.md, startup-tunnel.ps1) queda deprecado
- MAIN monitorea resultados vía git fetch + R15
"@
Set-Content -Path "doc\vaio\results\resultado-012.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-012.md
git commit -m "VAIO: resultado tarea 012 — scheduled tasks configuradas via API"
git pull --rebase
git push
```
