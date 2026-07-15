# CHANGELOG — Diligencia

---

## [2.7.2] — 2026-07-15

### Changed
- R5/R9 corregidas: agentes pueden ejecutar /CBP en cualquier forma (commit, version, full)
- R11/R12/R13 agregadas: disciplina multi-chat, backup pre-push, verificacion post-pull
- adaptar.md global sincronizado a v2.7.1 (estaba en v2.6.6)
- /ola copiado a ~/.config/opencode/commands/ — disponible globalmente para todos los proyectos

### Fixed
- @circuito actualizado a R1-R10 (reglas de paloma removidas)
- @consejero y @documentador sincronizados via /subadaptar
- COMANDOS.md: /ola correctamente insertado, circuitos actualizados

## [2.7.1] — 2026-07-04

### Removed
- /propagar deprecado a .old/commands/
- /paloma deprecado a .old/commands/ + arch/ + mecánicas
- Chamber: DiligenciaCommandBar, PalomaPanel, commands.ts eliminados (paso a .deprecated)
- Paloma circuit y referencias removidas de COMANDOS.md

### Added
- GUIA_RED_LOCAL.md — conexión SSH entre PCs Windows en red local
- R71: conexión remota SSH registrada en ROADMAP

### Fixed
- COMANDOS.md: /ola insertado correctamente en tabla Invocación, circuitos corregidos
- COMANDOS.md MarketAI: sincronizado v2.7.0
- /adaptar Flujo C: nueva Fase 2.5.6 — sincronización de guías de referencia

### Changed
- R10: /adaptar solo lo ejecuta el usuario (regla para agentes autónomos)
- AGENTS.md: comandos 31 → 32, Modelo Agentes Autónomos reescrito

## [2.7.0] — 2026-07-04

### Added
- Sistema de oleadas (olas): MECANICA-OLAS.md con wave manifest, reglas OnFail (skip/retry/escalate/fallback). /ola planear/ejecutar/estado. doc/olas/_template.md. R45 completado.

### Changed
- R45 actualizado: /ola sistema de oleadas completado
- COMANDOS.md: +/ola command reference
- 32 comandos fundamentales (+1: /ola)

## [2.6.8] — 2026-07-04

### Changed
- Modelo Agentes Autonomos: R1-R6 reescrito para editar/commit directo en proyecto asignado
- 5 agentes especializados: permisos edit:allow + git
- Palomas redefinidas: ahora auditoria cruzada + dashboard, no reporte primario

### Removed
- 4 agentes benchmark-* archivados a .old/
- @design-system unificado en @disenador

### Fixed
- +R9: agentes recuerdan /CBP tras BUILD

## [2.6.7] — 2026-07-04

### Added
- +6 agentes especializados por dominio (R70): @narrador, @game-designer, @trader, @cartografo, @editor-video, @design-system
- COMANDOS.md: seccion AGENTES completa con subcomandos y circuitos de calidad

### Fixed
- COMANDOS.md: flags faltantes --descartar y --pendiente agregados
- AGENTS.md: 30 -> 31 comandos fundamentales
- skills/diligencia-docs: conteo 28 -> 31 (evitaba falsos positivos en /documentar)
- GUIA_CHAMBER.md: 28 -> 31 comandos

### Changed
- COMANDOS.md: tablas, emojis y jerarquia visual mejorada
- MECANICA-TASK-ROUTER.md: +6 nuevas filas de ruteo
- ROADMAP.md: R70 completado

## [2.6.6] — 2026-07-04

### Added
- /agentes-sync Fase 1: sincroniza referencias de mecanicas/guias en agentes globales
- /agentes-sync Fase 2: escanea $PROYECTOS por desviaciones estructurales no reportadas
- catalogo-proyectos.md actualizado a v2.6.5 con datos reales y columnas de revision

## [2.6.5] — 2026-07-04

### Changed
- propagaciones: 5 proyectos actualizados a Diligencia v2.6.4 (+RM, MarketAI, conquisitare, BBB, nemesis)
- AGENTS.md: R7 — MAIN pasa respuestas de agentes textualmente
- AGENTS.md: R8 — MAIN muestra decisiones/veredictos en chat
- MECANICA-TASK-ROUTER.md: enrutador tarea → agente → modelo → API

## [2.6.4] — 2026-07-01

### Fixed
- CI/CD: remove CHECKLIST.md from diligencia-check.yml (file deprecado a .old/)
- ADR-003: remove CHECKLIST.md from standard structure tree
- Template doc-base: same fix for future projects

### Changed
- /salud post-v2.6.3: status-salud.md regenerated (v2.6.3)

## [2.6.3] — 2026-07-01

### Fixed
- P2: PalomaPanel.tsx — `cols[7]` → `cols[10]` (columna Estado rota al agregar triage)
- P3: paloma.md — agregados modos `--descartar` (📝→🗑️) y `--pendiente` (🟡→📬)
- P3: palomas.md — separador tabla corregido (columna extra)
- P3: AGENTS.md — agregada variable `$PALOMA_MAIN_PLAN`

### Added
- GUIA_HOSTING_VPS.md — guía completa de deploy VPS ($PROYECTOS + Chamber)
- paloma-@documentador-P003.md — renombrado (faltaba @ en nombre)

### Changed
- INDEX.md: agregados bugs.md, incidentes.md, backups.md, propagaciones.md, paloma-main-plan.md
- INDEX.md: removida referencia stale a CHECKLIST.md
- GUIA_HOSTING_VPS.md: header con versión v1.0

## [2.6.2] — 2026-07-01

### Changed
- propagaciones: 6 proyectos actualizados a Diligencia v2.6.1 (+RM, MarketAI, conquisitare, buenobonitobarato, nemesis, OpenMontage-main)
- OpenMontage: propagaciones.md local registrada

## [2.6.1] — 2026-07-01

### Added
- doc/arch/paloma-template.md — template estándar para palomas individuales (resumen ejecutivo, prioridad ordenada, cocinado P1 obligatorio, checklist)

### Changed
- `.opencode/commands/paloma.md`: +4 modos de acción (--aplicar, --revisar, --archivar, --reabrir)
- `doc/arch/palomas.md`: +3 columnas de triage (Archivos afectados, Estimación, Urgencia)
- INDEX.md: palomas.md + paloma-template.md agregados al catálogo

## [2.6.0] — 2026-07-01

### Added
- MECANICA-LLM.md — patrón multi-proveedor LLM (factory, provider-agnostic, 12 providers catalogados, estrategia híbrida)
- Chamber mechanic-aware: parser DILIGENCIA.md, store Zustand, comandos filtrados por mecánicas, PalomaPanel per-project
- @disenador — agente UI/UX con MiniMax M3 + image-01 (auditoría Crucix: 15 hallazgos, 4 P1)

### Changed
- MECANICA-MEMORY.md v1.0 → v2.0: 3 subsistemas (claude-mem + MemoryManager + Delta), heredado de Crucix-master
- ROADMAP: R21 completado (P2), R68 agregado (MECANICA-LLM)
- INDEX.md: nuevas mecánicas listadas

## [2.5.0] — 2026-07-01

### Added
- codebase-memory-mcp adaptación completa — Fase1-4 + 7 proyectos indexados + MCP en system prompts
- Ola 1 — template paloma-plan + $PALOMAS + publish P004 validado
- /paloma --new (paloma-plan) + --publish + estado 📝 Plan + flujo completo
- /paloma guarda archivo paloma-AGENTE-PNNN.md completo (persistencia)
- circuito paloma completo — --news + R1-bis + paloma-main-plan.md
- sistema de estado para palomas — 📬 Pendiente / 🟡 Revisión / ✅ Actuado / 🗑️ Ignorado
- @documentador modo cocinado — paloma incluye contenido listo para aplicar
- /paloma + NOTICE + SECURITY + palomas.md + @documentador local y global
- @disenador — agente UI/UX con MiniMax M3 + image-01

### Fixed
- /paloma --news — bash allow + parsing + bloque parseable

### Changed
- P003 @documentador — manifiesto, identidad, niveles de madurez, README + paloma completa
- refinar manifiesto, deprecar CHECKLIST y mejorar palomas
- LICENSING.md — corregido→reportado por @documentador, aplicado desde MAIN
- Modelo Paloma Mensajera — reglas MAIN↔AGENTE + paloma (reporte estructurado)
- R57/R58/R59 — agente auto-mejora + multi-chat MAIN↔AGENTE + Gran Orquestador
- README.md actualizado — v2.4.2, proyectos reales, 29 comandos, 6 agentes, AGPL-3.0
- Benchmark MiniMax vs DeepSeek en doc/arch/benchmark-minimax-vs-deepseek.md
- ROADMAP: R50-R67 actualizados con benchmark + @diseñador + multimodal por proyecto

## [2.4.2] — 2026-06-28

### Fixed
- /propagar: ignorar UPDATE-AVAILABLE.md en chequeo de WT para no bloquear /adaptar
- /propagar + /adaptar: post-upgrade limpia UPDATE-AVAILABLE.md + registra en CHANGELOG del proyecto

### Changed
- 6 proyectos adaptados a v2.2.0 (+RM, MarketAI, conquisitare, buenobonitobarato, Nemesis, OpenMontage)
- catálogo de proyectos actualizado con nuevas versiones

## [2.4.1] — 2026-06-28

### Fixed
- CBP dispatch: WT limpio + commits pendientes ya no ofrece "commit" como opción. Ahora sugiere "version" directo y solo muestra version/full/abortar en question()
- /commit: paso 0 — detecta commits sin versionar y guía al usuario hacia /version
- /version pre-flight: alertas P2/P3 son advertencias, no bloqueos. Solo P1 bloquea

## [2.4.0] — 2026-06-28

### Added
- `@documentador` integrado al 100%: +Worker 5 en CBP full, +fase en Ola1, +check g pre-flight /version, +paso 9.6 post-bump
- `@documentador` +4 checks IDENTIDAD PÚBLICA (24 checks, 6 categorías): README vigente, proyectos activos, identidad pública, docs comunitarios
- `/consejo --explorar <url>` — explora repos GitHub y fuentes externas para proponer mejoras
- CBP dispatch: ahora detecta WT limpio + commits pendientes y sugiere "version path"

### Changed
- CBP dispatch: opción "version" agregada al question() — `/CBP version` ahora es camino explícito
- ROADMAP: R55→✅ (documentador), R54→🟡 (consejero explorer)

## [2.3.0] — 2026-06-28

### Added
- `@documentador` — skill `diligencia-docs` con 20 checks en 5 categorías (estructura, legal, docs, tracking, comandos)
- `/documentar` — comando de auditoría documental con flags `--legales`, `--estructura`, `--docs`, `--tracking`, `--comandos`
- `/documentar --legales` — absorbe `/legal` como subcomando (ahora deprecado)
- `/salud` Fase 1i — auditoría documental vía @documentador (reemplaza Fase 1h legal)
- ADR-004: M6 — Chamber pertenece a Diligencia
- ADR-005: Fusión de comandos 39→28
- ADR-006: /doctor→/salud por conflicto OpenCode
- ROADMAP: R53 (tray template), R54 (consejero explorer), R55 (documentador)
- R55: 🟡 @documentador en progreso

### Changed
- /rm y /next: recordatorio de validación UX ($UX_CHECK) antes de planificar
- ROADMAP.md: header con v2.2.3, fecha 2026-06-28, stack con 6 proyectos reales, "Ahora" con items en progreso, Completado con v1.19→v2.2.3
- ADR_SUMMARY.md: header con versión, +3 ADRs (004-006), estadísticas 6/6
- INDEX.md: PENDING.md registrado, ADR-004/005/006 registrados, fecha global actualizada
- AGENTS.md: 28→29 comandos fundamentales (+/documentar)
- COMANDOS.md: CUIDAR 5→6

### Removed
- `/salud` deprecado → renombrado de vuelta (era el absorbido por /doctor, ahora es el nombre activo tras /doctor→/salud)

## [2.2.3] — 2026-06-27

### Changed
- `/doctor` renombrado a `/salud` por conflicto con OpenCode nativo (archivos: CBP.md, salud.md, estado.md, informe-salud.md, updoc.md, AGENTS.md, COMANDOS.md)
- M6 — Chamber pertenece a Diligencia: identidad actualizada, `$CHAMBER` variable registrada, mandato agregado
- v2.2.2 documentado como Stable Chamber baseline (tray + toolbar funcionales)
- ROADMAP: R25/R37/R38/R47/R51→✅ completados, R35→🗑️ deprecado
- CHECKLIST Dashboard actualizado a v2.2.2 con 15/15 versiones

## [2.2.2] — 2026-06-26 — Stable Chamber baseline

### Added
- R47 — Diligencia Command Toolbar en Chamber (5 verbos, dropdown, sendCommand)
- R52 — estudio de hosting + administración de proyectos en producción
- M6 — Chamber pertenece a Diligencia (identidad + $CHAMBER variable)
- Tray: menú con Rebuild UI + Reiniciar + Rebuild + Abrir Dev HMR (5173)

### Fixed
- DiligenciaCommandBar: getSessionModelSelection en vez de getLastUserChoice
- DiligenciaCommandBar: toast.warning() en vez de toast() directo
- Tray: Stop-Chamber + Start-Chamber restaurados a versiones estables
- Tray: "Abrir Chamber" abre navegador (sin Brave PWA)

### Added
- R47 — Diligencia Command Toolbar en Chamber (5 verbos, dropdown, sendCommand)
- R52 — estudio de hosting + administración de proyectos en producción

## [2.2.1] — 2026-06-26

### Changed
- R48 ✅ — /propagar marcado como completado en ROADMAP
- R38 — guías de Chamber creadas (GUIA_DILIGENCIA_CHAMBER + GUIA_CHAMBER)
- R37 — badges BETA + license + version agregados a README
- R51 — iconos SVG personalizados por proyecto (7 colores únicos)
- openchamber: upgrade v1.18.1→v2.2.0 (comandos sync, $PROPAGAR_LOG, $UX_CHECK)
- OpenMontage-main: integrado al ecosistema (6° proyecto en $PROYECTOS)
- Nemesis: DILIGENCIA.md recreado

## [2.2.0] — 2026-06-26

### Added
- `/doc` — unifica /+guia, /upguia, /+mec, /upmec en un solo comando (--tipo guia|mecanica, --crear|--actualizar)
- `/commit --push` — push integrado en commit, elimina /pushgh
- `/backup --all` — zip completo del proyecto, elimina /backupall
- `$UX_CHECK` → `doc/arch/ux-check.md` — checklist de validación manual post-implementación
- `/doctor` Fase 1h (legal) + Fase 3h (salud) — absorbe /legal y /salud
- R49 — UX panel interactivo en Chamber por proyecto

### Changed
- `/rm`: top 10 tareas con impacto (Alto/Medio/Bajo) y sub-fases ejecutables
- `/next`: plan por olas (waves), agrupa tareas sin dependencias cruzadas, usa @consejero
- `/plan`: soporta `--ola N` (grupo de tareas) con detección de conflictos y sub-fases
- `/explica`: nuevo template compacto (→/📄/⚠️/🧭), eliminado el label "En criollo"
- `/doctor`: genera status-salud.md automáticamente en Fase 3h (hereda de /salud)
- `/doctor`: verifica documentos legales en Fase 1h (hereda de /legal)
- `/commit`: +paso 8 push post-commit (hereda de /pushgh)
- `/backup`: +funcionalidad --all (hereda de /backupall)
- `/version`: paso 9.5 UX CHECK — sugiere validar tras BUILD
- `COMANDOS.md`: 8 grupos → 5 grupos por acción (✏️ CREAR / 📋 PLANIFICAR / ⚡ EJECUTAR / 🔍 REVISAR / 🛡️ CUIDAR)
- `AGENTS.md`: 39→28 comandos, todos los deprecados reorganizados
- `CBP.md`: /salud y /pushgh eliminados del circuito (absorbidos por /doctor y /commit)

### Removed
- `/apply` — redundante con herramientas de edición directa
- `/bug`, `/incidente` → `/reportar`
- `/checklist` → `/rm` + `/next`
- `/salud` → `/doctor`
- `/pushgh` → `/commit --push`
- `/report` → `/estado --full`
- `/backupall` → `/backup --all`
- `/legal` → `/doctor`
- `/+guia`, `/upguia`, `/+mec`, `/upmec` → `/doc`

## [2.1.1] — 2026-06-26

### Changed
- `$PROYECTOS` configurado con 5 proyectos activos (+RM, MarketAI, conquisitare, buenobonitobarato, Nemesis)
- `catalogo-proyectos.md`: versión Diligencia actualizada, métricas ajustadas
- `COMANDOS.md` creado — tabla compacta por categorías para panel lateral de Chamber
- `MECANICA-PROPAGACION.md` creada — documenta el flujo completo de propagación
- `CHECKLIST.md`: Dashboard actualizado a v2.1.0

## [2.1.0] — 2026-06-26

### Added
- `/propagar` — comando PLAN→BUILD para propagar actualizaciones de Diligencia a proyectos adaptados detectando versiones atrasadas, escribiendo `UPDATE-AVAILABLE.md`, y ofreciendo `/adaptar` Flujo C por proyecto
- `/version` paso 9 (post-bump) — detecta proyectos en `$PROYECTOS` con versión anterior y sugiere `/propagar`
- `$PROPAGAR_LOG` → `doc/arch/propagaciones.md` — log de propagaciones
- `/circuito`, `/consejo`, `/mutacion`, `/revision`, `deprecados.md`, `PENDING.md` — 6 archivos globales copiados a `.opencode/commands/`

### Changed
- `AGENTS.md` (2026-06-26): roles de sesión — Circuito + Chamber con cartas de nacimiento y reglas de convivencia
- `AGENTS.md`: tabla de comandos 38→39 fundamentales (+`/propagar`, `/mutacion`, `/revision`)
- `ROADMAP.md`: +R48 — mecanismo de propagación semiautomático (`/version` sugiere, `/propagar` ejecuta)
- 6 comandos locales sincronizados con globales: checklist, doctor, explica, next, plan, rm

### Fixed
- Calidad documental: `PENDING.md`, `mutaciones-consolidadas.md` — headers con versión + cross-refs agregados
- Calidad documental: `status-salud.md` — doble `—` en header corregido

## [2.0.0] — 2026-06-26

### Added
- `@consejero` — agente de decisión que revisa trayectoria de proyecto con 6 preguntas (supuestos, dominio, roadmap, deuda, mandato, aprender). Read-only, no codea.
- `@circuito` — agente de integridad lógica y UX con 8 checks (handlers vacíos, callejones, rutas huérfanas, fetch sin endpoint, estados no manejados, navegación rota, consistencia UX, feedback faltante). Read-only.
- `/consejo` — comando standalone para consultar al consejero sobre dudas o ideas del proyecto
- `/circuito [area]` — comando standalone para revisar integridad lógica y UX
- `diligencia-consejo` skill — checklist del consejero cargable por `/plan`, `/next`, `/RM`, `/checklist`, `/explica`, `/consejo`
- `diligencia-circuito` skill — checklist de 8 verificaciones cargable por `/circuito` y `/doctor` Fase 1g
- `MECANICA-CONSEJO.md` — mecánica completa del consejero: flujo, 6 preguntas, integración con comandos, anti-patrones
- `MECANICA-CIRCUITO.md` — mecánica completa de integridad lógica: 8 checks, flujo, integración con /doctor
- `/doctor` Fase 1g (Circuito lógico) — diagnóstico automático de handlers, rutas, navegación, UX en cada /doctor
- `/doctor` Fase 3g (Circuito) — registro de hallazgos de circuito como bugs P2/P3 en $BUGS + CHECKLIST

### Changed
- `/plan` — +paso Consejero pre-BUILD: carga skill, aplica 6 preguntas, agrega sección "Observaciones del Consejero"
- `/next` — +sección "Priorización estratégica (Consejero)" con orden real, deuda y recomendación
- `/RM` — +sección "Análisis de trayectoria (Consejero)" con fases salteadas e items stale
- `/checklist` — +sección "Deuda detectada (Consejero)" con bugs, ADRs y fases incompletas
- `/explica` — +4ª capa "Implicancia estratégica" para conectar conceptos con decisiones de proyecto
- AGENTS.md: 34→36 comandos fundamentales (+/consejo, +/circuito). Tabla de comandos actualizada con descripciones extendidas.
- HARNESS.md: skills locales de "ninguna" → 7 skills listadas. Versión 1.0.0→2.0.0.
- INDEX.md: +3 mecánicas v1.18.0 (CONTEXTO, GRAPHIFY, MEMORY). +2 mecánicas v2.0.0 (CONSEJO, CIRCUITO). Skills count 5→7. 24 archivos catalogados.
- MECANICA-CBP.md: tabla de agentes sugeridos actualizada con @consejero y @circuito.
- **LICENSE**: GPL-3.0 → AGPL-3.0 (copyleft más fuerte, cubre uso en red)
- **MANIFIESTO.md** creado: contrato social con 6 principios para quien adapte o redistribuya
- `README.md`, `CONTRIBUTING.md`, `doc/guias/GUIA_LEGAL.md`: actualizadas referencias de licencia

### Fixed
- INDEX.md: 3 mecánicas de v1.18.0 nunca registradas (MECANICA-CONTEXTO, GRAPHIFY, MEMORY)
- INDEX.md: 2 skills nuevas sin catalogar (diligencia-consejo, diligencia-circuito)
- PENDING.md: limpiada entrada de política emojis (2026-06-23) — procesada en este bump

### Removed
- `MECANICA-CIRCUITO.md` legacy (renombrado a MECANICA-CBP.md en v1.15.2) — reemplazado por nueva mecánica de integridad lógica

## [1.19.0] — 2026-06-25

### Added
- R34 — 5 skills Diligencia (cbp, health, docs, workflow, commands) para Chamber Skills Catalog
- Catalogo-proyectos.md — mapa completo de 7 proyectos adaptados
- backup-all.ps1 — script de backup de todos los proyectos
- ROADMAP R45-R47: /next --plan, audit Chamber, integración comandos UI
- OldWorld agregado como candidato a adaptar

### Changed
- AGENTS.md — identidad definida (Diligencia ≠ Chamber, gobierno de proyectos)
- R46 ✅ — audit Chamber completado (9 herramientas mapeadas)
- Fases 2-4: 6/6 proyectos activos actualizados a v1.18.1
- ROADMAP: R22-R47 items de planificación

## [1.18.0] — 2026-06-23

### Added
- MECANICA-CONTEXTO.md — modelo L0/L1/L2 (abstract, overview, detalle)
- MECANICA-GRAPHIFY.md — visualización de documentación como grafo
- MECANICA-MEMORY.md — memoria persistente con claude-mem
- templates/doc-base/.graphifyignore — ignorar node_modules, .opencode, .git
- GUIA_DE_BUENAS_PRACTICAS.md §13 (L0/L1/L2), §14 (graphify), §15 (claude-mem)
- ROADMAP R19, R20, R21

### Changed
- templates/doc-base/INDEX.md — +columna "Resumen (L0)" en todas las tablas
- MECANICA-DOCUMENTAL.md — +referencia a MECANICA-CONTEXTO
- Template `doc-base/LICENSE` actualizado a AGPL-3.0 (nuevos proyectos heredan AGPL)

### Deprecated
- `/+pend` — variable $PEND nunca definida, comando roto desde inicio (usar `/+rm`)
- `/+rmi` — variable $PEND nunca definida, comando roto desde inicio (usar `/+rm`)
- `/news` — sistema de distribución de novedades nunca usado
- `/notify` — variables $NOTIFY_SCRIPT/$NOTIFY_STATE nunca definidas
- `/qa` — variable $QA nunca definida

### Fixed
- `AGENTS.md`: agregadas variables faltantes $STACK y $PROJECT_NAME al Mapeo de rutas
- `AGENTS.md`: tabla de comandos corregida de 39 a 34 (5 deprecados removidos)
- `apply.md`: eliminada referencia a $NEWS_FILE (deprecado)
- `deprecar.md`: corregida referencia a $AGENTS (no existía como variable)
- Comandos /doctor y /health ahora tienen $STACK definido
- Comando /updoc ahora tiene $PROJECT_NAME definido
- `SECURITY.md` template actualizado con mejoras de Scope, Out of Scope, subject line y PoC
- `NOTICE` de Crocix-master: placeholders reemplazados por datos reales

### Changed (doc sync)
- `doc/guias/GUIA_DE_COMANDOS.md`: limpiadas referencias a comandos deprecados
- `doc/guias/GUIA_REFERENCIA_RAPIDA.md`: limpiadas referencias a comandos deprecados
- `doc/guias/GUIA_DE_INFORMES.md`: removidas referencias a $NEWS_FILE y comandos deprecados
- `doc/arch/status-salud.md`: removida línea de $NEWS_FILE
- `ROADMAP.md`: agregados items R12-R16 de auditoría de variables y comandos

## [1.17.7] — 2026-06-06

### Added
- 3 themes (naranja, verde, celeste) en templates/doc-base/.opencode/themes/
- Instrucción BUILD en opencode.jsonc: "nunca ejecutes git commit durante BUILD"

### Changed
- GUIA_THEMES.md: tabla actualizada con los 8 variants totales

## [1.17.6] — 2026-06-06

### Fixed
- commit workflow: ahora invoca `/commit` en vez de `git add -A` + `git commit` inline (bypasseaba validación Conventional Commits)
- parcial: ahora tiene Meta-PLAN ligero con confirmación entre PLAN y BUILD (antes ejecutaba BUILD* sin Meta-PLAN previo)
- version: doble confirmación eliminada (Meta-PLAN muestra CHANGELOG y pregunta una vez)
- Steps 6→8 → Steps 6→12 en todas las referencias de CBP.md (cubría pasos 9-12)
- doctor.md: bucle autoreferencial `/CBP doctor → /CBP doctor` corregido

### Added
- MECANICA-FLUJO.md — documentación completa del circuito con 5 secciones, tabla de reglas 19×6 y gaps

## [1.17.5] — 2026-06-06

### Added
- Guarda BUILD anti-commiteo: banner en CBP.md (updoc, doctor, full) — "BUILD = aplicar cambios, NO commitear"
- Fase 1 paso 5 en /adaptar — verifica que AGENTS.md tenga la sección "Disciplina BUILD" y la agrega si falta
- Sección "Disciplina BUILD" en templates/doc-base/AGENTS.md (nuevos proyectos la heredan)
- Sección "Disciplina BUILD" en AGENTS.md de Diligencia

### Changed
- Proyecto ajenos (Regla #19): ahora cualquier acción de git requiere confirmación explícita
- Todo BUILD termina con "cambios aplicados, Ejecutá /CBP para commitear" (no más commits directos)

## [1.17.4] — 2026-06-06

### Added
- `/adaptar` Fase 2.5.5 — sincroniza themes de doc-base a `.opencode/themes/` del proyecto
- 5 variantes Diligencia disponibles vía `/theme` en TUI

### Changed
- `GUIA_THEMES.md`: ruta `/theme` actualizada (los temas se eligen por proyecto, en la TUI)

## [1.17.3] — 2026-06-06

### Changed
- `/explica` reescrito a formato 3 capas: En criollo (qué es, para qué sirve), Técnico (archivo, comando), Impacto (costo/beneficio)

### Discipline fix
- Toda BUILD que edite comandos globales debe registrar en PENDING.md — el circuito lo detecta vía Paso 0f

## [1.17.2] — 2026-06-06

### Added
- `version.md`: reescrito a modelo git-log — CHANGELOG auto-generado desde commits Conventional Commits
- `CBP.md` dispatch: detecta cambios staged + unstaged + **commiteados** (`git diff HEAD` + `git log <release>..HEAD`)
- `CBP.md` Workers 1/3/4: `git diff --stat <last-version>` con fallback a `git log` (ya no fallan si hubo commits)

### Fixed
- `CBP.md` dispatch: ya no reporta "nada que procesar" si el usuario commiteó cambios pero no los versionó
- `updoc.md` Fase G: fallback robusto para detectar .md sin tag de versión (`git log HEAD~20`)

## [1.17.1] — 2026-06-06

### Added
- PENDING.md — archivo de registro de cambios globales pendientes de versionar

### Changed
- `/adaptar` Finalización: ya no commitea ni pushea. Solo stagea archivos Diligencia y sugiere `/CBP`
- CBP Paso 0f: reemplazada comparación por timestamps por lectura de PENDING.md (robusto contra commits)

### Fixed
- Regla #17: solo `/commit`, `/CBP` y `/version` pueden ejecutar git commit (el resto solo aplica cambios)
- GUIA_DE_BUENAS_PRACTICAS.md §1: fila "Commit" agregada en tabla de disciplina de sesión

## [1.17.0] — 2026-06-06

### Added
- `/informe-salud` — configuración automática de $PROYECTOS en primer uso (Paso 0, R02)
- `/estado` — recomendaciones proactivas según working tree (8 condiciones, R03)
- `/estado --full` — dashboard unificado: git log -15, salud, bloqueos (absorbe /report, R04)
- `/estado --update [file]` — persistir reporte a archivo
- `GUIA_THEMES.md` — personalización visual de OpenCode (themes built-in, custom JSON) (R07)
- `templates/doc-base/.opencode/themes/diligencia.json` — theme profesional TokyoNight-based
- CHECKLIST.md — grooming completo al estándar MECANICA-CALIDAD

### Changed
- `/report` deprecado → redirige a `/estado --full`
- `GUIA_ONBOARDING.md` — +§8 Personalización visual
- `CHECKLIST.md` — reescrito completo: dashboard actualizado, items históricos consolidados

### Fixed
- ROADMAP migrado a formato MECANICA-CALIDAD (R01-R07 completados)

## [1.16.7] — 2026-06-06

### Added
- `/adaptar` Fase 0: auto-elimina adaptar.md local stale al detectar que el global es más nuevo (el usuario dice "sí" a usar global y el archivo stale se borra automático)
- `/adaptar` Finalización: commit automático `chore: upgrade vX → vY` + push opcional a origin

## [1.16.6] — 2026-06-06

### Added
- `/adaptar` Fase 2.6 — verificación de calidad documental (MECANICA-CALIDAD): escanea todos los .md, migra ROADMAP de checklist a tabla, corrige headers/cross-refs/fechas no estándar
- `/CBP` dispatch dinámico — reemplazo de texto plano por `question()` con opciones clicables y descripciones

### Changed
- Regla #16 del orquestador: si se editan comandos globales que introducen cambios metodológicos, se DEBE bump version y documentar en el proyecto

## [1.16.5] — 2026-06-06

### Added
- `GUIA_LEGAL.md` — buenas prácticas legales: elegir licencia, headers SPDX, NOTICE, SECURITY.md, dual-licensing, disclaimer
- `GUIA_MULTI_REPO.md` — 4 patrones multi-repo: worktree testing (closefront), fork+upstream, submódulos, CI/CD deploy
- `MECANICA-WORKTREE.md` — mecánica de worktree testing dual-local: setup, sync, disciplina, automatización vía tray
- `MECANICA-CALIDAD.md` — estándares de calidad documental: ROADMAP con IDs/prioridades, estilo md, template conventions, autocheck
- `templates/doc-base/NOTICE` — template NOTICE (copyright holders, third-party deps)
- `templates/doc-base/SECURITY.md` — template de política de seguridad
- `/legal` — comando para verificar y aplicar buenas prácticas legales (39 comandos fundamentales)
- \$MECANICAS, \$MECANICAS_TEMPLATE, \$NEWS_FILE — variables agregadas a AGENTS.md

### Changed
- `templates/doc-base/ROADMAP.md` — reescrito a formato tabla estandarizada con IDs R01+, prioridad P1/P2/P3, dependencias
- `templates/doc-base/CHECKLIST.md` — expandido con tareas categorizadas
- `templates/doc-base/HARNESS.md` — +sección opcional `## Testing worktree`
- `GUIA_DE_BUENAS_PRACTICAS.md` — +§11 Calidad documental
- `AGENTS.md` — +`/legal`, contador 38→39

## [1.16.4] — 2026-06-06

### Added
- `GUIA_DE_INFORMES.md` — ecosistema de reportes: mapa de 8 comandos, flujo post-update, workflow semanal, gaps conocidos
- `META-ESCALABILIDAD.md` — mecánica de detección automática de camino en /CBP (commit/parcial/full)
- `_template.md` — plantilla de mecánica en `doc/mecanicas/`
- \$MECANICAS, \$MECANICAS_TEMPLATE, \$NEWS_FILE — variables agregadas a AGENTS.md

### Changed
- `CBP.md` — nuevo `## Despacho de entrada` con algoritmo de detección automática + 4 workers paralelos (docs/diag/ver/agt) en workflow `full`
- `CBP.md` — nuevos workflows `commit` y `parcial` (adaptación escalativa)
- `MECANICA-CBP.md` — diagrama + tabla de workflows actualizados con `commit`, `parcial`, y paralelismo
- `GUIA_DE_COMANDOS.md` §8 — +referencia a `GUIA_DE_INFORMES.md`
- `INDEX.md` — +GUIA_DE_INFORMES.md, +_template.md, +meta-escalabilidad.md
- `ROADMAP.md` — 3 items P1/P2 movidos a Completado; 2 P2 nuevos (config $PROYECTOS, +ayuda en worktree)

### Fixed
- `$NEWS_FILE` definido en AGENTS.md (archivo `design/report/news.txt` aún no creado)

## [1.16.3] — 2026-06-06

### Added
- `doc/guias/GUIA_ONBOARDING.md` — primeros pasos para usuarios primerizos de AI + OpenCode
- `/informe-salud` — comando de salud inter-proyecto: escanea $PROYECTOS y genera reporte consolidado con indicadores estructurales

### Changed
- Terminología provider-agnostic en `MECANICA-CBP.md`, `GUIA_DE_BUENAS_PRACTICAS.md`, `CBP.md`: `PRO`/`FLASH`/`DeepSeek` → `razonamiento`/`ejecución`/`modelo`
- `GUIA_ONBOARDING.md`: API key genérica (no hardcodeada a DeepSeek)
- 4 agentes SDD (~/.config/opencode/agents/): nota de adaptación para modelo configurable del proveedor

## [1.16.2] — 2026-06-05

### Added
- `/doctor` — Backup preventivo (Fase 1f) + paso de backup pre-corrección entre Fase 2 y Fase 3
- `$BACKUPS` → `doc/arch/backups.md`: log de backups con commit, versión, workflow y cantidad de archivos
- `$BACKUP_KEEP` en AGENTS.md: cantidad de backups a conservar (default 5), pruning automático
- Template `doc/arch/backups.md` en doc-base (externalizado para /adaptar)

### Changed
- `GUIA_ECOSISTEMAS.md`: /doctor ahora participa del ecosistema BACKUP (backup preventivo + log)
- Labels de 15 guías/mecánicas bump v1.16.0→v1.16.2 (sync post-backup feature)

## [1.16.1] — 2026-06-05

### Fixed
- Sanitizar paths hardcodeados en ADR-002.md y GUIA_DE_REVISION.md (proyectos privados, rutas locales)
- Redactar nombres de proyectos privados: Némesis→proyecto-alfa, MarketAI→proyecto-beta, closefront-io→proyecto-cliente

### Changed
- 'desarrollador' → 'orquestador' en CHANGELOG, CHECKLIST, ROADMAP, GUIA_ECOSISTEMAS

## [1.16.0] — 2026-06-05

### Added
- GitHub readiness: README.md, LICENSE (GPL-3.0), .gitignore, CONTRIBUTING.md, CODE_OF_CONDUCT.md
- CI workflow en `.github/workflows/diligencia-check.yml` para validación estructural en push/PR
- `doc/guias/GUIA_DE_CONTRIBUCION.md` — proceso formal para extender la metodología (guías, mecánicas, comandos, ADRs, templates)
- `doc/mecanicas/MECANICA-ENFORCEMENT.md` — documentación unificada del sistema de enforcement en 3 capas (runtime, pre-commit, CI/CD)
- INDEX.md actualizado con +1 guía y +1 mecánica

### Changed
- Bump v1.15.3 → v1.16.0: DILIGENCIA.md, template DILIGENCIA.md, adaptar.md

## [1.15.3] — 2026-06-05

### Added
- Idioma español como Buena Práctica — reforzado en `/adaptar` (templates AGENTS.md, HARNESS.md), GUIA_DE_BUENAS_PRACTICAS §10, y opencode.jsonc instructions
- Todas las respuestas del agente deben ser en español, con regla explícita de corrección si responde en inglés

### Changed
- Bump masivo de labels: 9 guías + 2 mecánicas v1.15.1 → v1.15.2
- identidad.md y MANDATO.md: ahora con label de versión v1.15.2

## [1.15.2] — 2026-06-05

### Changed
- `/circuito` renombrado a `/CBP` (Circuito de Buenas Prácticas) — archivo, cabeceras, y todas las referencias cruzadas
- `doc/mecanicas/MECANICA-CIRCUITO.md` → `MECANICA-CBP.md` + referencias actualizadas en guías, INDEX y templates
- `/CBP` sin argumentos: ahora ejecuta `completo` por defecto
- Bump masivo de labels: 10 guías + 2 mecánicas v1.15.0 → v1.15.1 (sync post-rename)

### Fixed
- CHANGELOG.md: entrada faltante v1.14.0 reconstruida
- GUIA_DE_ADAPTACION.md: step 11.5 (enforcement cableado) y Flujo C sync agregados

## [1.15.1] — 2026-06-05

### Fixed
- `/updoc` sync masivo: 14 labels stale corregidos en guías, mecánicas y referencias
- `INDEX.md`: versiones sincronizadas con headers de cada archivo
- `doc/arch/status-salud.md`: regenerado con datos frescos (v1.15.1, 0 stale)
- `/explica` scope expandido: +ADR_SUMMARY.md, identidad.md, MANDATO.md, status-salud.md

### Changed
- `CHECKLIST.md`: dashboard actualizado (v1.15.0 ✅, próximo milestone v1.15.1)
- `ROADMAP.md`: última actualización → 2026-06-05
- `DILIGENCIA.md`: historial v1.15.0 + v1.15.1 agregados
- `/CBP` commands: CBP corrections — /version step 5 aborta con alertas, /salud BUILD* puro

## [1.14.0] — 2026-06-04

### Fixed
- Templates `identidad.md` y `MANDATO.md`: versiones de metodología removidas de headers (v1.14.0 leak → headers sin versión de Diligencia)
- proyecto-cliente: INDEX.md actualizado (críticos a v0.3.0, DILIGENCIA.md a v1.14.0)
- proyecto-cliente: `identidad.md` y `MANDATO.md` sincronizados desde template (sin versión de metodología)

### Added
- Enforcement documental en 3 capas: `opencode.jsonc` (runtime), `scripts/check-docs.js` (pre-commit), `/adaptar` (proyectos nuevos y upgrades)

## [1.15.0] — 2026-06-05

### Added
- `scripts/check-docs.js` — validación automatizada de integridad documental
- `.husky/pre-commit` template en doc-base con gancho `check-docs`
- `opencode.jsonc` instructions: 6 reglas para enforcement de `/version` en toda sesión
- `/adaptar` Flujo A paso 11.5: cablea enforcement documental en proyectos nuevos
- `/adaptar` Flujo C Fase 1 paso 4: enforcement de sync en upgrades

### Fixed
- `/version` paso 8c: sync mejorado (comparar contenido antes de copiar, preservar placeholders del proyecto destino)

### Changed
- Enforcement documental consolidado como feature core del sistema

## [1.13.0] — 2026-06-03

### Added
- ADR_SUMMARY.md — índice con estadísticas de ADRs registrados
- `doc/guias/identidad.md` — guía de identidad visual y de marca
- `doc/mecanicas/MANDATO.md` — mandato del Director (L1-L3/Flash, memoria, auditoría, filosofía)
- `~/.config/opencode/skills/rebirth-protocol/SKILL.md` — protocolo REBIRTH de 4 fases: diagnosis, recovery, consolidation, load-testing
- CHECKLIST.md: dashboard de versiones en header
- `doc/arch/status-salud.md` — reporte de salud generado por /salud BUILD

### Changed
- adr-template.md: template enriquecido con tabla decisión/impacto, bullets ✅/⚠️, ejemplos concretos
- GUIA_DE_COMANDOS.md: +/CBP y /salud en tabla, 35→37 comandos, §8 extendido con identidad.md, MANDATO.md, ADR_SUMMARY.md
- GUIA_REFERENCIA_RAPIDA.md: bump 35→37 comandos
- INDEX.md: +3 entries (ADR_SUMMARY, identidad, MANDATO)
- DILIGENCIA.md: historial v1.13.0 agregado, doc/arch/README.md con referencia ADR_SUMMARY

## [1.12.1] — 2026-06-02

### Fixed
- DILIGENCIA.md: header sincronizado v1.10.3 → v1.12.0, historial con entradas v1.11.0 + v1.12.0 agregadas

## [1.12.0] — 2026-06-02

### Added
- `/salud` — comando BUILD\* para generar reporte de salud del proyecto (`doc/arch/status-salud.md`)
- Template `status-salud.md` en doc-base (externalizado para /adaptar)
- Meta-PLAN en `/CBP`: fase PRO con auditoría consolidada de todos los comandos + confirmación única previa a BUILD (FLASH)
- `/CBP completo` con meta-orquestador: detección automática de agentes/skills según working tree (@sdd-reviewer, @sdd-architect, @sdd-verify, skill tdd-strict/sdd-workflow)

### Changed
- `/CBP` workflows reestructurados: todo workflow ahora ejecuta META-PLAN (PRO) → BUILD (FLASH)
- MECANICA-CBP.md: diagrama con Meta-PLAN, tabla de 8 estados, secciones de agentes y contrato Meta-PLAN→BUILD
- GUIA_DE_BUENAS_PRACTICAS.md §9: diagramas Meta-PLAN, reglas de modelo (PRO/FLASH), anti-patrones actualizados
- ROADMAP.md: +5 ítems en Siguiente (status-salud, meta-orquestador, revisión agentes/skills, Meta-PLAN, informe-salud inter-proyecto)
- AGENTS.md: +/salud en tabla de comandos (35 fundamentales)

## [1.11.0] — 2026-06-02

### Added
- `/CBP` — orquestador de workflows vinculantes (updoc, doctor, version, completo). Reemplaza el handoff distribuido por "Próximo paso en el circuito".

### Changed
- `/updoc`, `/version`, `/doctor`: sección "Próximo paso en el circuito" removida — el orquestador `/CBP` es el único punto de encadenamiento
- `/doctor` Fase 3f: ya no auto-ejecuta /version patch — sugiere `/CBP doctor`
- MECANICA-CBP.md: migrate a /CBP como SSOT del chain, tabla de estados ref. workflows
- GUIA_DE_BUENAS_PRACTICAS.md §9 + safe-path + anti-patrones: /CBP entry point
- GUIA_REFERENCIA_RAPIDA.md: POST cycle, command table, chain table actualizados a /CBP
- MECANICA-DOCUMENTAL.md §post-sesión: ref a /CBP version
- GUIA_DE_COMANDOS.md: doctor row actualizado
- /explica scope: ADR-001/002/003 agregados, ADAPTAR-COMANDOS.md removido (no existe en disco)
- AGENTS.md: ADAPTAR-COMANDOS.md removido (archivo inexistente)

### Fixed
- D3 cross-ref gap: /explica scope desactualizado (ADAPTAR-COMANDOS.md referenciado pero inexistente; ADRs sin incluir)

## v1.10.3 — 2026-06-02

### Changed
- MECANICA-CBP.md: definición del circuito cíclico vinculante PLAN→BUILD entre comandos
- /updoc, /version, /doctor: sección "Próximo paso en el circuito" con handoff vinculante
- GUIA_DE_BUENAS_PRACTICAS.md §9: diagrama de loop reemplaza diagrama lineal post-sesión
- MECANICA-CBP.md registrado en INDEX.md

### Fixed
- DILIGENCIA.md header no actualizado en v1.10.2 (mostraba v1.10.1)

## v1.10.2 — 2026-06-01

### Fixed
- Template DILIGENCIA.md (doc-base) y /adaptar.md sincronizados a v1.10.2 — estaban en v1.10.0 mientras proyecto en v1.10.1

## v1.10.1 — 2026-06-01

### Fixed
- `/adaptar` reportaba versión incorrecta (v1.7.1) por template DILIGENCIA.md y /adaptar.md stalé. Sincronizados a v1.10.0.

### Changed
- `/version`: si proyecto = Diligencia, actualiza adaptar.md y template DILIGENCIA.md con la nueva versión
- `/updoc`: D5 — detección de staleness entre template DILIGENCIA.md, /adaptar.md y proyecto
- `/doctor` sobre Diligencia: 3 correcciones aplicadas — RM Completado + CHECKLIST + AGENTS.md actualizados con v1.10.0 y /reanudar

## v1.10.0 — 2026-06-01

### Changed
- `/version`: autodetección post-/doctor — si `[Unreleased]` contiene `/doctor`, sugiere `patch` en lugar de `minor`
- `/doctor`: circuito `/doctor` → `/version patch` — sugiere ejecutar `/version patch` tras correcciones
- Nuevo comando `/reanudar`: recuperar sesión tras interrupción brusca (pérdida de conexión, brutalstop)

## v1.9.1 — 2026-06-01

### Changed
- `/doctor` sobre Diligencia: items stale "Plantillas por stack" y "GUIA_REFERENCIA_RAPIDA.md" movidos de Siguiente a Completado en ROADMAP.md

## v1.9.0 — 2026-06-01

### Added
- Integración con CI/CD: `.github/workflows/diligencia-check.yml` — GitHub Actions workflow que valida estructura Diligencia (Category A/ADR-003) en push y pull request. Copiado automáticamente por `/adaptar` vía doc-base.

## v1.8.0 — 2026-06-01

### Added
- CHANGELOG: formato Keep a Changelog con `[Unreleased]` y 6 categorías (Added, Changed, Deprecated, Removed, Fixed, Security)
- ADR lifecycle states: Proposed → Accepted → Deprecated → Superseded con campos Supersedes/Superseded by en template y ADR-001/002/003
- `/commit`: validación Conventional Commits (11 tipos, formato `tipo(scope): descripción`)
- `/version`: soporte `[YANKED]` en CHANGELOG y migración automática desde `[Unreleased]`
- `/updoc`: flag `--auto` para cambios no-destructivos sin preguntar
- `/commit`: flag `--auto` para commitar sin confirmación (uso desde /version)
- `/doctor`: autocierre de tracking en 3f — ✅/[x] en RM/CHECKLIST
- `/explica`: sugerencias automáticas de caminos/dependencias; explicación por contexto de roadmap items
- Plantillas stack: `templates/{node,python,go}/HARNESS.md` pre-configurados con test/lint/typecheck/build/dev por stack. `/adaptar` aplica overlay automático.
- `GUIA_REFERENCIA_RAPIDA.md` — referencia rápida de 1 página con comandos, árbol de decisión, ciclo de sesión, variables, workflows, anti-patrones y ecosistemas

### Changed
- `/version`: paso 6 ejecuta `/updoc --auto`, paso 7 ejecuta `/commit --auto` con formato chore(release)
- `/doctor`: 2 correcciones aplicadas — CHECKLIST +4 items tildeados, ROADMAP GUIA_ECOSISTEMAS movido a Completado
- `/explica`: alcance expandido a GUIA_REFERENCIA_RAPIDA.md
- `GUIA_DE_ADAPTACION.md`: documentado overlay de stack templates
- `GUIA_DE_COMANDOS.md`: cross-ref agregada a GUIA_REFERENCIA_RAPIDA.md
- `ROADMAP.md`, `CHECKLIST.md`: Plantillas stack, GUIA_REFERENCIA_RAPIDA marcados como ✅/[x]; tracking actualizado

## v1.7.2 — 2026-06-01

### Added
- `GUIA_ECOSISTEMAS.md` — mapa de 9 ecosistemas de comandos, cadenas de orquestación, reglas de frontera, matriz archivos×ecosistema, y árbol de decisión

### Changed
- `GUIA_DE_COMANDOS.md` §8: cross-ref a GUIA_ECOSISTEMAS.md
- `/explica` scope: GUIA_ECOSISTEMAS.md agregado a docs de búsqueda
- `ROADMAP.md` Next: GUIA_ECOSISTEMAS.md marcado como ✅ Hecho
- `CHECKLIST.md`: +sección P2 con GUIA_ECOSISTEMAS.md ✅
- `DILIGENCIA.md`: bump v1.7.1→v1.7.2

## v1.7.1 — 2026-06-01

### Added
- Convención semver 3-partes (vX.Y.Z): /version, /diligencia-check y template DILIGENCIA.md actualizados para compatibilidad

### Changed
- `doc/arch/bugs.md`, `doc/arch/incidentes.md` creados desde template (faltaban en disco, detectados por /doctor)
- `.opencode/commands/` creado (faltaba; Diligencia usa comandos globales)
- DILIGENCIA.md: bump v1.6→v1.7.1, +entradas v1.7.0 y v1.7.1 en historial
- `CHANGELOG.md`: v1.7 partido en v1.7.0 (/doctor) y v1.7.1 (correcciones + semver)

## v1.7.0 — 2026-06-01

### Added
- Comando `/doctor` — cuidado integral del proyecto: unifica /diligencia-check, /health, /updoc (Fase C), /bug, /incidente, /limpiar y /deprecar en un solo flujo de 3 fases (diagnóstico, confirmación, correcciones)

### Changed
- Diligencia AGENTS.md: +1 comando (34 total), tablas de comandos actualizadas
- `GUIA_DE_COMANDOS.md`: +1 entrada (34 comandos), + /doctor en Calidad
- `GUIA_DE_BUENAS_PRACTICAS.md`: +/doctor en §2 árbol de decisión y §8 matriz
- ROADMAP.md, CHECKLIST.md: /doctor agregado como P2 pendiente

## v1.6 — 2026-05-31

### Added
- `doc/mecanicas/MECANICA-DOCUMENTAL.md` — mapa del motor documental (variables, flujo, sincronización, anti-patrones)
- Template `incidentes.md` en `doc-base/` — template standalone para incidentes (simétrico a bugs.md)
- Template `sesion.md` en `doc-base/` — journal de sesión multi-agente con decisiones y commits
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` — hábitos y workflows del orquestador (disciplina de sesión, árbol de decisión, delegación, docs vivos, tracking, deprecar, anti-patrones)

### Changed
- `/updoc`: Fase D añadida — integridad de referencias cruzadas (D1 guías huérfanas, D2 templates sin consumidor, D3 scope /explica, D4 variables huérfanas). Fase antigua D → Fase E.
- `/incidente`: referencias a template `incidentes.md` en doc-base en lugar de template inline
- `/adaptar`: Flujo A step 7 crea `doc/arch/incidentes.md` desde template
- `/explica`: scope ampliado a MECANICA-DOCUMENTAL.md y GUIA_DE_BUENAS_PRACTICAS.md
- `GUIA_DE_COMANDOS.md`: + sección 8 guías relacionadas (incluye BUENAS_PRACTICAS, MECANICA-DOCUMENTAL)
- Diligencia AGENTS.md: 33→36 comandos fundamentales
- ROADMAP.md, CHECKLIST.md: tracking de nuevos items

## v1.5 — 2026-05-31

### Added
- Template `bugs.md` en `doc-base/` — bug tracker estándar con P1/P2/P3, resumen tabular e historial
- Comando `/bug` — reportar bugs en `$BUGS` con ID auto-incremental, severidad y archivo
- Comando `/incidente` — registrar crashes runtime en `$INCIDENTS` con stack trace y mitigación
- AGENTS.md (template y Diligencia): `$BUGS` → `doc/arch/bugs.md`, `$INCIDENTS` → `doc/arch/incidentes.md`

### Changed
- `/diligencia-check`: categoría A verifica existencia de `doc/arch/bugs.md` y `doc/arch/incidentes.md`
- `/adaptar`: migración v1.3→v1.4 incluye `$BUGS`, `$INCIDENTS`, y creación de `doc/arch/bugs.md`
- `/explica`: scope ampliado a bugs.md e incidentes.md
- Diligencia AGENTS.md: 31→33 comandos fundamentales
- `GUIA_DE_COMANDOS.md`: 31→33 entradas (+ /bug, + /incidente)

### Commands
- `/bug` declarativo: 8 secciones, ID auto B-NN, template fallback, actualiza $CHECKLIST
- `/incidente` declarativo: 8 secciones, ID auto I-NN, template fallback, stack trace opcional

## v1.4 — 2026-05-31

### Added
- Template `HARNESS.md` en `doc-base/` — config de harness (test, lint, skills, stack) para proyectos nuevos
- Diligencia `.opencode/HARNESS.md` propio — harness autorreferencial de la metodología

### Changed
- ADR-003: árbol incorpora `.opencode/HARNESS.md`, regla 5 lo define como estándar
- `/diligencia-check`: verifica existencia de `.opencode/HARNESS.md` (categoría A)
- `/adaptar`: Flujo A copia HARNESS.md desde template; Flujo C verifica su existencia; tabla migración v1.2→v1.3 lo incluye
- `AGENTS.md` (template y Diligencia): `$TESTING` → `*(definido en HARNESS.md)*`, + `$HARNESS`
- `DILIGENCIA.md`: + fila Harness en tabla Convención
- `GUIA_DE_ADAPTACION.md`: + ítem HARNESS.md en checklist post-migración

### Documentation
- `CHECKLIST.md`, `ROADMAP.md` actualizados con hitos de integración HARNESS

## v1.3 — 2026-05-31

### Fixed
- ROADMAP.md: items stale de v1.0 (ADRs, guías, documentación) en "Ahora (🟡)" → movidos a "Completado"; item duplicado "Estandarizar comandos" removido de "Next"
- `CHECKLIST.md` vs `$RM` inconsistency: /updoc ahora detecta y corrige gaps documentales entre versiones

### Changed
- AGENTS.md de Diligencia: actualizado con 29 comandos fundamentales + variables faltantes ($RM, $COMMANDS_DIR, $TESTING)
- `/updoc` mejorado de sincronización simple a **auditoría documental entre versiones** con 4 fases (alcance, clasificación, gaps, aplicación)

### Architecture
- /updoc ahora detecta el último commit versionado, hace `git diff --name-only <tag>` en lugar de solo `--stat`, clasifica cada .md en 6 categorías, y detecta gaps específicos por categoría

## v1.2 — 2026-05-31

### Added
- 12 comandos globales desde proyecto-alfa: `+mec`, `upmec`, `+rm`, `backup`, `backupall`, `foco`, `news`, `version`, `report`, `apply`, `head`, `notify` — **29 comandos fundamentales totales**
- `/adaptar` ahora copia comandos fundamentales a `.opencode/commands/` del proyecto (todos los flujos A/B/C)
- `ESTANDAR-COMANDOS.md`: guarda de ejecución + instrucciones imperativas agregadas como secciones obligatorias

### Changed
- Diligencia neutralizada: cero referencias a proyecto-alfa/proyecto-beta/$MAIN_APP en comandos globales
- `commit.md`: formato `[sesión]:` removido, ahora usa mensaje libre
- `head.md`: fallback a `$MAIN_APP` removido, requiere ruta explícita o variable del proyecto

### Migrations
- proyecto-alfa: 13 archivos locales removidos, 3 archivados (`nexttx/ui/ux`), AGENTS.md actualizado con tabla global/local/deprecados

## v1.1 — 2026-05-31

### Added
- `ESTANDAR-COMANDOS.md` — define tipos declarativo/procedural, 3 secciones obligatorias + templates
- Guarda de ejecución al tope de 15 comandos globales: `INSTRUCCIÓN: EJECUTAR... NO mostrar este archivo como output.`
- Instrucciones imperativas en 13 comandos declarativos ("Leer AHORA", "Entregar SOLO")

### Changed
- 15 comandos globales estandarizados con Formato + Validación + Anti-patrones (13 declarativos) o solo Anti-patrones (2 procedurales)
- `limpiar.md`: patrones de temp files de proyecto-alfa (query, start, line*.txt, check_*.js, chk.js)
- `ROADMAP.md` Diligencia: items de estandarización
- `CHECKLIST.md` Diligencia: P2 estandarización de comandos globales (15 items ✅)

## v1.0 — 2026-05-08

### Added
- Template `doc-base` con 8 archivos: `AGENTS.md`, `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`, `DILIGENCIA.md`, `.markdownlint.json`, `doc/arch/README.md`, `doc/arch/adr-template.md`
- Comando global `/adaptar` (Diligencia v1.0): detección automática nuevo/existente/adaptado
- `DILIGENCIA.md` — sello de metodología con convención, proyectos adaptados e historial
- `ADAPTAR-COMANDOS.md` v1.3: referencia a `/adaptar` como atajo

### Architecture
- **Dos capas de comandos:** global (`~/.config/opencode/commands/`) heredada automáticamente + local (`.opencode/commands/`) por proyecto
- **Sistema de `$variables`:** rutas hardcodeadas reemplazadas por variables definidas en `AGENTS.md`, zero hardcoded paths
- **Estructura estándar:** `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md` en raíz; `doc/arch/`, `doc/guias/`, `doc/mecanicas/` para contenido

### Migrations
- proyecto-alfa Detective: 35 variables, 21+ comandos refactorizados, 15 archivos migrados de `autoridad/` a estructura estándar
- proyecto-beta: 32 variables, 10 comandos refactorizados, migración completa a estructura estándar

## Archivos relacionados
- `ROADMAP.md` — roadmap del proyecto
- `CHECKLIST.md` — checklist de tareas
- `DILIGENCIA.md` — sello de metodología
