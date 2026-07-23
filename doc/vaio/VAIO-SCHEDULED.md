# VAIO-SCHEDULED — Worker autónomo via Chamber Scheduled Tasks v1.0

> Reemplaza el sistema anterior (worker-loop.md + startup-tunnel.ps1).
> Chamber gestiona el scheduling. OpenCode ejecuta las tareas. Ningún loop en el agente.

---

## Arquitectura

En vez de un loop infinito en OpenCode (que no funciona porque el agente espera input humano), **Chamber orquesta las ejecuciones**:

```
Chamber en VAIO (24/7 en localhost:57123)
│
├── Scheduled Task "VAIO: check-tareas"
│   Cada: 1 minuto
│   Acción: git pull → revisar doc/vaio/tasks/ → ejecutar pendientes → resultado → push
│
├── Scheduled Task "VAIO: cloudflared-watchdog"
│   Cada: 5 minutos
│   Acción: verificar cloudflared vivo, reiniciar si caído
│
├── Scheduled Task "VAIO: publish-url"
│   Cada: 1 hora
│   Acción: leer URL de cloudflared, escribir en cloudflared-url.md, commit + push
│
└── Cloudflare Tunnel (nativo de Chamber)
    Chamber inicia y publica la URL automáticamente
```

### Diferencias con el sistema anterior

| Aspecto | Antes (worker-loop.md) | Ahora (Scheduled Tasks) |
|---|---|---|
| ¿Quién hace el loop? | OpenCode (agente infinito) | Chamber (scheduler battle-tested) |
| ¿Quién ejecuta tareas? | OpenCode | OpenCode (vía scheduled task) |
| ¿Persistencia? | Sesión manual | Scheduler persistido en base de datos |
| ¿Recuperación tras crash? | Manual (reiniciar sesión) | Automática (Chamber revive el scheduler) |
| ¿Monitoreo? | worker-log.md manual | Eventos SSE + estado en UI de Chamber |
| Túnel cloudflared | startup-tunnel.ps1 (script manual) | Nativo de Chamber (UI + API) |

---

## Cómo funciona cada tarea

### check-tareas (cada 1 minuto)

Chamber crea una sesión OpenCode y envía el prompt:

```
Actuá como el VAIO Worker de Diligencia.
1. git pull
2. Revisá doc/vaio/tasks/ para tareas sin resultado
3. Si hay tarea pendiente: ejecutala, escribí resultado en doc/vaio/results/
4. git add + commit + push
5. Respondé "DONE" con resumen
```

Si hay tarea pendiente → el agente la procesa entera. Si no hay → git pull y "DONE".

### cloudflared-watchdog (cada 5 minutos)

```
Verificá que cloudflared esté corriendo.
Si no: reinicialo.
Si sí: respondé "OK".
```

### publish-url (cada 1 hora)

```
Leé la URL actual de cloudflared.
Escribila en doc/vaio/cloudflared-url.md.
Commit + push.
```
---

## Configuración

### Requisitos previos

- Chamber corriendo en la VAIO (`localhost:57123`)
- Acceso a la UI de Chamber (vía vscode.dev tunnel o cloudflared URL)
- OpenCode configurado con git y credenciales de GitHub
- El repositorio Diligencia clonado en `C:\xampp\htdocs\Diligencia`

### Pasos

1. Abrir Chamber en la VAIO
2. Ir a la sección **Scheduled Tasks** (Settings → Scheduled Tasks)
3. Crear las tareas según los detalles debajo
4. Verificar que se ejecuten correctamente

Cada tarea requiere:
- **Name:** nombre descriptivo
- **Project:** el proyecto Diligencia (`C:\xampp\htdocs\Diligencia`)
- **Schedule:** cron expression o intervalo
- **Prompt:** las instrucciones para el agente

---

## Tareas configuradas

### 1. check-tareas

| Campo | Valor |
|---|---|
| Name | VAIO: check-tareas |
| Project | Diligencia |
| Schedule | `* * * * *` (cada minuto) |
| Agent | build |
| Model | deepseek-v4-flash |
| Auto-approve | On |
| Prompt | Actuá como el VAIO Worker de Diligencia. Hacé `git pull` en `C:\xampp\htdocs\Diligencia`. Revisá `doc/vaio/tasks/` para tareas sin resultado (`doc/vaio/results/resultado-NNN.md`). Si hay tarea pendiente: ejecutala completamente, escribí el resultado en `doc/vaio/results/resultado-NNN.md`, hace `git add + commit -m "VAIO: resultado tarea NNN" + push`. Respondé "DONE" con resumen. Si no hay tareas: respondé "sin tareas". |

### 2. cloudflared-watchdog

| Campo | Valor |
|---|---|
| Name | VAIO: cloudflared-watchdog |
| Project | Diligencia |
| Schedule | `*/5 * * * *` (cada 5 minutos) |
| Agent | build |
| Model | deepseek-v4-flash |
| Auto-approve | On |
| Prompt | Verificá que cloudflared esté corriendo en esta máquina con `Get-Process cloudflared -ErrorAction SilentlyContinue`. Si no está: ejecutá `C:\Program Files (x86)\cloudflared\cloudflared.exe tunnel --url http://localhost:57123` en background. Si está: respondé "OK". |

### 3. publish-url

| Campo | Valor |
|---|---|
| Name | VAIO: publish-url |
| Project | Diligencia |
| Schedule | `0 * * * *` (cada hora) |
| Agent | build |
| Model | deepseek-v4-flash |
| Auto-approve | On |
| Prompt | Ejecutá `curl http://127.0.0.1:20241/metrics` o verificá la URL actual de cloudflared. Escribí la URL en `doc/vaio/cloudflared-url.md` con el formato `# cloudflared-url\n\n| Campo | Valor |\n|---|---|\n| URL | https://... |\n| Fecha | (fecha actual) |`. Commit + push. |

---

## Troubleshooting

| Problema | Causa | Solución |
|---|---|---|
| La tarea no se ejecuta | Scheduler no arrancó | Verificar que Chamber esté corriendo. `Get-Process OpenChamber*` |
| La tarea falla con "permission denied" | Auto-approve desactivado | Activar "auto-approve" en la configuración de la tarea |
| El agente no encuentra el repo | Project path incorrecto | Verificar que el proyecto apunte a `C:\xampp\htdocs\Diligencia` |
| cloudflared no se reinicia | El agente no tiene permisos para iniciar procesos | Verificar auto-approve o ejecutar una vez manualmente |
| git push falla | Credenciales no configuradas | Ejecutar `git push` manualmente una vez desde la VAIO para autenticar |

## Archivos relacionados

- `doc/vaio/tasks/tarea-012.md` — instrucciones para configurar los scheduled tasks
- `doc/vaio/worker-loop.md` — ⚠️ DEPRECADO (reemplazado por este sistema)
- `doc/vaio/startup-tunnel.ps1` — ⚠️ DEPRECADO (reemplazado por tunnel nativo de Chamber)
- `doc/mecanicas/MECANICA-VAIO-WORKER.md` — patrón documentado (actualizar)
- `AGENTS.md` — reglas R14-R15 (actualizar)
