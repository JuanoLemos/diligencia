# CHANGELOG — Diligencia

---

## [1.16.3] — 2026-06-06

### Added
- `doc/guias/GUIA_ONBOARDING.md` — primeros pasos para usuarios primerizos de IA + OpenCode
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
