# MECANICA-SERVIDOR-AUTONOMO.md — Control remoto de agentes via API v1.0

> Nueva arquitectura: `opencode serve` en VAIO expone API REST + SSE.
> Chamber en PC controla el servidor sin necesidad de git polling.
> Reemplaza el triangulo GitHub (tasks/results) para control directo.

---

## Arquitectura

```
┌─── PC Personal ────────────────────┐     ┌─── Servidor (VAIO/Linux) ────────┐
│                                    │     │                                   │
│  Chamber Desktop                   │     │  opencode serve                   │
│  ┌──────────────────────────────┐  │     │  --port 4096 --hostname 0.0.0.0  │
│  │ invoke-agent-task.ps1        │  │HTTP │  --mdns                          │
│  │ watch-server.ps1             │◄─SSE─►│                                   │
│  │                              │  │     │  Proyectos:                      │
│  │ POST /session                │  │     │  C:\xampp\htdocs\Diligencia     │
│  │ POST /session/:id/prompt_async│  │    │  C:\xampp\htdocs\Nemesis        │
│  │ GET  /event (SSE)            │  │     │  C:\xampp\htdocs\+RM            │
│  │ GET  /global/health          │  │     │  ...                             │
│  └──────────────────────────────┘  │     │                                   │
│                                    │     │  Cloudflare tunnel (opcional)     │
└────────────────────────────────────┘     └───────────────────────────────────┘
```

---

## Endpoints de opencode serve

`opencode serve` expone una API REST completa con espec OpenAPI 3.1 en `/doc`.

| Endpoint | Metodo | Descripcion | Equivalente funcional |
|---|---|---|---|
| `/session` | POST | Crear sesion nueva (con titulo y cwd) | "Nueva tarea" |
| `/session` | GET | Listar todas las sesiones | Dashboard |
| `/session/:id/message` | POST | Enviar prompt y esperar respuesta (sincrono) | "Ejecutar y esperar" |
| `/session/:id/prompt_async` | POST | Disparar tarea sin esperar (204) | "Enviar a cola" |
| `/session/:id/abort` | POST | Cancelar sesion en ejecucion | "Abortar" |
| `/session/:id/message` | GET | Ver mensajes de sesion | "Leer resultado" |
| `/session/:id/diff` | GET | Ver diff de cambios | "Que toco?" |
| `/event` | GET | Stream SSE de eventos en tiempo real | "Monitoreo" |
| `/global/event` | GET | Stream SSE de TODAS las sesiones | "Monitoreo global" |
| `/global/health` | GET | Health check del servidor | "Ping" |

---

## Flujo de trabajo

### 1. Iniciar servidor (en VAIO, una sola vez)

```powershell
# En VAIO:
.\doc\vaio\scripts\start-opencode-server.ps1 -Port 4096 -Lan -Password "secreto"

# O como Scheduled Task "At Startup" para 24/7:
# Trigger: At system startup
# Action: powershell -File "C:\xampp\htdocs\Diligencia\doc\vaio\scripts\start-opencode-server.ps1" -Port 4096 -Lan -Password "secreto"
```

### 2. Conectar desde PC (Chamber)

```powershell
# Configurar variable de entorno:
$env:DILIGENCIA_SERVER = "http://vaio-ip-o-tunnel:4096"
$env:OPENCODE_SERVER_PASSWORD = "secreto"

# Verificar que responde:
.\scripts\watch-server.ps1
```

### 3. Enviar tarea

```powershell
# Modo sincrono (espera resultado):
.\scripts\invoke-agent-task.ps1 -Prompt "Fix the login bug in auth.ts" -Project "Nemesis"

# Modo asincrono + streaming:
.\scripts\invoke-agent-task.ps1 -Prompt "Actualizar roadmap" -Project "Diligencia" -Stream
.\scripts\watch-server.ps1 -Watch
```

### 4. Monitorear sesion especifica

```powershell
.\scripts\watch-server.ps1 -SessionId abc123
```

---

## Autenticacion

`opencode serve` usa HTTP Basic Auth:

```powershell
$env:OPENCODE_SERVER_USERNAME = "diligencia"
$env:OPENCODE_SERVER_PASSWORD = "tu-password-seguro"
```

Los scripts `invoke-agent-task.ps1` y `watch-server.ps1` usan estas variables automaticamente.

---

## Comparacion con el sistema anterior

| Aspecto | Antes (triangulo GitHub) | Ahora (API directa) |
|---|---|---|
| Comunicacion | git push -> poll -> git pull | HTTP directo |
| Latencia | Minutos (espera polling) | Milisegundos |
| Notificacion de resultado | Revisar GitHub | SSE en tiempo real |
| Cancelar tarea | Esperar que termine | `POST /session/:id/abort` |
| Ver progreso | No | SSE streaming |
| Health check | No | `GET /global/health` |
| Multiples proyectos | Una sesion a la vez | Sesiones paralelas por proyecto |
| Fallback | — | Sistema anterior sigue funcionando |

---

## Proyectos soportados

El mapeo proyecto -> ruta esta en `invoke-agent-task.ps1`:

| Proyecto | Ruta en VAIO |
|---|---|
| Diligencia | `C:\xampp\htdocs\Diligencia` |
| +RM | `C:\xampp\htdocs\+RM` |
| MarketAI | `C:\xampp\htdocs\MarketAI` |
| conquisitare | `C:\xampp\htdocs\conquisitare` |
| buenobonitobarato | `C:\xampp\htdocs\buenobonitobarato` |
| Nemesis | `C:\xampp\htdocs\nemesis` |
| OpenMontage | `C:\Users\jlemo\OneDrive\Desktop\OpenMontage-main` |

---

## Scheduled Tasks recomendadas (Chamber en VAIO)

### server-health

| Campo | Valor |
|---|---|
| Name | VAIO: server-health |
| Schedule | `*/5 * * * *` (cada 5 minutos) |
| Prompt | Verifica que opencode serve este respondiendo. `curl -s http://localhost:4096/global/health`. Si no responde, reinicia con `doc\vaio\scripts\start-opencode-server.ps1 -Kill -Lan`. Reporta "OK" o "REINICIADO". |

---

## Seguridad

- `opencode serve` solo acepta Basic Auth (usuario + password)
- Usar Cloudflare tunnel en vez de exponer el puerto directamente
- El password se pasa por variable de entorno, nunca hardcodeado
- `--hostname 0.0.0.0` solo en redes de confianza (VPN, LAN local)
- Para acceso publico: siempre via tunnel con `--ui-password`

---

## Troubleshooting

| Problema | Causa | Solucion |
|---|---|---|
| Server no responde | opencode serve no esta corriendo | `Get-Process opencode`. Si no esta: `start-opencode-server.ps1` |
| 401 Unauthorized | Password incorrecta | Verificar `$env:OPENCODE_SERVER_PASSWORD` |
| CORS bloqueado | Dominio no en whitelist | Agregar `--cors` con el dominio de la PC |
| Sesion stuck | Agente crasheo | `POST /session/:id/abort` |
| Puerto en uso | Otra instancia de opencode | `Get-Process opencode \| Stop-Process -Force` |

---

## Archivos relacionados

- `doc/vaio/scripts/start-opencode-server.ps1` — script de inicio del servidor
- `scripts/invoke-agent-task.ps1` — enviar tareas desde PC
- `scripts/watch-server.ps1` — monitoreo y dashboard
- `doc/vaio/schemas/task.json` — schema de tarea
- `doc/vaio/VAIO-SCHEDULED.md` — sistema de scheduled tasks (fallback)
- `doc/vaio/GUIA_RECUPERACION_VAIO.md` — recovery checklist
- `ROADMAP.md` — item R78
