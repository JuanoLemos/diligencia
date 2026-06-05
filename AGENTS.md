# AGENTS.md — Diligencia

Documentación de la metodología de estructura estándar para proyectos OpenCode.

---

## Mapeo de rutas

| Variable | Ruta | Descripción |
|---|---|---|
| $ROADMAP | `ROADMAP.md` | Roadmap de Diligencia |
| $CHECKLIST | `CHECKLIST.md` | Checklist de tareas |
| $CHANGELOG | `CHANGELOG.md` | Historial de versiones |
| $GUIAS | `doc/guias/` | Guías de uso |
| $GUIAS_TEMPLATE | `doc/guias/_template.md` | Plantilla de guía |
| $ARCH | `doc/arch/` | ADRs y arquitectura |
| $TEMPLATE_DIR | `~/.config/opencode/templates/doc-base/` | Template base |
| $GLOBAL_COMMANDS | `~/.config/opencode/commands/` | Comandos globales |
| $RM | `ROADMAP.md` | Alias de $ROADMAP |
| $COMMANDS_DIR | `.opencode/commands/` | Comandos locales del proyecto |
| $HARNESS | `.opencode/HARNESS.md` | Configuración de harness (test, lint, skills, stack) |
| $BUGS | `doc/arch/bugs.md` | Bug tracker (P1/P2/P3, severidad, estado) |
| $INCIDENTS | `doc/arch/incidentes.md` | Incidentes runtime y crashes |
| $TESTING | *(definido en HARNESS.md)* | Comando de test del proyecto |

## Comandos globales heredados — 34 fundamentales

| Comando | Descripción | Tipo |
|---|---|---|
| /adaptar | Adaptar proyecto a estructura Diligencia | Declarativo |
| /plan | Planificar en modo PLAN | Declarativo |
| /commit | Git add + commit formateado | Procedural |
| /health | Verificar sintaxis y consistencia | Declarativo |
| /bug | Reportar bug en el proyecto | Declarativo |
| /deprecar | Deprecar archivos/comandos/estructuras obsoletas | Declarativo |
| /debug | Análisis profundo | Declarativo |
| /diligencia-check | Validar estructura Diligencia del proyecto | Declarativo |
| /doctor | Cuidado integral: estructura + código + tracking + limpieza + deprecación | Declarativo |
| /limpiar | Limpiar temporales | Procedural |
| /estado | Reporte rápido del proyecto | Declarativo |
| /explica | Explicar concepto breve y sencillo | Declarativo |
| /checklist | Revisar CHECKLIST + ROADMAP | Declarativo |
| /rm | Revisar ROADMAP por área | Declarativo |
| /next | Próximos 5 pasos según CHECKLIST | Declarativo |
| /qa | Revisión cruzada de calidad | Declarativo |
| /+rm | Agregar item al ROADMAP | Declarativo |
| /+guia | Crear guía nueva en doc/guias | Declarativo |
| /+pend | Agregar pendiente genérico | Declarativo |
| /updoc | Actualizar documentación completa | Declarativo |
| /upguia | Actualizar guía existente | Declarativo |
| /+mec | Crear documento desde template | Declarativo |
| /upmec | Actualizar documento existente | Declarativo |
| /+rmi | Agregar ítem a $RM | Declarativo |
| /backup | Backup pre-edit genérico | Procedural |
| /backupall | Zip completo del proyecto | Procedural |
| /foco | Enfocar agente en área específica | Declarativo |
| /news | Leer y distribuir $NEWS_FILE | Declarativo |
| /version | Cerrar sesión: bump + updoc + commit | Declarativo |
| /report | Reporte consolidado | Declarativo |
| /apply | Aplicar handoff file a código | Declarativo |
| /head | Preparar edición de sección en archivo | Declarativo |
| /incidente | Registrar incidente o crash runtime | Declarativo |
| /notify | Toggle de notificación remota | Procedural |
| /reanudar | Recuperar sesión tras interrupción brusca | Declarativo |
| /salud | Reporte de salud del proyecto (BUILD* via /CBP) | Declarativo |

## Focus
- Documentar la metodología
- Mantener coherencia entre componentes
- Evolucionar el estándar
