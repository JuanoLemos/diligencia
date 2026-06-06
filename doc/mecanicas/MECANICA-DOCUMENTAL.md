# MECANICA-DOCUMENTAL — Motor documental de Diligencia v1.16.0

Define cómo interactúan los archivos, variables y comandos del sistema Diligencia. Es referencia del motor; para hábitos de usuario, ver `GUIA_DE_BUENAS_PRACTICAS.md`.

---

## Índice

| # | Sección | Contenido |
|---|---------|-----------|
| [§1](#1-motor-base---variables-y-flujo) | Motor base | Variables del sistema, flujo documental, sincronización RM↔CHECKLIST |
| [§2](#2-tracking---bugs-e-incidentes) | Tracking | /bug, /incidente, ciclo de vida de items |
| [§3](#3-qa---situaciones-a-revisar) | QA | /qa, cuándo es QA vs bug vs incidente |
| [§4](#4-sesión---apertura-y-cierre) | Sesión | Pre, durante y post-sesión: /backup, /updoc, /version |
| [§5](#5-conservación---deprecar-y-limpiar) | Conservación | /deprecar, /limpiar, /diligencia-check |
| [§6](#6-anti-patrones-documentales) | Anti-patrones | Por sección, qué evitar |

---

## 1. Motor base — Variables y flujo

### Variables del sistema

| Variable | Archivo | Rol |
|---|---|---|
| $RM | ROADMAP.md | Estrategia: Ahora / Siguiente / Futuro / Completado |
| $CHECKLIST | CHECKLIST.md | Tracking operativo: tareas tildables |
| $CHANGELOG | CHANGELOG.md | Historial versionado por release |
| $BUGS | doc/arch/bugs.md | Bug tracker: P1/P2/P3, severidad, estado |
| $INCIDENTS | doc/arch/incidentes.md | Incidentes runtime: stack, mitigación |
| $QA | doc/qa/ | Situaciones a revisar (archivos sueltos) |
| $HARNESS | .opencode/HARNESS.md | Config test/lint/skills/stack |
| $ADR | doc/arch/ | Decisiones de arquitectura (ADR-NNN.md) |
| $GUIAS | doc/guias/ | Guías de usuario |
| $MECANICAS | doc/mecanicas/ | Mecánicas documentales |
| $COMMANDS_DIR | .opencode/commands/ | Comandos locales del proyecto |

### Flujo documental

```
Editar docs
    ↓
/updoc (Fase A-E)
    ├── A: Alcance (git diff desde último versionado)
    ├── B: Clasificación (CORE/ADR/GUIA/MECANICA/COMMAND/AGENTS/DILIGENCIA)
    ├── C: Gaps (RM↔CHECKLIST, ADRs, guías, mecánicas, comandos, AGENTS, DILIGENCIA)
    ├── D: Integridad cross-ref (guias huérfanas, templates sin consumidor,
    │       scope /explica, variables huérfanas, D5 template staleness)
    └── E: Consolidar y aplicar (tabla de gaps → confirmación → cambios)
    ↓
/version (cierre)
    ├── Detecta versión actual (CHANGELOG.md o package.json)
    ├── Si post-/doctor: auto-sugiere `patch` en vez de `minor`
    ├── Bump minor/patch/X.Y
    ├── Si proyecto = Diligencia: sync template DILIGENCIA.md + adaptar.md
    ├── Entrada en CHANGELOG.md
    ├── /updoc final (sincroniza antes de commit)
    └── Commit versionado
```

### Sincronización RM ↔ CHECKLIST

- `/updoc` Fase C detecta items en RM "Ahora" con estado 🟡/✅ que ya están en "Completado" → los mueve
- Items DONE en RM que faltan en CHECKLIST → se agregan
- Items duplicados entre secciones → se notifican
- CHECKLIST = fuente operativa, RM = fuente estratégica. Convergen via `/updoc`.

---

## 2. Tracking — Bugs e incidentes

### /bug — Bug tracking

Comando: `~/.config/opencode/commands/bug.md`
Datos: `$BUGS` → `doc/arch/bugs.md`

| Acción | ID | Severidad | Campos obligatorios |
|---|---|---|---|
| Crear bug | B-NN | P1/P2/P3 | Descripción, archivo o módulo |
| Resolver bug | B-NN | — | Fix descripción |
| Revertir bug | B-NN | — | Razón de reversión |

Ciclo de vida: `Abierto → Resuelto → (opcional) Revertido`

Template en `~/.config/opencode/templates/doc-base/bugs.md`. Si no existe, `/bug` lo crea automáticamente con nombre del proyecto.

### /incidente — Incident tracking

Comando: `~/.config/opencode/commands/incidente.md`
Datos: `$INCIDENTS` → `doc/arch/incidentes.md`

| Acción | ID | Severidad | Campos distintos de bug |
|---|---|---|---|
| Crear incidente | I-NN | P1/P2/P3 | Fecha, stack trace, mitigación |
| Resolver | I-NN | — | Causa root, mitigación aplicada |

Diferencia clave: los bugs son **defectos de código**. Los incidentes son **eventos runtime** (crash, anomalía en producción, error de sistema). Un bug puede causar un incidente, pero se registran por separado.

Ambos actualizan `$CHECKLIST` automáticamente al crearse.

---

## 3. QA — Situaciones a revisar

### /qa — Reporte de situación

Comando: `~/.config/opencode/commands/qa.md`
Datos: `$QA` → `doc/qa/` (archivos sueltos .md)

| Campo | Descripción |
|---|---|
| Situación observada | Qué viste |
| Comportamiento esperado | Qué debería pasar |
| Comportamiento real | Qué pasó |
| Pasos para reproducir | Cómo llegar al estado |

Cuándo usar QA vs Bug vs Incidente:

| Escenario | Herramienta | Razón |
|---|---|---|
| Defecto confirmado en código | `/bug` | Ya tenés certeza |
| Crash en producción con stack | `/incidente` | Evento runtime, necesita mitigación |
| No sabés si es bug, no hay stack | `/qa` | Ambigua: investigar primero, convertir a bug después |
| Comportamiento extraño, sin error | `/qa` | Situación, no defecto confirmado |
| Mejora o feature request | `/plan` | No es bug ni incidente |

`/qa` crea un archivo en `$QA/` con nombre descriptivo y agrega entrada en `$CHECKLIST`.

---

## 4. Sesión — Apertura y cierre

### Pre-sesión

1. Leer `AGENTS.md` → conocer variables y comandos del proyecto
2. Revisar `$CHECKLIST` → items abiertos, prioridades
3. Revisar `$RM` "Ahora" y "Siguiente" → qué está activo
4. Si hubo interrupción brusca en sesión anterior: `/reanudar` para recuperar contexto
5. Opcional: `/diligencia-check` si no se corrió hace varias sesiones
6. Opcional: `/backup` si se planean cambios destructivos grandes

### Durante

Usar el árbol de decisión de `GUIA_DE_BUENAS_PRACTICAS.md §2` para elegir comando según situación. Ningún cambio documental debería saltar `/updoc` al final.

### Post-sesión

1. Ejecutar `/updoc` → sincroniza RM/CHECKLIST, detecta gaps cross-ref (incluye D5 template staleness)
2. Si hay cambios versionables: `/CBP version` → bump, CHANGELOG, commit (o `/CBP doctor` para chain completo con /version patch)
3. Si hubo interrupción brusca en sesión anterior: `/reanudar` antes de continuar

### /backup — Respaldo pre-cambio

Comando: `~/.config/opencode/commands/backup.md`

| Modo | Qué hace |
|---|---|
| Con git | `git stash push -m "backup pre-edit $(date)"` |
| Sin git | Copia archivos críticos a `.old/bak_<archivo>.<fecha>` |

Sin argumentos: respalda automáticamente AGENTS.md, ROADMAP.md, CHECKLIST.md, CHANGELOG.md + archivos git-modified.

---

## 5. Conservación — Deprecar y limpiar

### /deprecar — Archivar sin borrar

Comando: `~/.config/opencode/commands/deprecar.md`

| Target | Acción | Destino |
|---|---|---|
| Archivo (`docs/viejo.md`) | Mover a `.old/` manteniendo estructura | `.old/docs/viejo.md` + `<!-- DEPRECADO -->` en AGENTS.md |
| Comando local (`/comando`) | Mover .md a `.old/commands/` | `.old/commands/comando.md` + fila en AGENTS.md Deprecados |
| Comando global (`/comando`) | Marcar en `deprecados.md` (no mover) | `~/.config/opencode/commands/deprecados.md` |
| Directorio (`doc/antiguo/`) | Solo registro en AGENTS.md (mover manual) | Tabla Deprecados en AGENTS.md |

Post-deprecación: ejecutar `/diligencia-check` para verificar que ninguna `$variable` apunte al archivo movido, y `/updoc` para que el diff clasifique el cambio.

### /limpiar — Higiene de temporales

Comando: `~/.config/opencode/commands/limpiar.md`

Patrones buscados: `*.log`, `*.tmp`, `*.bak.*`, `temp/`, `node_modules/.cache/`, `query`, `start`, `line*.txt`, `check_*.js`, `chk.js`

Siempre muestra lista antes de eliminar y pide confirmación.

### /diligencia-check — Diagnóstico estructural

Comando: `~/.config/opencode/commands/diligencia-check.md`

| Categoría | Verifica |
|---|---|---|
| A — Estructura ADR-003 | Archivos raíz, `doc/arch/`, `doc/guias/`, `.opencode/`, HARNESS.md |
| B — Variables AGENTS.md | Cada `$VARIABLE` resuelve a archivo real, core variables presentes, comandos sin rutas hardcodeadas |
| C — Comandos (ESTANDAR-COMANDOS.md) | Guarda de ejecución, secciones obligatorias según tipo |
| D — Versión | DILIGENCIA.md vs /adaptar |
| E — CI/CD | `.github/workflows/diligencia-check.yml` presente (opcional) |

---

## 6. Anti-patrones documentales

### Motor base

- NO editar $RM sin tildar en $CHECKLIST (o viceversa) → rompe la sincronización, /updoc va a detectarlo y corregirlo pero queda rastro.
- NO saltar `/updoc` antes de `/version` → los gaps se acumulan y la próxima auditoría encuentra inconsistencias.
- NO tener $RM o $CHECKLIST sin $CHANGELOG → el historial de versiones es requisito del estándar ADR-003.

### Tracking

- NO registrar bugs en $CHECKLIST sin crear entrada en $BUGS → el tracker `$BUGS` es la fuente de verdad, CHECKLIST solo refleja.
- NO registrar incidentes sin fecha y severidad → sin fecha no hay trazabilidad; default P2 si no se especifica.
- NO usar `/qa` para bugs confirmados ni viceversa → QA es investigación, bug es certeza.

### Sesión

- NO cerrar sesión sin `/updoc` → la documentación se desvía del código.
- NO hardcodear rutas en comandos locales ("solo esta vez") → la próxima migración encuentra 5 rutas absolutas.
- NO acumular deuda documental ("lo actualizo después") → nunca se actualiza.

### Conservación

- NO borrar archivos obsoletos → usar `/deprecar` que mueve a `.old/` y marca en AGENTS.md.
- NO deprecar el mismo target dos veces → `/deprecar` lo detecta y aborta.
- NO limpiar sin confirmación → `/limpiar` siempre muestra lista antes de eliminar.
