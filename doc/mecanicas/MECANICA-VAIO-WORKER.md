# MECANICA-VAIO-WORKER — Worker autónomo para servidores remotos v1.0

> Patrón reutilizable. Cualquier proyecto adaptado a Diligencia puede desplegar un worker 24/7 en una máquina remota.

---

## Propósito

Permitir que una máquina remota (servidor, laptop 24/7, VPS) ejecute tareas de mantenimiento sin intervención humana, comunicándose exclusivamente vía git con el repositorio del proyecto.

---

## Arquitectura

```
MAIN (PC principal)              GitHub                    WORKER (máquina remota)
───────────────────              ──────                    ───────────────────────
crea tarea en                    ← repo →                  git pull (cada 60s)
doc/vaio/tasks/tarea-NNN.md                                detecta tarea nueva
git push                                                   ejecuta comandos
                                                           escribe resultado en
                                                           doc/vaio/results/
                                                           git commit + push
git pull                        ← repo →                   sleep 60s → loop
lee resultado                                              

Sin intervención humana en el worker.
```

---

## Componentes

| Archivo | Propósito | Ubicación |
|---|---|---|
| `doc/vaio/README.md` | Instrucciones del puente (genéricas) | Template doc-base → heredado por /adaptar |
| `doc/vaio/worker-loop.md` | Prompt del worker: loop infinito, reglas, protocolo | Template doc-base → heredado por /adaptar |
| `doc/vaio/tasks/` | Tareas pendientes (creadas por MAIN) | Se crea al necesitarse |
| `doc/vaio/results/` | Resultados completados (creados por worker) | Se crea al necesitarse |
| `doc/vaio/worker-log.md` | Log de actividad del worker (opcional) | Se crea al activar el worker |

---

## Protocolo de comunicación

### MAIN → Worker (crear tarea)

1. Escribir archivo `doc/vaio/tasks/tarea-NNN.md` con comandos en orden
2. `git commit -m "feat(vaio): tarea NNN — [descripción]"`
3. `git push`

### Worker → MAIN (reportar resultado)

1. Worker detecta tarea nueva en su ciclo de polling (60s)
2. Ejecuta los comandos en orden
3. Escribe `doc/vaio/results/resultado-NNN.md` con el formato que pide la tarea
4. `git add doc/vaio/results/` → `git commit -m "VAIO: resultado tarea NNN"` → `git pull --rebase` → `git push`

### Ciclo del worker

```
LOOP INFINITO:
  1. git pull
  2. Listar tareas en doc/vaio/tasks/
  3. Para cada tarea sin resultado correspondiente:
     a. Leer la tarea completa
     b. Ejecutar comandos en orden
     c. Si un comando falla: anotar error, continuar con el siguiente
     d. Escribir resultado en doc/vaio/results/
     e. git add + commit + pull --rebase + push
  4. Esperar 60 segundos
  5. Volver a 1
```

---

## Reglas de seguridad

| Regla | Descripción |
|---|---|
| **Scope cerrado** | El worker solo lee y escribe en `doc/vaio/`. No toca código del proyecto, no modifica otros archivos. |
| **Solo ejecuta, no decide** | El worker ejecuta los comandos exactamente como están en la tarea. Si un comando falla, reporta el error. No improvisa soluciones. |
| **Idempotente** | Si `resultado-NNN.md` ya existe, la tarea `tarea-NNN.md` no se re-ejecuta. |
| **Commit seguro** | Antes de cada commit: `git pull --rebase`. Si hay conflicto, aborta y reporta en el resultado. |
| **No bloqueante** | Si una tarea requiere intervención manual (ej: "abrir navegador"), la reporta como bloqueante y continúa con la siguiente. |
| **Sin permisos elevados** | El worker no puede ejecutar comandos como Administrador. Si una tarea lo requiere, lo reporta como bloqueante. |
| **Aislado por proyecto** | Cada proyecto tiene su propio worker, su propio repo, su propia sesión OpenCode. Un worker no toca otros proyectos en la misma máquina. |

---

## Despliegue

### Requisitos

- OpenCode instalado en la máquina remota
- Git configurado (usuario + email + acceso al repo)
- Repositorio del proyecto clonado

### Activación

1. Clonar el repo del proyecto en la máquina remota
2. Abrir una sesión de OpenCode en el directorio del proyecto
3. Cargar `doc/vaio/worker-loop.md` como prompt del sistema
4. La sesión entra en loop perpetuo — no se cierra

### Verificación de salud

- El MAIN puede monitorear `doc/vaio/worker-log.md` (si el worker lo mantiene)
- Si pasan más de 5 minutos sin actividad en git, el worker podría estar caído
- VS Code Tunnels permite reconectar y verificar el estado de la sesión

---

## Convivencia multi-worker

Una misma máquina puede tener múltiples workers sin conflicto:

```
VAIO física:
  C:\xampp\htdocs\Diligencia\doc\vaio\   → Sesión OpenCode #1 (worker Diligencia)
  C:\xampp\htdocs\MarketAI\doc\vaio\     → Sesión OpenCode #2 (worker MarketAI)
```

Cada worker opera en su propio repositorio. No comparten archivos, no comparten estado. Las tareas de un proyecto nunca afectan a otro.

**Regla de despliegue:** una sesión de OpenCode por worker. Dos workers en la misma máquina requieren dos sesiones separadas.

---

## Deprecación del puente

Cuando los túneles directos (VS Code Remote + Cloudflare) están operativos, el worker puede ser reemplazado por acceso directo. Sin embargo, el worker tiene ventajas:

| Worker (git) | Túneles directos |
|---|---|
| ✅ No requiere túneles activos 24/7 | ❌ El túnel puede caerse |
| ✅ El MAIN no necesita estar conectado | ❌ Requiere conexión activa |
| ✅ Barato (solo git push/pull) | ❌ Depende de servicios externos |
| ❌ Latencia de ~2 minutos (ciclo git) | ✅ Respuesta inmediata |
| ❌ Solo comandos predefinidos | ✅ Terminal interactiva |

**Recomendación:** Convivencia. Túneles para trabajo interactivo, worker para tareas programadas y mantenimiento autónomo.

---

## Herencia vía /adaptar

Cualquier proyecto adaptado a Diligencia v3.0.0+ recibe automáticamente:

| Archivo | Propósito |
|---|---|
| `doc/vaio/README.md` | Instrucciones del puente de comunicación |
| `doc/vaio/worker-loop.md` | Prompt para worker autónomo 24/7 |
| `doc/vaio/PRONT_VAIO.md` | Prompt de nacimiento para sesiones Chamber interactivas |
| `doc/vaio/tasks/` | Tareas pendientes (creadas por MAIN) |
| `doc/vaio/results/` | Resultados (creados por el worker) |
| `doc/mecanicas/MECANICA-VAIO-WORKER.md` | Este documento (patrón) |

El proyecto sabe que tiene un asistente en VAIO-Server. La comunicación usa el mismo protocolo git (tareas .md → resultados .md). El scaffold está listo — solo falta activar la sesión en la VAIO.

### PRONT_VAIO vs worker-loop

| Prompt | Modo | Cuándo usarlo |
|---|---|---|
| `PRONT_VAIO.md` | **Interactivo** — diálogo humano-agente | Sesiones Chamber donde el usuario habla con el asistente |
| `worker-loop.md` | **Autónomo** — loop perpetuo | Sesiones OpenCode background que ejecutan tareas sin preguntar |

---

## Archivos relacionados

- `doc/vaio/PRONT_VAIO.md` — prompt de nacimiento para sesiones Chamber
- `doc/vaio/worker-loop.md` — prompt del worker autónomo
- `doc/vaio/README.md` — instrucciones del puente
- `GUIA_CONTROL_REMOTO.md` — túneles directos (complemento)
- `AGENTS.md` — Regla R14 (VAIO Worker) + sección Asistente VAIO
