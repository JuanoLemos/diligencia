# GUIA DE USO — Diligencia v1.15.0

Manual completo de la metodología de estructura estándar para proyectos OpenCode.

---

## 1. ¿Qué es Diligencia?

Diligencia es una convención que define cómo se estructura la documentación de un proyecto OpenCode. Resuelve tres problemas:

1. **Rutas inconsistentes** entre proyectos → estructura predecible
2. **Paths hardcodeados** en comandos → sistema de `$variables`
3. **Comandos duplicados** cada proyecto nuevo → dos capas (global + local)

---

## 2. Componentes del sistema

```
~\.config\opencode\                         ← GLOBAL (se hereda solo)
├── commands\adaptar.md                     ← /adaptar
├── commands\commit.md, plan.md, ...        ← comandos universales
├── commands\ADAPTAR-COMANDOS.md            ← referencia técnica
└── templates\doc-base\                     ← plantilla para proyectos nuevos
    ├── AGENTS.md                           ← variables editables
    ├── ROADMAP.md                          ← plan
    ├── CHECKLIST.md                        ← tareas
    ├── CHANGELOG.md                        ← versiones
    ├── DILIGENCIA.md                       ← sello metodología
    ├── .markdownlint.json                  ← reglas linting
    └── doc\arch\                           ← ADRs
        ├── README.md
        └── adr-template.md

<tu-proyecto>\                               ← LOCAL
├── AGENTS.md                               ← NODO CENTRAL ($variables)
├── ROADMAP.md                              ← plan del proyecto
├── CHECKLIST.md                            ← tareas vivas
├── CHANGELOG.md                            ← historial
├── DILIGENCIA.md                           ← sello de versión
├── doc\arch\                               ← ADRs, bitácora, sistema
├── doc\guias\                              ← guías de usuario
├── doc\mecanicas\                          ← mecánicas (si aplica)
└── .opencode\commands\                     ← comandos del proyecto
```

---

## 3. Flujo de trabajo ideal

### Crear proyecto nuevo

```
1. mkdir nuevo-proyecto
2. cd nuevo-proyecto
3. opencode -c
4. → Decís: /adaptar
```

El comando detecta que no hay `AGENTS.md` → proyecto nuevo. Copia el template, pregunta nombre y stack, escribe `AGENTS.md` con variables iniciales, crea `ROADMAP.md`.

### Adaptar proyecto existente

```
1. cd proyecto-existente
2. opencode -c
3. → Decís: /adaptar
```

El comando detecta `AGENTS.md` sin `ROADMAP.md` en raíz → existente no adaptado. Ejecuta las 6 fases de migración (explorar → variables → refactorizar → mover → actualizar ops → verificar).

### Trabajo diario (cada sesión)

```
1. opencode -c (retomar sesión)
2. Trabajar: comandos locales con $variables
3. Durante la sesión: /doctor para diagnóstico, /bug para bugs, /incidente para crashes
4. Al final: /updoc (PLAN — audit docs informativos, 8 fases A→H)
5. → Si /updoc encuentra gaps: confirmar correcciones (BUILD)
6. → Si /updoc D5 sugiere /version patch: ejecutar
7. /version minor|patch (cierra versión: CHANGELOG, bump, commit auto)
```

### Recuperar sesión tras interrupción

```
1. opencode -c
2. → Decís: /reanudar
3. El comando detecta modo Plan (discusión) o Build (edición) desde git + SDD artifacts
4. Continúa la sesión desde donde quedó
```

---

## 4. Auditoría y sincronización de documentación (`/updoc`)

`/updoc` audita y sincroniza la **documentación informativa** (guías, mecánicas, ADRs, referencias) contra la versión de referencia de CHANGELOG. No toca docs críticos (CHANGELOG, DILIGENCIA, ROADMAP, CHECKLIST) — esos son dominio de `/version`.

Opera en 8 fases (A→H):

| Fase | Qué hace |
|---|---|
| **A — Catálogo** | Lee INDEX.md; si no existe, escanea disco y ofrece crearlo |
| **B — Referencia** | Obtiene versión de referencia desde CHANGELOG |
| **C — Stale** | Compara labels de versión de cada doc contra referencia |
| **D — Gaps** | Detecta gaps de contenido en docs stale o sin label |
| **E — Plan** | Presenta tabla consolidada y pide confirmación |
| **F — BUILD** | Aplica correcciones de contenido y bumps de label |
| **G — Git-diff** | .md modificados no registrados en INDEX |
| **H — Cross-ref** | D1-D5: guías huérfanas, templates, scope /explica, variables, template staleness |

**Regla:** INDEX.md es el catálogo SSOT de toda la documentación informativa.

---

## 5. Reglas clave

| Regla | Explicación |
|---|---|---|
| **Solo $variables en comandos** | Ningún comando tiene rutas absolutas o relativas hardcodeadas |
| **AGENTS.md es SSOT de rutas** | Cambiás una ruta una vez y todos los comandos la heredan |
| **Root = 4 archivos** | `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`, `DILIGENCIA.md`. Siempre. |
| **INDEX.md es catálogo** | Toda la documentación informativa se registra en INDEX.md |
| **/updoc + /version al cerrar sesión** | Primero /updoc (docs informativos), luego /version (docs críticos + bump) |
| **Dos capas de comandos** | Los globales se heredan sin copiar. Los locales solo si son específicos del proyecto |
| **/doctor para diagnóstico** | Unifica health, lint, bug/incidente tracking en un flujo |
| **/reanudar tras interrupción** | Recupera sesión sin perder contexto — detecta Plan vs Build automáticamente |

---

## 6. Resolución de variables

Cuando el orquestador lee un comando como `/+rm`, encuentra `$RM_TX`. Busca en `AGENTS.md` el valor de `$RM_TX` y lo resuelve a `ROADMAP.md#tecnico`. Así un comando escrito en cualquier proyecto sabe exactamente qué archivo leer sin rutas absolutas.

---

## 7. Ejemplo completo

```
# Querés crear un proyecto nuevo

C:\> mkdir mis-tesoros
C:\> cd mis-tesoros
C:\mis-tesoros> opencode -c

opencode> /adaptar
  → detecta proyecto nuevo
  → copia template (14 archivos, incluye HARNESS.md y CI/CD)
  → "¿Nombre del proyecto?" "Mis Tesoros"  
  → "¿Stack?" "Python + Flask + SQLite"
  → "¿Áreas de roadmap?" "Técnico, UX"
  → AGENTS.md creado con $variables
  → ROADMAP.md creado con áreas Técnico + UX
  → HARNESS.md overlay aplicado (stack Python)
  → "Listo. Estructura Diligencia v1.10.1 creada."

opencode> / +rm "CRUD de items" tx
  → agrega item al ROADMAP.md sección Técnico

opencode> [trabajar código...]

opencode> /updoc
  → audita documentación informativa (8 fases A→H)
  → detecta INDEX.md, compara labels, busca gaps
  → sugiere correcciones si aplica

opencode> /version patch
  → cierra versión: mueve [Unreleased] → v1.0.0
  → actualiza CHANGELOG, DILIGENCIA, ROADMAP
  → sincroniza template doc-base y /adaptar

opencode> /commit --auto
  → "chore(release): v1.0.0"

# Sesión interrumpida (pérdida de conexión)

C:\mis-tesoros> opencode -c
opencode> /reanudar
  → detecta working tree dirty + SDD artifacts → modo BUILD
  → continúa desde el punto de interrupción
```
