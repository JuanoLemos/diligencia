# GUIA DE ECOSISTEMAS — Diligencia v1.16.2

Mapa de los 9 ecosistemas de comandos: qué hacen, cuándo se ejecutan, qué archivos gestionan, y las reglas de frontera entre ellos.

---

## 1. Qué es un ecosistema

Un **ecosistema** es un grupo de comandos que comparten:

- **Dominio** — el "por qué" (cuidar, versionar, adaptar, etc.)
- **Ciclo de ejecución** — se invocan juntos o secuencialmente
- **Archivos gestionados** — escriben/leen el mismo conjunto de archivos

Cada comando pertenece a un ecosistema primario. Algunos comandos (como `/deprecar`) participan en dos ecosistemas.

---

## 2. Los 9 ecosistemas

| # | Ecosistema | Propósito | Comandos | Cuándo se usa | Archivos que gestiona |
|---|---|---|---|---|---|
| 1 | **DOCTOR** | Cuidado integral del proyecto | `/doctor`, `/health`, `/diligencia-check`, `/bug`, `/incidente`, `/limpiar`, `/deprecar` | Revisión periódica, antes de commit, al adoptar un proyecto existente | `bugs.md`, `incidentes.md`, `.old/**`, `CHECKLIST.md` |
| 2 | **VERSION** | Versionado, sincronización y recuperación de sesión | `/version`, `/updoc`, `/reanudar` | Al cerrar una sesión, tras interrupción brusca, antes de commit, después de cambios en docs | `DILIGENCIA.md`, `CHANGELOG.md`, `ROADMAP.md`, `CHECKLIST.md` |
| 3 | **ADAPTAR** | Inicialización y migración de proyectos | `/adaptar`, `@sdd-architect`, `@sdd-implement`, `@sdd-reviewer`, `@sdd-verify` | Proyecto nuevo, migración de proyecto existente | Estructura de proyecto, `DILIGENCIA.md`, `CHANGELOG.md`, `doc/`, `.github/workflows/`, `templates/doc-base/**` |
| 4 | **DESARROLLO** | Definición y consulta del lenguaje del sistema | `/crear-comando`, `/explica` | Al crear un comando nuevo, al preguntar por un concepto | `ESTANDAR-COMANDOS.md`, archivos de comandos, documentación indexada |
| 5 | **CALIDAD** | Validación de código runtime | `/lint`, `/typecheck` | Después de editar código, en hooks de pre-commit, CI | Código fuente del proyecto (ningún archivo de Diligencia) |
| 6 | **DOCUMENTACIÓN** | Autoría de mecánicas y guías | `/+mec`, `/+guia` | Al crear una mecánica nueva, al crear una guía nueva | `doc/mecanicas/`, `doc/guias/` |
| 7 | **CONTEXTO** | Estado compartido entre sesiones | Variables: `$BUGS`, `$INCIDENTS`, `$CHECKLIST`. Comando: `/explica` | En cada inicio de sesión (vía AGENTS.md), al preguntar por el estado del proyecto | `AGENTS.md`, `doc/arch/bugs.md`, `doc/arch/incidentes.md`, `CHECKLIST.md`, `ROADMAP.md` |
| 8 | **BACKUP** | Deprecación segura sin pérdida de historial | `/deprecar` | Al retirar un archivo, comando o template obsoleto | `.old/`, archivos movidos a `.old/` |
| 9 | **COMUNICACIÓN** | Operaciones Git | `/commit`, `/push`, `/pr`, `/pushgh` | Después de cerrar una sesión con `/version`, al preparar un PR, push automático via /CBP | Repositorio git, commits, PRs |

---

## 3. Cadenas de orquestación

### DOCTOR (orquestador de subcomandos)

```
/doctor
├── Fase 1 Diagnóstico (solo lectura)
│   ├── /health          — salud del stack
│   ├── /diligencia-check — estructura y documentación
│   ├── /bug             — bugs abiertos
│   ├── /incidente        — incidentes abiertos
│   └── /limpiar         — temporales y basura
├── Fase 2 Confirmación  → usuario decide qué corregir
└── Fase 3 Correcciones
    ├── /bug             — crear/actualizar bugs
    ├── /incidente        — crear/actualizar incidentes
    ├── /limpiar         — limpieza
    └── /deprecar        — mover a .old/
    ↓
    └── Sugiere `/version patch` para consolidar correcciones
```

### VERSION (secuencia de cierre de sesión)

```
/version
├── Auto-detecta: ¿viene de /doctor? → sugiere `patch` en vez de `minor`
├── Bump DILIGENCIA.md
├── ¿Proyecto = Diligencia? → sync template + adaptar.md
├── Actualiza CHANGELOG.md
└── Llama a /updoc
    ├── Fase A — sincronizar versiones
    ├── Fase B — detectar comandos nuevos
    ├── Fase C — actualizar tracking (RM, CHECKLIST)
    ├── D5 — detecta staleness template vs proyecto
    └── Fase E — archivar y cerrar
```

### ADAPTAR (flujo SDD completo)

```
/adaptar
├── Crea estructura de proyecto
├── Copia templates doc-base (incluye .github/workflows/diligencia-check.yml)
├── Adapta comandos globales
├── Registra en AGENTS.md
└── Luego: @sdd-architect → @sdd-implement → @sdd-reviewer/@sdd-verify
```

---

## 4. Reglas de frontera

### DOCTOR ↔ VERSION (la más crítica)

| Regla | DOCTOR | VERSION (/updoc) |
|---|---|---|
| `bugs.md` | Lee y escribe (Fase 1c + Fase 3b) | **No toca** — ni lee, ni escribe, ni sincroniza |
| `incidentes.md` | Lee y escribe (Fase 1d + Fase 3c) | **No toca** — ni lee, ni escribe, ni sincroniza |
| `.old/**` | Escribe (Fase 3e via `/deprecar`) | **No procesa** — ignora todo `.old/` |
| `CHECKLIST.md` | Agrega items en correcciones | Sincroniza tildes (Fase C) |
| `ROADMAP.md` | — | Sincroniza estado (Fase C) |
| `DILIGENCIA.md` | — | Sincroniza versión (Fase A) |
| `CHANGELOG.md` | — | Verifica cobertura (Fase C) |

**Principio**: `/updoc` solo procesa cambios del orquestador (guías, mecánicas, ADRs, comandos). `/doctor` maneja su propio tracking en `bugs.md` e `incidentes.md`. Nunca conflictúan porque operan sobre dominios disjuntos de archivos.

### CALIDAD ↔ DOCTOR

- `/health` es convocado por `/doctor` pero también funciona standalone
- `/lint` y `/typecheck` son independientes — no hay orquestación directa
- Si el stack no es JS, `/doctor` saltea `/health` silenciosamente (no aborta)

### BACKUP ↔ DOCTOR

- `/deprecar` es la única herramienta de backup. `/doctor` lo invoca en Fase 3, pero no tiene lógica propia de backup.
- `/deprecar` nunca borra — solo mueve a `.old/` y marca en CHANGELOG.

---

## 5. Comandos multi-ecosistema

| Comando | Ecosistema primario | Otros ecosistemas |
|---|---|---|
| `/deprecar` | DOCTOR | BACKUP (única herramienta de backup) |
| `/explica` | DESARROLLO | CONTEXTO (lee variables y estado) |
| `/health` | DOCTOR | CALIDAD (validación de stack) |
| `/doctor` | DOCTOR | — (es el orquestador, no se mueve) |
| `/reanudar` | VERSION | — (recuperación de sesión) |
| `/pushgh` | COMUNICACIÓN | — (push git a $REPO) |

---

## 6. Árbol de decisión — ¿qué ecosistema usar?

```
¿Qué estás haciendo?
│
├── Revisar salud del proyecto    → DOCTOR  → `/doctor`
├── Cerrar una sesión             → VERSION → `/version`
├── Recuperar sesión interrumpida → VERSION → `/reanudar`
├── Nuevo proyecto                → ADAPTAR → `/adaptar`
├── Crear un comando nuevo        → DESARROLLO → `/crear-comando`
├── Preguntar por un concepto     → DESARROLLO → `/explica`
├── Validar código runtime        → CALIDAD → `/lint` o `/typecheck`
├── Crear una mecánica/guía       → DOCUMENTACIÓN → `/+mec` o `/+guia`
├── Revisar estado del proyecto   → CONTEXTO → abrir AGENTS.md o hacer `/explica $VARIABLE`
├── Retirar un archivo obsoleto   → BACKUP  → `/deprecar`
└── Commitear y pushear           → COMUNICACIÓN → `/commit`, `/push`, `/pushgh` (push automático via /CBP)
```

---

## 7. Archivos por ecosistema (matriz)

| Archivo | DOCTOR | VERSION | ADAPTAR | DESARROLLO | CALIDAD | DOCUMENTACIÓN | CONTEXTO | BACKUP | COMUNICACIÓN |
|---|---|---|---|---|---|---|---|---|---|
| `AGENTS.md` | — | Lee/Actualiza | Crea | — | — | — | Referencia | — | — |
| `DILIGENCIA.md` | — | Actualiza | Crea | — | — | — | — | — | — |
| `CHANGELOG.md` | — | Actualiza | Crea | — | — | — | — | Acrega | — |
| `ROADMAP.md` | — | Actualiza | — | — | — | — | Referencia | — | — |
| `CHECKLIST.md` | Agrega items | Actualiza tildes | Crea | — | — | — | Referencia | — | — |
| `bugs.md` | Lee/Escribe | — | Crea template | — | — | — | Referencia | — | — |
| `incidentes.md` | Lee/Escribe | — | Crea template | — | — | — | Referencia | — | — |
| `GUIA_ECOSISTEMAS.md` | — | — | — | — | — | Crea | — | — | — |
| `doc/guias/*` | — | — | — | — | — | Crea | — | — | — |
| `doc/mecanicas/*` | — | — | — | — | — | Crea | — | — | — |
| `ESTANDAR-COMANDOS.md` | — | — | — | Lee/Actualiza | — | — | — | — | — |
| `comandos/*.md` | — | — | — | Crea | — | — | — | — | — |
| `.github/workflows/diligencia-check.yml` | — | — | Copia template | — | — | — | — | — | — |
| `.old/**` | Indica mover | — | — | — | — | — | — | Escribe | — |
| Código fuente proyecto | — | — | — | — | Valida | — | — | — | — |
| Repositorio git | — | — | — | — | — | — | — | — | Escribe |

---

*Última actualización: 2026-06-01*
