# Tarea 012 — Configurar Scheduled Tasks en Chamber

> **Tarea ÚNICA de configuración.** Una vez configurada, Chamber ejecuta las tareas automáticamente.
> Ejecutar desde la UI de Chamber en la VAIO. No modifica código del proyecto.

## Objetivo

Crear 3 tareas programadas en Chamber que reemplazan el worker-loop.md (deprecado):

| Tarea | Frecuencia | Propósito |
|---|---|---|
| VAIO: check-tareas | Cada 1 minuto | Revisar y ejecutar tareas pendientes en doc/vaio/tasks/ |
| VAIO: cloudflared-watchdog | Cada 5 minutos | Verificar cloudflared vivo, reiniciar si caído |
| VAIO: publish-url | Cada 1 hora | Publicar URL de cloudflared en cloudflared-url.md |

---

## Paso 1 — Acceder a Scheduled Tasks en Chamber

Abrir Chamber en la VAIO:

```
https://close-proceeds-winter-cups.trycloudflare.com
```

O desde vscode.dev:

```
https://vscode.dev/tunnel/vaio-server/
```

Ir a: **Settings** (⚙️) → **Scheduled Tasks** → **+ New Task**

---

## Paso 2 — Crear tarea: check-tareas

```yaml
Name: VAIO: check-tareas
Project: Diligencia  # o el nombre del proyecto configurado en Chamber
Schedule: Every minute  # o cron: * * * * *
Agent: build  # deepseek-v4-flash
Auto-approve: ON

Prompt:
  Actuá como el VAIO Worker de Diligencia.
  
  1. Hacé `git pull` en `C:\xampp\htdocs\Diligencia`
  2. Revisá `doc/vaio/tasks/` para tareas sin resultado correspondiente
  3. Si hay tarea pendiente: ejecutala, escribí resultado en `doc/vaio/results/`
  4. `git add + commit -m "VAIO: resultado tarea NNN" + push`
  5. Respondé "DONE" con resumen de lo ejecutado
```

---

## Paso 3 — Crear tarea: cloudflared-watchdog

```yaml
Name: VAIO: cloudflared-watchdog
Project: Diligencia
Schedule: Every 5 minutes  # o cron: */5 * * * *
Agent: build
Auto-approve: ON

Prompt:
  Verificá que cloudflared esté corriendo.
  
  1. `Get-Process cloudflared -ErrorAction SilentlyContinue`
  2. Si no está vivo:
     `Start-Process -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57123" -WindowStyle Hidden`
  3. Si está vivo: respondé "OK — cloudflared PID: [PID]"
```

---

## Paso 4 — Crear tarea: publish-url

```yaml
Name: VAIO: publish-url
Project: Diligencia
Schedule: Every hour  # o cron: 0 * * * *
Agent: build
Auto-approve: ON

Prompt:
  Actualizá la URL de cloudflared.
  
  1. Ejecutá `curl.exe http://127.0.0.1:20241/metrics 2>&1 | Select-String "https://.*trycloudflare.com"` o verificá el proceso cloudflared
  2. Escribí la URL en `doc/vaio/cloudflared-url.md` con formato markdown
  3. `git add + commit -m "VAIO: URL cloudflared" + push`
  4. Respondé "URL actualizada"
```

---

## Paso 5 — Verificar que funcionan

Después de crear las 3 tareas:

1. En la UI de Scheduled Tasks, verificar que aparecen como **enabled**
2. Esperar 1-2 minutos
3. Verificar el estado (última ejecución, éxito/fallo)
4. Hacer `git pull` desde la PC Principal y verificar `cloudflared-url.md` actualizado

---

## Paso 6 — Escribir resultado

Desde la VAIO:

```powershell
$ok = @"
# Resultado 012 — Scheduled Tasks configuradas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Tareas creadas

| Tarea | Schedule | Estado |
|---|---|---|
| check-tareas | cada 1 min | Activa |
| cloudflared-watchdog | cada 5 min | Activa |
| publish-url | cada 1 hora | Activa |

## Próximos pasos

- Verificar que las tareas se ejecutan correctamente en los próximos minutos
- El sistema anterior (worker-loop.md, startup-tunnel.ps1) queda deprecado
- Chamber ahora orquesta el worker autónomo
"@
Set-Content -Path "doc\vaio\results\resultado-012.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-012.md
git commit -m "VAIO: resultado tarea 012 — scheduled tasks configuradas"
git pull --rebase
git push
```
