# GUIA DE BUENAS PRACTICAS — Diligencia v1.15.0

Hábitos y workflows para usar Diligencia de forma consistente entre sesiones, agentes y proyectos.

---

## 1. Disciplina de sesión

| Fase | Acción |
|---|---|
| **Pre-sesión** | Leer `AGENTS.md`, revisar `$CHECKLIST` items abiertos, revisar `$RM` "Ahora" o "Siguiente". Si hubo interrupción brusca: `/reanudar` para recuperar contexto. Si hay cambios grandes planeados: `/backup`. Periódicamente: `/diligencia-check` para detectar degradación estructural. |
| **Durante** | Usar el comando adecuado para cada situación (ver §2) |
| **Post-sesión** | `/CBP updoc` (ejecuta /updoc PLAN→BUILD → /version minor BUILD* → sugiere /doctor) |

Regla: toda sesión sigue **PLAN → BUILD**. Usar `/CBP updoc` para post-sesión completa. Si solo se necesita versionar sin auditoría: `/CBP version`.

---

## 2. Árbol de decisión — qué comando usar

| Situación | Comando | Alternativa incorrecta |
|---|---|---|
| Defecto en código/bug | `/bug` | /qa (qa es para situaciones ambiguas, no bugs confirmados) |
| Crash o error en runtime | `/incidente` | /bug (incidente es runtime, no defecto de código) |
| Situación extraña, no sabés si es bug | `/qa` | /bug (esperar a confirmar antes de crear bug) |
| Feature nueva | `/plan` → BUILD | /.direct (falta diseño si es >1 archivo) |
| Diagnóstico integral del proyecto (estructura + código + tracking + limpieza) | `/doctor` | /health o /diligencia-check individual (doctor orquesta todo) |
| Sesión interrumpida / pérdida de conexión | `/reanudar` | empezar de cero (pierde contexto) |
| Salud de estructura del proyecto | `/diligencia-check` | /health (health es solo código, no estructura) |
| Salud de código (solo JS) | `/health` | /diligencia-check (no verifica sintaxis) |
| Análisis profundo de sección | `/debug` | /. (debug da tabla estructurada con línea exacta) |
| Sincronizar documentación | `/updoc` | editar RM/CHECKLIST a mano (updoc detecta gaps automático) |
| Cerrar sesión | 1. `/updoc` (auditar) → 2. `/version` (versionar) | commit directo (sin updoc faltan gaps, sin version falta CHANGELOG) |
| Archivo obsoleto o duplicado | `/deprecar` | `rm` o `del` (deprecar no borra, mueve a .old/) |
| Backup pre-edit | `/backup` | confiar en "no voy a romper nada" |
| Limpiar temporales | `/limpiar` | borrar a mano (olvida patrones comunes) |

---

## 3. Delegación segura

| Tamaño del cambio | Workflow |
|---|---|
| Edición pequeña, 1 archivo, <20 líneas | Trabajo directo inline |
| Exploración de código desconocido | Delegar a `@explore` o `@scout` |
| Cambio grande, multi-archivo, arquitectónico | Flujo SDD completo: `@sdd-architect` → `@sdd-implement` → `@sdd-verify` → `@sdd-reviewer` |
| Commit, push, PR | Ejecutar `@sdd-reviewer` con contexto fresco antes |

Nunca delegar una tarea grande (3+ archivos) a un solo agente sin pasar por SDD.

---

## 4. Mantener documentos vivos

- `/updoc` no es opcional: ejecutar al menos una vez por sesión que toque documentación
- `$RM` debe reflejar el estado actual: mover items "Ahora" a "Completado" apenas terminan
- `$CHECKLIST` es operativo: tildar items al completarlos, no al final de la semana
- `$CHANGELOG` se actualiza con `/version`, no manualmente

Señales de documentos enfermos:
- Items en `$RM` "Ahora" con estado 🟡 desde hace 3 sesiones → mover a "Siguiente" o limpiar
- `$CHECKLIST` con 20+ items abiertos sin prioridad → revisar si son viables o basura
- `$CHANGELOG` sin entrada en la última semana → sesiones sin versionar
- Template DILIGENCIA.md desactualizado vs proyecto → `/updoc` D5 lo detecta, corre con `/version patch`

Ejecutar `/diligencia-check` cada pocas sesiones — detecta estructura rota, variables huérfanas, comandos sin guarda.

---

## 5. Tracking sin grietas

| Esto | Va en | Y actualiza |
|---|---|---|
| Bug de código | `/bug` → `$BUGS` | `$CHECKLIST` |
| Crash en producción | `/incidente` → `$INCIDENTS` | `$CHECKLIST` |
| Situación a revisar | `/qa` → `$QA/<archivo>.md` | `$CHECKLIST` |
| Tarea operativa | `/checklist` o `$CHECKLIST` directo | — |

No duplicar: si registraste un bug en `$BUGS`, no lo copies a `$CHECKLIST` manualmente — `/bug` ya lo hace.

---

## 6. Deprecar, no borrar

`/deprecar` es la única vía para eliminar archivos obsoletos. Nunca usar `rm`, `del`, `Remove-Item`.

| Target | Ejemplo | Qué hace |
|---|---|---|
| Archivo | `/deprecar docs/viejo.md` | Mueve a `.old/docs/viejo.md`, marca en AGENTS.md |
| Comando | `/deprecar /updoc --deprecado-por /sync` | Archiva commando, recomienda reemplazo |
| Estructura | `/deprecar doc/antiguo/` | Mueve todo a `.old/doc/antiguo/` |

La carpeta `.old/` preserva historia y evita pérdida accidental.

Después de deprecar: ejecutar `/diligencia-check` (verifica que $variables no apunten a archivos deprecados) y `/updoc` (detecta el diff, clasifica el cambio).

---

## 7. Anti-patrones de usuario

- **Saltar `/updoc`**: ahorra 2 minutos ahora, cuesta 20 más tarde en gaps documentales
- **Hardcodear rutas**: "solo esta vez" → 3 sesiones después hay 5 rutas absolutas en comandos
- **Modificar `$CHECKLIST` sin cambiar `$RM`**: la próxima `/updoc` va a detectar inconsistencia
- **Usar `/bug` para situaciones ambiguas**: si no estás seguro, usa `/qa`. Convertir a bug después si se confirma
- **No versionar sesiones chicas**: hasta un fix de 1 línea merece su entrada en `$CHANGELOG` y su commit
- **Acumular deuda documental**: "lo actualizo después" → nunca se actualiza
- **Usar `/health` para validar estructura de proyecto adaptado**: `/health` es solo código (JS). Usar `/diligencia-check` para estructura Diligencia.

---

## 8. Cuidado por tipo de proyecto

El comando adecuado varía según el stack del proyecto. Leer `$STACK` de HARNESS.md o detectar manualmente.

| Proyecto | Estructura | Código | Higiene | Pre-cambio | Diagnóstico |
|---|---|---|---|---|---|
| **JS/TS** (Node, React, Next) | `/diligencia-check` | `/health` (node --check, paréntesis, rutas) | `/limpiar` | `/backup` | `/debug` |
| **Python** (Django, Flask) | `/diligencia-check` | *(pendiente — /health solo JS)* | `/limpiar` | `/backup` | `/debug` |
| **Go** | `/diligencia-check` | *(pendiente — /health solo JS)* | `/limpiar` | `/backup` | `/debug` |
| **Documental** (Diligencia, guías) | `/diligencia-check` | *(no aplica)* | `/updoc` | `/deprecar` | `/updoc` |
| **Cualquier proyecto** — diagnóstico integral | `/doctor` | `/doctor` | `/doctor` | `/doctor` | `/doctor` |

Los checks de código para stacks no-JS están pendientes de implementar en `/health`. Mientras tanto, usar linters nativos (`python -m py_compile`, `go vet`) como paso manual.

---

## 9. Circuito de trabajo

Usar `/CBP` para ejecutar secuencias completas. Cada workflow se divide en **Meta-PLAN (PRO)** y **BUILD (FLASH)**.
Mecánica completa: `doc/mecanicas/MECANICA-CBP.md`

### Diagrama de workflows

```
   SESSIONWORK
       │
       ├── /CBP updoc
       │       │
       │       ├── META-PLAN (PRO)
       │       │     /updoc PLAN → /doctor PLAN → /salud preview
       │       │     UNA confirmación
       │       │
       │       └── BUILD (FLASH)
       │             /updoc Fase F → /salud BUILD* → /version BUILD* → /doctor BUILD
       │
       ├── /CBP doctor
       │       │
       │       ├── META-PLAN (PRO)
       │       │     /doctor Fases 1→2 → /salud preview
       │       │     UNA confirmación
       │       │
       │       └── BUILD (FLASH)
       │             /doctor Fase 3 → /salud BUILD* → /version patch BUILD*
       │
       ├── /CBP version
       │       │
       │       ├── META-PLAN (PRO)
       │       │     /version Steps 1→5
       │       │     UNA confirmación
       │       │
       │       └── BUILD (FLASH)
       │             /version Steps 6→8 → sugiere /doctor
       │
       └── /CBP completo
               │
               ├── META-PLAN (PRO)
               │     Agentes/skills sugeridos → /updoc PLAN → /doctor PLAN → /salud preview
               │     UNA confirmación
               │
               └── BUILD (FLASH)
                     Agentes/skills → /updoc Fase F → /salud BUILD* → /version BUILD* → /doctor
```

### Reglas del Meta-PLAN

1. Meta-PLAN se ejecuta SIEMPRE en DeepSeek PRO (análisis profundo), sin importar el modo de invocación
2. BUILD se ejecuta SIEMPRE en DeepSeek FLASH (ejecución rápida)
3. Meta-PLAN ejecuta PLAN de TODOS los comandos del workflow antes de pedir confirmación
4. BUILD* solo es válido cuando el Meta-PLAN ya auditó los datos necesarios
5. El usuario confirma UNA SOLA VEZ (no paso a paso)
6. Si el usuario rechaza el Meta-PLAN: workflow detenido, cero archivos modificados

### Safe-path: /CBP version sin /CBP updoc previo

```
/CBP version detecta: INDEX.md ausente o labels stale
→ "⚠️ No se detectó /updoc reciente. ¿Ejecutar /CBP updoc primero?"
  ├─ Sí  → abortar /CBP version, ejecutar /CBP updoc
  └─ No  → /CBP version igual (gaps informativos sin corregir)
```

### Agentes y skills en /CBP completo

El workflow `completo` del meta-orquestador sugiere agentes según el estado del working tree:

| Condición | Agente/Skill | Orden en BUILD |
|---|---|---|
| git diff >20 líneas código | `@sdd-reviewer` | 1ero (antes de versionar) |
| Cambios de arquitectura | `@sdd-architect` | 1ero (antes de aplicar) |
| Tests en proyecto | `skill("tdd-strict")` + `@sdd-verify` | 2do (después de revisar) |
| ROADMARK con SDD items | `skill("sdd-workflow")` | Contexto (no ejecuta) |

### Anti-patrones

- **Ejecutar `/CBP version` cuando debía ser `/CBP updoc`**: gaps documentales se acumulan
- **Saltar `/doctor` antes de cerrar**: bugs no registrados y tracking desincronizado pasan desapercibidos
- **Ejecutar Meta-PLAN en FLASH**: el análisis profundo requiere PRO para detectar gaps y stale correctamente
- **Ejecutar BUILD en PRO**: desperdicio de tokens y latencia — BUILD solo ejecuta cambios ya planificados
- **Confirmar paso a paso en vez de UNA SOLA VEZ**: el Meta-PLAN consolida todo, no necesita confirmaciones intermedias
