# GUIA DE BUENAS PRACTICAS — Diligencia v1.5

Hábitos y workflows para usar Diligencia de forma consistente entre sesiones, agentes y proyectos.

---

## 1. Disciplina de sesión

| Fase | Acción |
|---|---|
| **Pre-sesión** | Leer `AGENTS.md`, revisar `$CHECKLIST` items abiertos, revisar `$RM` "Ahora" o "Siguiente" |
| **Durante** | Usar el comando adecuado para cada situación (ver §2) |
| **Post-sesión** | Ejecutar `/updoc` → sincroniza RM/CHECKLIST. Ejecutar `/version` si hay cambios → bump, CHANGELOG, commit |

Regla: toda sesión que modifique archivos debe cerrar con `/updoc`. Si hay cambios versionables, cerrar con `/version`.

---

## 2. Árbol de decisión — qué comando usar

| Situación | Comando | Alternativa incorrecta |
|---|---|---|
| Defecto en código/bug | `/bug` | /qa (qa es para situaciones ambiguas, no bugs confirmados) |
| Crash o error en runtime | `/incidente` | /bug (incidente es runtime, no defecto de código) |
| Situación extraña, no sabés si es bug | `/qa` | /bug (esperar a confirmar antes de crear bug) |
| Feature nueva | `/plan` → BUILD | /.direct (falta diseño si es >1 archivo) |
| Duda sobre estado del proyecto | `/health` | /. (health diagnostica rápidamente) |
| Sincronizar documentación | `/updoc` | editar RM/CHECKLIST a mano (updoc detecta gaps automático) |
| Cerrar sesión | `/version` | commit directo (version ejecuta updoc + changelog + bump) |
| Archivo obsoleto o duplicado | `/deprecar` | `rm` o `del` (deprecar no borra, mueve a .old/) |

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

---

## 7. Anti-patrones de usuario

- **Saltar `/updoc`**: ahorra 2 minutos ahora, cuesta 20 más tarde en gaps documentales
- **Hardcodear rutas**: "solo esta vez" → 3 sesiones después hay 5 rutas absolutas en comandos
- **Modificar `$CHECKLIST` sin cambiar `$RM`**: la próxima `/updoc` va a detectar inconsistencia
- **Usar `/bug` para situaciones ambiguas**: si no estás seguro, usa `/qa`. Convertir a bug después si se confirma
- **No versionar sesiones chicas**: hasta un fix de 1 línea merece su entrada en `$CHANGELOG` y su commit
- **Acumular deuda documental**: "lo actualizo después" → nunca se actualiza
