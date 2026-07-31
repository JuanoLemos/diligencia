# AGENTS.md — Diligencia

Documentación de la metodología de estructura estándar para proyectos OpenCode.

## Identidad

Soy **Diligencia** — una metodología de estructura documental para proyectos OpenCode.

**v3.11.0 (2026-07-31):** Transición a Claude Desktop. VAIO + server remoto + Chamber deprecados. Arquitectura simplificada: Claude local → git → proyectos adaptados.

Gobierno: comandos globales, reglas, mecánicas, guías, versionado.

Los proyectos adaptados (Nemesis, +RM, conquisitare, etc.) son independientes — no los modifico sin confirmación explícita del usuario (Regla #19).



## Idioma

Español — todas las respuestas del agente deben ser en español. Si el agente contesta en inglés, recordarle explícitamente que responda en español.

Emojis: permitidos y recomendados en todo tipo de comunicación y documentación. Diligencia es plural — usa emojis para mejorar la claridad visual y reducir la barrera de entrada para usuarios no expertos. ✅🔴🟡🟢📋🩺🔬📦⚠️

---

## Mapeo de rutas

| Variable | Ruta | Descripción |
|---|---|---|
| $ROADMAP | `ROADMAP.md` | Roadmap de Diligencia |
| $CHANGELOG | `CHANGELOG.md` | Historial de versiones |
| $GUIAS | `doc/guias/` | Guías de uso |
| $GUIAS_TEMPLATE | `doc/guias/_template.md` | Plantilla de guía |
| $MECANICAS | `doc/mecanicas/` | Mecánicas del sistema |
| $MECANICAS_TEMPLATE | `doc/mecanicas/_template.md` | Plantilla de mecánica |
| $ARCH | `doc/arch/` | ADRs y arquitectura |
| $TEMPLATE_DIR | `~/.config/opencode/templates/doc-base/` | Template base |
| $GLOBAL_COMMANDS | `~/.config/opencode/commands/` | Comandos globales |
| $RM | `ROADMAP.md` | Alias de $ROADMAP |
| $COMMANDS_DIR | `.opencode/commands/` | Comandos locales del proyecto |
| $HARNESS | `.opencode/HARNESS.md` | Configuración de harness (test, lint, skills, stack) |
| $BUGS | `doc/arch/bugs.md` | Bug tracker (P1/P2/P3, severidad, estado) |
| $INCIDENTS | `doc/arch/incidentes.md` | Incidentes runtime y crashes |
| $TESTING | *(definido en HARNESS.md)* | Comando de test del proyecto |
| $REPO | `https://github.com/JuanoLemos/diligencia.git` | Repositorio GitHub del proyecto |
| $BACKUPS | `doc/arch/backups.md` | Log de backups del doctor |
| $BACKUP_KEEP | `5` | Cantidad de backups a conservar (pruning automático) |
| $PROYECTOS | `"C:\xampp\htdocs\+RM","C:\xampp\htdocs\MarketAI","C:\xampp\htdocs\conquisitare","C:\xampp\htdocs\buenobonitobarato","C:\xampp\htdocs\nemesis","C:\Users\jlemo\OneDrive\Desktop\OpenMontage-main"` | 6 proyectos activos adaptados a Diligencia (NO incluye Chamber) |
| $CHAMBER | `C:\Users\jlemo\OneDrive\Desktop\openchamber` | Repo de OpenChamber — interfaz visual de Diligencia (pertenece a Diligencia) |
| $STACK | *(definido en HARNESS.md)* | Stack tecnológico del proyecto (runtime) |
| $PROJECT_NAME | *(del header DILIGENCIA.md)* | Nombre del proyecto para reportes |
| $UX_CHECK | `doc/arch/ux-check.md` | Checklist de validación manual post-implementación |

## Comandos globales heredados — 32 fundamentales

| Comando | Descripción | Tipo |
|---|---|---|
| /adaptar | Adaptar proyecto a estructura Diligencia | Declarativo |
| /subadaptar | Sincronizar agentes con reglas R1-R10 actuales | Declarativo |
| /plan | Planificar tarea o grupo de tareas (ola) con sub-fases y conflictos | Declarativo |
| /commit | Git add + commit formateado (--push para commit+push) | Procedural |
| /health | Verificar sintaxis y consistencia | Declarativo |
| /reportar | Reportar bug o incidente en el tracker correspondiente | Declarativo |
| /deprecar | Deprecar archivos/comandos/estructuras obsoletas | Declarativo |
| /debug | Análisis profundo | Declarativo |
| /diligencia-check | Validar estructura Diligencia del proyecto | Declarativo |
| /salud | Cuidado integral: estructura + código + tracking + circuito + limpieza + legal | Declarativo |
| /limpiar | Limpiar temporales | Procedural |
| /estado | Reporte rápido del proyecto | Declarativo |
| /explica | Explicar concepto en formato directo (→/📄/⚠️/🧭) | Declarativo |
| /rm | Revisar ROADMAP: top 10 tareas con impacto y sub-fases | Declarativo |
| /next | Plan de ejecución por olas: agrupa tareas sin dependencias cruzadas + sub-fases | Declarativo |
| /consejo | Consultar al consejero sobre dudas o ideas del proyecto (--explorar para fuentes externas) | Declarativo |
| /circuito | Revisar integridad lógica y UX (handlers, rutas, navegación) | Declarativo |
| /+rm | Agregar item al ROADMAP | Declarativo |
| /updoc | Actualizar documentación completa | Declarativo |
| /doc | Crear o actualizar guías y mecánicas desde template | Declarativo |
| /backup | Backup de archivos o proyecto completo (--all) | Procedural |
| /foco | Enfocar agente en área específica | Declarativo |
| /version | Cerrar sesión: bump + updoc + commit | Declarativo |
| /head | Preparar edición de sección en archivo | Declarativo |
| /reanudar | Recuperar sesión tras interrupción brusca | Declarativo |
| /informe-salud | Reporte de salud inter-proyecto (escanea $PROYECTOS) | Declarativo |
| /mutacion | Absorber mutaciones de un proyecto adaptado | Declarativo |
| /revision | Revisar mutaciones del proyecto y generar reporte | Declarativo |
| /documentar | Auditoría documental completa (24 checks, --legales para legal) | Declarativo |
| /ola | Sistema de oleadas multi-proyecto (planear/ejecutar/estado) | Declarativo |
| /CBP | Orquestador de workflows vinculantes (commit, version, updoc) | Procedural |
| /agentes-sync | Sincronizar agentes + escanear $PROYECTOS | Declarativo |
## Focus
- Documentar la metodología
- Mantener coherencia entre componentes
- Evolucionar el estándar

## Disciplina BUILD

BUILD = aplicar cambios, NO commitear. Solo /commit, /CBP y /version ejecutan git commit.
Al terminar cualquier BUILD en este proyecto, reportar cambios aplicados y sugerir /CBP.

> Nota: Este proyecto es Markdown puro (sin código runtime). Los pasos de post-edit verification
> del harness global (verificar `const`/`let`/`function`/`class` duplicados) son irrelevantes
> y pueden omitirse en este proyecto. Aplica solo la releitura de 15 líneas alrededor del sitio editado.

## Deprecados

| Item | Fecha | Reemplazo |
|---|---|---|
| `/+pend` | 2026-06-13 | Usar `/+rm` para registro directo en ROADMAP |
| `/+rmi` | 2026-06-13 | Usar `/+rm` para agregar items al ROADMAP |
| `/news` | 2026-06-13 | Sin reemplazo — feature nunca usado |
| `/notify` | 2026-06-13 | Sin reemplazo — variable $NOTIFY_SCRIPT nunca definida |
| `/qa` | 2026-06-13 | Sin reemplazo — variable $QA nunca definida |
| `/apply` | 2026-06-26 | Sin reemplazo — redundante con herramientas de edición directa de OpenCode |
| `/bug` | 2026-06-26 | Usar `/reportar --tipo bug` — unificado con /incidente |
| `/incidente` | 2026-06-26 | Usar `/reportar --tipo incidente` — unificado con /bug |
| `/salud` | 2026-06-26 | Renombrado de `/doctor` por conflicto con OpenCode nativo. `/salud` es el reemplazo directo. |
| `/doctor` | 2026-06-26 | Usar `/salud` — renombrado por conflicto con built-in de OpenCode |
| `/pushgh` | 2026-06-26 | Usar `/commit --push` — integrado como flag |
| `/report` | 2026-06-26 | Usar `/estado --full` — absorbido en Dashboard Unificado |
| `/backupall` | 2026-06-26 | Usar `/backup --all` — integrado como flag |
| `/legal` | 2026-06-26 | Usar `/salud` — verifica licencias en Fase 1h |
| `/+guia` | 2026-06-26 | Usar `/doc --tipo guia` |
| `/upguia` | 2026-06-26 | Usar `/doc --tipo guia --actualizar` |
| `/+mec` | 2026-06-26 | Usar `/doc --tipo mecanica` |
| `/upmec` | 2026-06-26 | Usar `/doc --tipo mecanica --actualizar` |
| `/checklist` | 2026-06-26 | Usar `/rm` (inconsistencias CHECKLIST↔RM) y `/next` (priorización) — funcionalidad redistribuida |
| `CHECKLIST.md` (documento) | 2026-06-28 | Movido a `.old/` — tracking redistribuido en `/rm` y `/next`. Variable `$CHECKLIST` eliminada. |

## Reglas operacionales (v4.0.0)

| Regla | Descripción |
|---|---|
| **R1-R5** | **Autonomía de sesión**: Un solo agente por proyecto. El agente puede editar su proyecto asignado, reportar textuales, ejecutar /CBP. `/adaptar` solo usuario. Auditoría cruzada si encuentra bugs en otros proyectos. |
| **R6** | **Bump selectivo**: Version solo cambios SHELL (comandos globales, mecánicas, R-numbers, migraciones). NO: docs, heartbeats, infra, watchdog, ruido. Pre-check obligatorio antes de bump. |
| **R7-R10** | **Convivencia multi-sesión**: git fetch antes de respuesta. Notificar cambios significativos. WT limpio antes de commit. Si conflicto, pausa y reporta. |
| **R16** | **Evidencia obligatoria**: Toda afirmación (verifiqué, revisé) requiere evidencia (archivo:línea, output comando). Prohibido: "está bien". Requerido: "Leí DILIGENCIA.md:1 → v4.0.0 ✓". |
| **R17** | **Autonomía racional**: Ejecuta lo que puedas. Solo delega: acceso físico, credenciales, decisiones irreversibles, confirmación R79.2. |
| **R79.2** | **Decisión humana sobre git (CRITICAL)**: SIEMPRE esperas confirmación antes de `git commit`, `git push`, `git tag`, bump. Patrón: "Recomiendo X porque Y. ¿Procedo (sí/no/cambiar)?" y **esperar respuesta**. Excepciones: (a) mandato explícito, (b) R-excepción en archivo, (c) tareas read-only. |
| **R81** | **Token awareness (NEW)**: Input > 35K → sugiere compresión. Output > 5K → sugiere split próxima sesión. Monitorea overhead, evita burn rate. |


## Prioridad MCP — codebase-memory-mcp

Si `codebase-memory-mcp` está disponible como servidor MCP (instalado por el usuario), **los agentes deben usarlo antes de leer archivos individuales**. Este servidor indexa el codebase completo en un grafo de conocimiento, permitiendo consultas estructurales 120× más eficientes que explorar archivo por archivo.

| Herramienta | Para qué |
|---|---|
| `search_graph` | Buscar funciones/clases por patrón de nombre |
| `trace_path` | Trazar call chains (quién llama a qué) |
| `get_architecture` | Overview estructural del proyecto |
| `search_code` | Búsqueda textual en archivos indexados |
| `manage_adr` | Gestionar Architecture Decision Records |
| `detect_changes` | Mapear cambios no commiteados a símbolos afectados |
| 3D UI | `http://localhost:9749` — grafo interactivo del proyecto |

Regla: **Primero MCP, después grep.** Siempre que necesites entender estructura, llamá a `get_architecture` o `search_graph` antes de leer archivos con bash/grep.

## Instrucciones Claude v4.0.0

La metodología completa para Claude Desktop está en **`.opencode/claude-instructions-v4.md`**.

Contiene:
- Identidad + modo conversacional (charla + confirmación)
- Reglas completas R1-R81
- Anti-patrones (loops, triangularidad, ambigüedad)
- Patrón de conversación ejemplificado

**Este archivo (`AGENTS.md`) es la referencia rápida.** Para documentación completa, ver `claude-instructions-v4.md`.

---

## Archivos relacionados
- `.opencode/claude-instructions-v4.md` — instrucciones Claude v4.0.0 (completo)
- `.opencode/HARNESS.md` — configuración de harness, test y lint
- `doc/guias/ESTANDAR-COMANDOS.md` — estándar de formato de comandos
