# GUIA DE USO — Diligencia v1.0

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
3. Al final de la sesión: /updoc
4. → /commit
```

---

## 4. Ciclo de actualización por instancia (`/updoc`)

Cada vez que cerrás una sesión, `/updoc` sincroniza estos archivos:

| Archivo | Qué hace |
|---|---|
| `ROADMAP.md` | Marca items como DONE, mueve a Completed |
| `CHECKLIST.md` | Sincroniza con DONE de ROADMAP, elimina duplicados |
| `AGENTS.md` | Agrega nuevas mecánicas/guías/comandos detectados |
| `doc/guias/COMANDOS.md` | Refleja comandos nuevos del proyecto |
| `doc/testing/TESTING_PENDIENTE.md` | Tests nuevos/completados |

**Regla:** `ROADMAP.md` (y en general los RM) son fuente de verdad. `CHECKLIST.md` se deriva. `AGENTS.md` es el índice de todo.

---

## 5. Reglas clave

| Regla | Explicación |
|---|---|
| **Solo $variables en comandos** | Ningún comando tiene rutas absolutas o relativas hardcodeadas |
| **AGENTS.md es SSOT de rutas** | Cambiás una ruta una vez y todos los comandos la heredan |
| **Root = 3 archivos** | `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`. Siempre. |
| **/updoc al cerrar sesión** | Si no sincronizás, la documentación se desvía |
| **Dos capas de comandos** | Los globales se heredan sin copiar. Los locales solo si son específicos del proyecto |

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
  → copia template
  → "¿Nombre del proyecto?" "Mis Tesoros"  
  → "¿Stack?" "Python + Flask + SQLite"
  → "¿Áreas de roadmap?" "Técnico, UX"
  → AGENTS.md creado con $variables
  → ROADMAP.md creado con áreas Técnico + UX
  → "Listo. Estructura Diligencia v1.0 creada."

opencode> / +rm "CRUD de items" tx
  → agrega item al ROADMAP.md sección Técnico

opencode> [trabajar código...]

opencode> /updoc
  → sincroniza docs
  → detecta items DONE

opencode> /commit
  → "chore: CRUD de items"
```
