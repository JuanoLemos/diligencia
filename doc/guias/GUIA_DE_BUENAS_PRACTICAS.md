# GUIA DE BUENAS PRACTICAS — Diligencia v1.10.2

Hábitos y workflows para usar Diligencia de forma consistente entre sesiones, agentes y proyectos.

---

## 1. Disciplina de sesión

| Fase | Acción |
|---|---|
| **Pre-sesión** | Leer `AGENTS.md`, revisar `$CHECKLIST` items abiertos, revisar `$RM` "Ahora" o "Siguiente". Si hubo interrupción brusca: `/reanudar` para recuperar contexto. Si hay cambios grandes planeados: `/backup`. Periódicamente: `/diligencia-check` para detectar degradación estructural. |
| **Durante** | Usar el comando adecuado para cada situación (ver §2) |
| **Post-sesión** | 1. `/updoc` (PLAN: audit 8 fases, detecta gaps) → si hay gaps, confirmar BUILD (Fase F)<br>2. Si `/updoc` D5 detecta template stale → `/version patch`<br>3. `/version minor|patch` (cierra versión: bump, CHANGELOG, commit auto) |

Regla: toda sesión sigue **PLAN → BUILD**. `/updoc` primero (auditar), `/version` después (versionar). Si ejecutás `/version` sin `/updoc`, él mismo sugiere correr `/updoc` primero.

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

Secuencia cíclica **PLAN → BUILD** vinculante, con handoff automático entre comandos.
Cada paso requiere confirmación explícita del usuario.
Mecánica completa: `doc/mecanicas/MECANICA-CIRCUITO.md`

```
   SESSIONWORK
       │
       ▼
   /updoc PLAN → BUILD
       │ (vinculante)
       ▼
   /version PLAN → BUILD
       │ (vinculante)
       ▼
   /doctor PLAN → BUILD
       │
       ├── correcciones → /version patch PLAN → BUILD → SESSIONWORK
       └── sin correcciones ──────────────────────→ SESSIONWORK
```

### Safe-path: /version sin /updoc previo

```
/version detecta: INDEX.md ausente o labels stale
→ "⚠️ No se detectó /updoc reciente. ¿Ejecutar /updoc primero?"
  ├─ Sí  → /updoc (auditar), luego /version
  └─ No  → /version igual (gaps informativos sin corregir)
```

### Anti-patrones

- **Ejecutar `/version` sin `/updoc` previo**: gaps documentales se acumulan
- **Saltar `/doctor` antes de cerrar**: bugs no registrados y tracking desincronizado pasan desapercibidos
