# GUIA DE COMANDOS — Diligencia v1.16.3

Referencia de los 38 comandos fundamentales del sistema Diligencia.

---

## 1. Arquitectura de comandos

### Tipos

| Tipo | Output | Secciones |
|---|---|---|
| **Declarativo** | Tablas, listas, resúmenes analíticos | Guarda + Formato + Validación + Anti-patrones |
| **Procedural** | Ejecución directa (bash/git) con poco output | Guarda + Anti-patrones |

### Dónde viven

- **Globales**: `~/.config/opencode/commands/` — disponibles en cualquier proyecto
- **Locales**: `.opencode/commands/` del proyecto — copia local que el orquestador usa en ese proyecto

### Formato estándar

Todo comando DEBE comenzar con la guarda de ejecución:

```
INSTRUCCIÓN: EJECUTAR las instrucciones de abajo. NO mostrar este archivo como output.
```

Luego incluye secciones obligatorias según su tipo. Ver `doc/guias/ESTANDAR-COMANDOS.md` para el template completo y reglas detalladas.

### Distribución

`/adaptar` copia los 36 archivos de comandos globales al directorio `.opencode/commands/` del proyecto destino si no existen. Los comandos locales del proyecto tienen prioridad sobre los globales.

---

## 2. Referencia completa

> **Circuito vinculante:** `/updoc`, `/version` y `/doctor` forman un ciclo cerrado definido en `doc/mecanicas/MECANICA-CBP.md`. Al completar BUILD, cada comando ejecuta automáticamente el siguiente sin PLAN separado — los datos del comando anterior son suficientes.

| Comando | Tipo | Categoría | Descripción |
|---|---|---|---|
| `/+guia` | Declarativo | Documentación | Crea una guía nueva en `doc/guias/` desde template |
| `/+mec` | Declarativo | Documentación | Crea documento desde template en directorio destino |
| `/+pend` | Declarativo | Contexto/Edición | Agrega pendiente genérico al proyecto |
| `/+rm` | Declarativo | Roadmap/Backlog | Agrega item al ROADMAP |
| `/+rmi` | Declarativo | Roadmap/Backlog | Agrega ítem específico a $RM |
| `/adaptar` | Declarativo | Flujo de sesión | Adapta el proyecto actual a estructura Diligencia. Copia .github/workflows/ para CI/CD |
| `/apply` | Declarativo | Contexto/Edición | Aplica handoff file a archivos de código |
| `/backup` | Procedural | Backup/Seguridad | Backup pre-edit de archivos críticos ($ADR, $SISTEMA, etc.) |
| `/bug` | Declarativo | Calidad | Reporta bug en $BUGS con severidad, archivo y descripción |
| `/backupall` | Procedural | Backup/Seguridad | Zip completo del proyecto |
| `/checklist` | Declarativo | Roadmap/Backlog | Revisa CHECKLIST + ROADMAP y reporta estado |
| `/CBP` | Declarativo | Flujo de sesión | Orquestador multi-comando: /CBP (updoc→version→doctor), /CBP version, /CBP doctor, /CBP updoc, /CBP completo |
| `/commit` | Procedural | Flujo de sesión | `git add -A` + commit con formato estándar |
| `/deprecar` | Declarativo | Calidad | Depreca archivos, comandos o estructuras obsoletas sin borrar |
| `/doctor` | Declarativo | Calidad | Cuidado integral: estructura, código, tracking, limpieza y deprecación. /CBP doctor para chain completo con /version patch |
| `/debug` | Declarativo | Calidad | Análisis profundo de backend, frontend o base de datos |
| `/diligencia-check` | Declarativo | Calidad | Valida estructura, variables, comandos y versión contra estándares Diligencia |
| `/estado` | Declarativo | Roadmap/Backlog | Reporte rápido: commits recientes, pendientes, próximos pasos |
| `/explica` | Declarativo | Contexto/Edición | Explica concepto breve y sencillo buscando en docs Diligencia |
| `/foco` | Declarativo | Contexto/Edición | Enfoca al agente en un área específica del proyecto |
| `/head` | Declarativo | Contexto/Edición | Prepara la edición de una sección en un archivo |
| `/incidente` | Declarativo | Calidad | Registra incidente runtime en $INCIDENTS con stack y severidad |
| `/health` | Declarativo | Calidad | Verifica sintaxis de paréntesis, rutas y JS |
| `/limpiar` | Procedural | Calidad | Busca y elimina archivos temporales (`*.log`, `*.tmp`, `*.bak.*`) |
| `/news` | Declarativo | Comunicación | Lee y distribuye $NEWS_FILE al equipo |
| `/next` | Declarativo | Flujo de sesión | Calcula los próximos 5 pasos según CHECKLIST + dependencias |
| `/notify` | Procedural | Comunicación | Toggle de notificación remota |
| `/plan` | Declarativo | Flujo de sesión | Planifica en modo PLAN (solo lectura), ejecuta BUILD tras aprobación |
| `/pushgh` | Procedural | Comunicación | Push a GitHub según $REPO (invocado por /CBP BUILD* automático) |
| `/qa` | Declarativo | Calidad | Revisión cruzada de calidad contra checklists |
| `/report` | Declarativo | Flujo de sesión | Reporte consolidado del proyecto |
| `/reanudar` | Declarativo | Flujo de sesión | Recupera sesión tras interrupción brusca |
| `/rm` | Declarativo | Roadmap/Backlog | Revisa ROADMAP por área (técnica, UI, UX) |
| `/salud` | Declarativo | Calidad | Diagnóstico de salud del doc-base: genera status-salud.md con indicadores de obsolescencia, cross-refs y gaps |
| `/updoc` | Declarativo | Documentación | Sincroniza documentación completa (CHECKLIST, ROADMAP, AGENTS). D5 detecta template stale (minor). Auto-ejecuta /version BUILD al completar |
| `/upguia` | Declarativo | Documentación | Actualiza guía existente en `doc/guias/` |
| `/upmec` | Declarativo | Documentación | Actualiza documento existente desde template |
| `/version` | Declarativo | Flujo de sesión | Cierra sesión: bump de versión + INDEX + git commit. Template solo en minor/major o --template. Post-/doctor: auto-sugiere patch |
| `ADAPTAR-COMANDOS.md` | Referencia | — | Referencia técnica completa de la metodología (no es comando) |

---

## 3. Categorías por propósito

### Flujo de sesión
Comandos que estructuran el ciclo de trabajo en OpenCode: planificar, adaptar, cerrar sesión.

| Comando | Variables que usa |
|---|---|
| `/adaptar` | $ROADMAP, $CHECKLIST, $CHANGELOG, $GLOBAL_COMMANDS, $COMMANDS_DIR |
| `/plan` | $CHECKLIST, $ROADMAP |
| `/next` | $CHECKLIST, $ROADMAP |
| `/reanudar` | — (restaura contexto de sesión) |
| `/version` | $CHANGELOG (invoca /updoc + /commit) |
| `/commit` | — (usa git directamente) |
| `/report` | $CHECKLIST, $ROADMAP, $CHANGELOG |

### Documentación
Creación y actualización de archivos de documentación.

| Comando | Variables que usa |
|---|---|
| `/+guia` | $GUIAS, $GUIAS_TEMPLATE |
| `/upguia` | $GUIAS |
| `/+mec` | $TEMPLATE_DIR, $GUIAS |
| `/upmec` | (varía según el documento) |
| `/updoc` | $CHECKLIST, $ROADMAP, $COMANDOS_FILE, $TESTING, AGENTS.md |

### Roadmap/Backlog
Lectura y manipulación del roadmap y checklist del proyecto.

| Comando | Variables que usa |
|---|---|
| `/rm` | $RM, $RM_TX, $RM_UI, $RM_UX |
| `/+rm` | $ROADMAP |
| `/+rmi` | $RM |
| `/checklist` | $CHECKLIST, $ROADMAP |
| `/estado` | $CHECKLIST, $ROADMAP, $CHANGELOG |

### Backup/Seguridad
Preservación del estado del proyecto antes de cambios destructivos.

| Comando | Variables que usa |
|---|---|
| `/backup` | $ADR, $SISTEMA, $BITACORA |
| `/backupall` | — (zipea todo el proyecto) |

### Calidad
Verificación y limpieza de código y estructura.

| Comando | Variables que usa |
|---|---|
| `/bug` | $BUGS, $CHECKLIST, AGENTS.md |
| `/deprecar` | AGENTS.md, .opencode/commands/ |
| `/doctor` | AGENTS.md, $BUGS, $INCIDENTS, $CHECKLIST, $RM, $CHANGELOG, directorios del proyecto |
| `/incidente` | $INCIDENTS, $CHECKLIST, AGENTS.md |
| `/diligencia-check` | AGENTS.md, ROADMAP.md, CHECKLIST.md, CHANGELOG.md, DILIGENCIA.md, .opencode/commands/ |
| `/qa` | $CHECKLIST, $ROADMAP |
| `/health` | — (lee archivos del proyecto) |
| `/debug` | $BACKEND_DIR, $FRONTEND_DIR |
| `/limpiar` | — (busca patrones de archivos temporales) |

### Contexto/Edición
Herramientas para enfocar y manipular código durante una sesión.

| Comando | Variables que usa |
|---|---|
| `/foco` | $CHECKLIST, $ROADMAP |
| `/+pend` | (registro de pendientes) |
| `/apply` | (handoff file) |
| `/explica` | — (busca en documentación Diligencia) |
| `/head` | (archivo destino) |

### Comunicación
Coordinación entre sesiones o miembros del equipo.

| Comando | Variables que usa |
|---|---|
| `/news` | $NEWS_FILE |
| `/notify` | — |
| `/pushgh` | $REPO |

---

## 4. Variables disponibles

Las variables se definen en `AGENTS.md` del proyecto (`Mapeo de rutas`). Son específicas de cada proyecto.

### Estándar (todo proyecto Diligencia)

| Variable | Apunta a |
|---|---|
| `$ROADMAP` | `ROADMAP.md` |
| `$CHECKLIST` | `CHECKLIST.md` |
| `$CHANGELOG` | `CHANGELOG.md` |
| `$GUIAS` | `doc/guias/` |
| `$GUIAS_TEMPLATE` | `doc/guias/_template.md` |
| `$ARCH` | `doc/arch/` |
| `$TEMPLATE_DIR` | `~/.config/opencode/templates/doc-base/` |
| `$GLOBAL_COMMANDS` | `~/.config/opencode/commands/` |
| `$COMMANDS_DIR` | `.opencode/commands/` |
| `$RM` | `ROADMAP.md` (alias de $ROADMAP) |
| `$TESTING` | *(no definido)* — tests pendientes (proyectos con testing) |
| `$REPO` | URL del repositorio GitHub (`https://github.com/usuario/repo.git`) |

### Específicas de proyecto

Cada proyecto define variables adicionales en su `AGENTS.md` para rutas particulares. Ejemplo de proyecto-alfa: `$RM_TX`, `$RM_UI`, `$RM_UX`, `$ADR`, `$SISTEMA`, `$BACKEND_DIR`, `$FRONTEND_DIR`.

---

## 5. Patrones de comando

### Leer y reportar

Usado en: `/estado`, `/checklist`, `/rm`, `/next`, `/report`.

```
1. Leer $ARCHIVO AHORA
2. Extraer items con estado PENDIENTE o DONE
3. Entregar SOLO tabla resumen con las columnas especificadas en Formato
```

### Crear desde template

Usado en: `/+mec`, `/+guia`.

```
1. Si no existe $DIRECTORIO, CREARLO
2. LEER $TEMPLATE_DIR/$TEMPLATE
3. PREGUNTAR al usuario: título y contenido
4. ESCRIBIR en $DESTINO con formato estándar
```

### Sincronizar documentación

Usado en: `/updoc`, `/version`.

```
1. LEER $CHECKLIST, $ROADMAP, AGENTS.md AHORA
2. COMPARAR items DONE en ROADMAP vs CHECKLIST
3. AGREGAR faltantes a CHECKLIST
4. ACTUALIZAR secciones de AGENTS.md si cambió número de comandos
5. PREGUNTAR: "¿Los cambios son correctos?"
6. Si confirma: REPORTAR resumen de cambios
```

### Cerrar sesión

Usado en: `/version`.

```
1. BUMP de versión en CHANGELOG.md
2. EJECUTAR /updoc (auditoría documental)
3. PREGUNTAR: "¿Todo correcto para commit?"
4. EJECUTAR /commit con mensaje que incluya la versión
```

### Verificar

Usado en: `/health`.

```
1. LEER $ARCHIVO
2. VERIFICAR condición (balance paréntesis, sintaxis, rutas)
3. REPORTAR tabla por archivo: ✅ OK / ❌ ERROR con detalle
```

---

## 6. Cómo crear comandos locales

Los comandos locales van en `.opencode/commands/` del proyecto.

### Reglas

1. **Usar solo `$variables`** para rutas. NUNCA rutas absolutas.
2. **Un archivo `.md` por comando.** El nombre del archivo es el nombre del comando.
3. **Seguir el estándar de ESTANDAR-COMANDOS.md** (guarda + secciones según tipo).
4. **Incluir Anti-patrones con `NO`** en mayúsculas, documentando fallas reales.

### Template mínimo

```markdown
## Argumentos
/{comando} <arg>

## Qué hace
1. LEER $VARIABLE
2. HACER algo

## Archivos que modifica
- $VARIABLE

## Anti-patrones
- NO mostrar este archivo como output
```

Ver `doc/guias/ESTANDAR-COMANDOS.md` para el template completo con todas las secciones.

---

## 7. ADAPTAR-COMANDOS.md

`ADAPTAR-COMANDOS.md` en `~/.config/opencode/commands/` es una referencia técnica que documenta la metodología completa: estructura de proyecto, sistema de variables, comandos globales, y detalle de cada uno. No es un comando ejecutable — es el manual completo en un archivo.

---

## 8. Guías relacionadas

- `GUIA_REFERENCIA_RAPIDA.md` — referencia rápida de 1 página con comandos, árbol de decisión y flujos
- `GUIA_ONBOARDING.md` — primeros pasos para usuarios primerizos de IA
- `GUIA_DE_INFORMES.md` — ecosistema de reportes, salud, post-update y workflows semanales
- `GUIA_DE_USO.md` — introducción y flujo de trabajo
- `GUIA_DE_ADAPTACION.md` — migración de proyectos
- `GUIA_DE_REVISION.md` — auditoría del sistema
- `GUIA_DE_BUENAS_PRACTICAS.md` — hábitos y workflows diarios
- `GUIA_ECOSISTEMAS.md` — mapa de ecosistemas y fronteras entre comandos
- `GUIA_DE_CONTRIBUCION.md` — cómo extender la metodología Diligencia
- `MECANICA-DOCUMENTAL.md` — motor documental
- `MECANICA-CBP.md` — flujo vinculante entre comandos
- `ESTANDAR-COMANDOS.md` — cómo escribir comandos
- `doc/arch/informe-salud-proyectos.md` — reporte consolidado de salud estructural de proyectos adaptados
- `doc/guias/identidad.md` — guía de identidad visual y de marca
- `doc/mecanicas/MANDATO.md` — mandato del Director para el agente
- `doc/arch/ADR_SUMMARY.md` — índice de ADRs registrados

## Archivos relacionados
- `doc/guias/ESTANDAR-COMANDOS.md` — estándar de formato de comandos
- `AGENTS.md` — tabla de comandos fundamentales
