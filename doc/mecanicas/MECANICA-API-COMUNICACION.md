# MECANICA-API-COMUNICACION.md — Protocolo de tareas via API v1.0

Define la comunicacion entre PC (MAIN) y VAIO via REST API de `opencode serve`.
Reemplaza el triangulo GitHub como canal principal. El triangulo queda como fallback.

---

## Arquitectura

```
PC (MAIN)                           VAIO (servidor 24/7)
┌───────────────────┐              ┌──────────────────────────┐
│ invoke-agent-task │──POST/SSE──► │ opencode serve :4096     │
│ .ps1              │              │ sesion persistente/proy  │
│                   │◄─respuesta── │                           │
│                   │              │ watchdog: vaio-services   │
│                   │              │ .ps1 (health + cleanup)   │
│ .agent-sessions/  │              │                           │
│ └─ proyecto.json  │              │ Proyectos en disco        │
└───────────────────┘              └──────────────────────────┘
```

---

## Bootstrap de contexto (LAZY, R79.1)

Antes de procesar cualquier tarea, una sesion nueva PUEDE recibir este preambulo.
**El script `invoke-agent-task.ps1` lo inyecta SOLO si el prompt contiene keywords vinculantes** (commit, push, cbp, version, build, agente, sesion, deploy, watchdog, sync, git, rm, adapta, revis, implement, investig, doc, patron, promp, archivo, linea, merge, branch, rotat, depend, contexto, model, api, salud) o si se pasa `-StrictBootstrap`.

Prompts triviales (`git status`, `ls`, `lista archivos`) NO reciben bootstrap para ahorrar tokens input.

```
[BOOTSTRAP DILIGENCIA]
Proyecto: {NOMBRE}. CWD: {RUTA}.
Reglas vinculantes:
- BUILD = aplicar cambios, NUNCA commitear sin orden explicita.
- Solo /CBP y /version ejecutan git commit.
- No modificar archivos fuera del CWD.
- Responder SIEMPRE en espanol.
- Reportar EXITO o ERROR al final con evidencia.
- R16: citar archivo:linea en toda afirmacion.
- Si encontrás un bug en otro proyecto, reportalo, no lo arregles.
- [opcional] ALCANCE: solo pods leer/escribir archivos que matcheen: {glob,...}
```

---

## Modos de ejecucion

### Sesion nueva (default)
Cada `invoke-agent-task.ps1` crea una sesion nueva. Sin contexto previo.
Mas barato en tokens pero el agente no recuerda nada.

### Sesion persistente (-Persist)
Reusa una sesion por proyecto. El agente acumula contexto.
```powershell
.\invoke-agent-task.ps1 -Prompt "..." -Project "Nemesis" -Persist
```

La sesion se guarda en `.agent-sessions/{proyecto}.session` y se reusa hasta que:
- Se alcanzan 5 prompts → rotacion automatica
- Se superan 50K tokens → rotacion automatica
- La sesion queda idle >30 min → abortada por el watchdog
- VAIO se reinicia → el script detecta 404 y recrea la sesion

Al rotar, el ultimo prompt pide un resumen de estado (1K tokens aprox) que se inyecta en la nueva sesion.

---

## Formato de tarea

| Parametro | Ejemplo | Descripcion |
|---|---|---|
| `-Prompt` | `"Revisa el ROADMAP"` | La instruccion para el agente |
| `-Project` | `"Nemesis"` | Proyecto objetivo (define CWD) |
| `-Model` | `deepseek-v4-flash` | Modelo (default flash por costo; cargado de model-policy.json) |
| `-Persist` | (flag) | Usa sesion persistente por proyecto |
| `-SessionId` | `"abc123"` | Sesion especifica (uso avanzado) |
| `-Sync` | (flag) | Espera respuesta sincrona |
| `-MaxPrompts` | 5 | Override del limite de rotacion |
| `-NoRotate` | (flag) | Desactiva rotacion (riesgo de costo!) |
| `-StrictBootstrap` | (flag) | Fuerza bootstrap completo incluso si prompt es trivial |
| `-Include` | `*.ps1,*.md` | Scope filter (alcance de archivos que el agente puede leer) |
| `-MaxInputTokens` | 50000 | Cap de tokens input por sesion |
| `-MaxOutputTokens` | 8000 | Cap de tokens output por sesion |
| `-BalanceFloor` | 0.50 | Aborta si balance DeepSeek < floor (USD) |
| `-MaxCost` | 1.00 | Aborta sesion si cost > MaxCost tras sync (USD) |
| `-SkipPolicy` | (flag) | No cargar model-policy.json |

---

## Formato de respuesta

El agente DEBE responder con:

```
{EXITO|ERROR}: {mensaje}
Evidencia: (si aplica, archivo:linea)
```

Ejemplos:
```
EXITO: Commits analizados. 3 cambios en auth.ts.
Evidencia: git log --oneline -5: commit abc123 fix auth

ERROR: No se pudo conectar al repositorio.
Evidencia: git status: fatal: not a git repository
```

---

## Ciclo de vida de sesion

```
Crear sesion ──► Bootstrap ──► Prompt 1 ──► Prompt 2 ──► ... ──► Rotar
                                                                    │
                                                                    ▼
                                                            Nueva sesion
                                                            + resumen
```

El watchdog `vaio-services.ps1` aborta sesiones que:
- Llevan >5 min en status `running` sin progreso
- Llevan >30 min sin actividad (idle)

---

## Seguridad

- Las sesiones no tienen sandboxing a nivel filesystem.
- El agente recibe instruccion explicita de no salir del CWD.
- La password de opencode serve se pasa por variable de entorno, no hardcodeada.
- Los archivos `.agent-sessions/*.session` contienen solo IDs de sesion, no datos sensibles.

---

## Circuit breakers (R79.1 burn rate)

| Capa | Umbral | Accion |
|---|---|---|
| Pre-flight balance | `BalanceFloor` USD (default 0.50) | Aborta invocacion si balance < floor |
| Per-task cost | `MaxCost` USD (default 1.00) | Aborta sesion tras sync si cost > MaxCost |
| Daily cap | `cost-tracker.ps1 -DailyCap` (default 5.00) | Mata todas las sesiones + alerta |
| Model denylist | `pro|claude|sonnet|opus|gpt-4|gemini-pro` | `invoke-agent-task.ps1` advierte en amarillo (R18) |
| Balance floor | `BalanceFloor` USD (default 0.50) | `invoke-agent-task.ps1` aborta si balance < floor |
| Bootstrap lazy | Sin keywords | Omite bootstrap (~600 chars ahorrados) |

---

## Archivos relacionados

- `scripts/invoke-agent-task.ps1` — cliente de tareas (implementa -Persist)
- `scripts/vaio-services.ps1` — watchdog con session cleanup
- `scripts/server-config.ps1` — config persistente de conexion
- `scripts/watch-server.ps1` — dashboard y monitoreo
- `doc/mecanicas/MECANICA-SERVIDOR-AUTONOMO.md` — arquitectura del servidor
