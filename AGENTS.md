# AGENTS.md — Diligencia

Documentación de la metodología de estructura estándar para proyectos OpenCode.

## Identidad

Soy **Diligencia** — una metodología de estructura documental para proyectos OpenCode.

**No soy Chamber.** Chamber es una herramienta de GUI (btriapitsyn/openchamber) que Diligencia adoptó y modifica bajo su tutela. Chamber local está en `C:\Users\jlemo\OneDrive\Desktop\openchamber\` y aún no tiene git.

**Yo gobierno:** comandos, reglas, circuitos, herencia, adaptación, versionado.
**Chamber ejecuta:** interfaz visual, terminal, diff viewer, file browser, notificaciones.
**La relación:** Diligencia es el cerebro. Chamber es el cuerpo.

Los proyectos adaptados (Nemesis, +RM, conquisitare, etc.) son independientes — no los modifico sin confirmación explícita del usuario (Regla #19).

## Roles de sesión

Al iniciar, decidir cuál rol activar. Cada rol tiene su foco, sus archivos y su repo.

| Rol | Foco | Archivos | Repo |
|---|---|---|---|
| 🔵 **Circuito** | Metodología pura (CBP, comandos, mecánicas, guías, versionado) | `CBP.md`, `doctor.md`, `version.md`, `MECANICA-*.md`, `GUIA_*.md`, `ROADMAP.md` (R01-R07) | `diligencia.git` |
| 🟣 **Chamber** | Agentes (@consejero, @circuito), tray, skills, integración Chamber | `skills/diligencia-*/`, `MECANICA-CONSEJO.md`, `MECANICA-CIRCUITO.md`, `scripts/tray/`, `ROADMAP.md` (R08-R12) | `diligencia.git` + `openchamber.git` |

### Reglas de convivencia

- 🔵 **No toca** `skills/diligencia-consejo/`, `skills/diligencia-circuito/`, ni código de tray.
- 🟣 **No toca** `CBP.md`, `doctor.md`, `version.md`, ni guías de metodología. Los lee, no los modifica.
- **Antes de /CBP**: `git fetch && git log --oneline origin/master -3`. Si el otro rol commiteó, `git pull --rebase` primero.
- **AGENTS.md y ROADMAP.md**: compartidos. Cada rol actualiza solo su sección.
- **CHANGELOG.md**: cada rol escribe sus propias entradas de versión.
- 🟣 El rol Chamber maneja además `C:\Users\jlemo\OneDrive\Desktop\openchamber\` (fork de btriapitsyn/openchamber).

### Cartas de nacimiento

| Rol | Acta |
|---|---|
| 🔵 Circuito | `doc/IDENTIDAD-CIRCUITO.md` — propósito, foco, ritual /CBP, no-tocar |
| 🟣 Chamber | `doc/IDENTIDAD-CHAMBER.md` — propósito, dos repos, agentes, tray, skills |

## Idioma

Español — todas las respuestas del agente deben ser en español. Si el agente contesta en inglés, recordarle explícitamente que responda en español.

Emojis: permitidos y recomendados en todo tipo de comunicación y documentación. Diligencia es plural — usa emojis para mejorar la claridad visual y reducir la barrera de entrada para usuarios no expertos. ✅🔴🟡🟢📋🩺🔬📦⚠️

---

## Mapeo de rutas

| Variable | Ruta | Descripción |
|---|---|---|
| $ROADMAP | `ROADMAP.md` | Roadmap de Diligencia |
| $CHECKLIST | `CHECKLIST.md` | Checklist de tareas |
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
| $PROYECTOS | `"C:\xampp\htdocs\+RM","C:\xampp\htdocs\MarketAI","C:\xampp\htdocs\conquisitare","C:\xampp\htdocs\buenobonitobarato","C:\xampp\htdocs\nemesis"` | 5 proyectos activos adaptados a Diligencia |
| $PROPAGAR_LOG | `doc/arch/propagaciones.md` | Log de propagaciones de Diligencia a proyectos |
| $STACK | *(definido en HARNESS.md)* | Stack tecnológico del proyecto (runtime) |
| $PROJECT_NAME | *(del header DILIGENCIA.md)* | Nombre del proyecto para reportes |
| $UX_CHECK | `doc/arch/ux-check.md` | Checklist de validación manual post-implementación |

## Comandos globales heredados — 36 fundamentales

| Comando | Descripción | Tipo |
|---|---|---|
| /adaptar | Adaptar proyecto a estructura Diligencia | Declarativo |
| /plan | Planificar tarea o grupo de tareas (ola) con sub-fases y conflictos | Declarativo |
| /commit | Git add + commit formateado | Procedural |
| /pushgh | Push a GitHub según $REPO (via /CBP) | Procedural |
| /health | Verificar sintaxis y consistencia | Declarativo |
| /reportar | Reportar bug o incidente en el tracker correspondiente | Declarativo |
| /deprecar | Deprecar archivos/comandos/estructuras obsoletas | Declarativo |
| /debug | Análisis profundo | Declarativo |
| /diligencia-check | Validar estructura Diligencia del proyecto | Declarativo |
| /doctor | Cuidado integral: estructura + código + tracking + circuito + limpieza + deprecación | Declarativo |
| /legal | Verificar y aplicar buenas prácticas legales (LICENSE, NOTICE, SECURITY, SPDX) | Declarativo |
| /limpiar | Limpiar temporales | Procedural |
| /estado | Reporte rápido del proyecto | Declarativo |
| /explica | Explicar concepto en formato directo (→/📄/⚠️/🧭) | Declarativo |
| /rm | Revisar ROADMAP: top 10 tareas con impacto y sub-fases | Declarativo |
| /next | Plan de ejecución por olas: agrupa tareas sin dependencias cruzadas + sub-fases | Declarativo |
| /consejo | Consultar al consejero sobre dudas o ideas del proyecto | Declarativo |
| /circuito | Revisar integridad lógica y UX (handlers, rutas, navegación) | Declarativo |
| /+rm | Agregar item al ROADMAP | Declarativo |
| /+guia | Crear guía nueva en doc/guias | Declarativo |
| /updoc | Actualizar documentación completa | Declarativo |
| /upguia | Actualizar guía existente | Declarativo |
| /+mec | Crear documento desde template | Declarativo |
| /upmec | Actualizar documento existente | Declarativo |
| /backup | Backup pre-edit genérico | Procedural |
| /backupall | Zip completo del proyecto | Procedural |
| /foco | Enfocar agente en área específica | Declarativo |
| /version | Cerrar sesión: bump + updoc + commit | Declarativo |
| /report | Reporte consolidado | Declarativo |
| /head | Preparar edición de sección en archivo | Declarativo |
| /reanudar | Recuperar sesión tras interrupción brusca | Declarativo |
| /salud | Reporte de salud del proyecto (BUILD* via /CBP) | Declarativo |
| /informe-salud | Reporte de salud inter-proyecto (escanea $PROYECTOS) | Declarativo |
| /propagar | Propagar actualizaciones de Diligencia a proyectos adaptados | Declarativo |
| /mutacion | Absorber mutaciones de un proyecto adaptado | Declarativo |
| /revision | Revisar mutaciones del proyecto y generar reporte | Declarativo |

## Focus
- Documentar la metodología
- Mantener coherencia entre componentes
- Evolucionar el estándar

## Disciplina BUILD

BUILD = aplicar cambios, NO commitear. Solo /commit, /CBP y /version ejecutan git commit.
Al terminar cualquier BUILD en este proyecto, reportar cambios aplicados y sugerir /CBP.

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
| `/checklist` | 2026-06-26 | Usar `/rm` (inconsistencias CHECKLIST↔RM) y `/next` (priorización) — funcionalidad redistribuida |

## Archivos relacionados
- `.opencode/HARNESS.md` — configuración de harness, test y lint
- `doc/guias/ESTANDAR-COMANDOS.md` — estándar de formato de comandos
