# CHANGELOG — Diligencia

---

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
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` — hábitos y workflows del desarrollador (disciplina de sesión, árbol de decisión, delegación, docs vivos, tracking, deprecar, anti-patrones)

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
- 12 comandos globales desde Nemesis: `+mec`, `upmec`, `+rm`, `backup`, `backupall`, `foco`, `news`, `version`, `report`, `apply`, `head`, `notify` — **29 comandos fundamentales totales**
- `/adaptar` ahora copia comandos fundamentales a `.opencode/commands/` del proyecto (todos los flujos A/B/C)
- `ESTANDAR-COMANDOS.md`: guarda de ejecución + instrucciones imperativas agregadas como secciones obligatorias

### Changed
- Diligencia neutralizada: cero referencias a Nemesis/MarketAI/$MAIN_APP en comandos globales
- `commit.md`: formato `[sesión]:` removido, ahora usa mensaje libre
- `head.md`: fallback a `$MAIN_APP` removido, requiere ruta explícita o variable del proyecto

### Migrations
- Nemesis: 13 archivos locales removidos, 3 archivados (`nexttx/ui/ux`), AGENTS.md actualizado con tabla global/local/deprecados

## v1.1 — 2026-05-31

### Added
- `ESTANDAR-COMANDOS.md` — define tipos declarativo/procedural, 3 secciones obligatorias + templates
- Guarda de ejecución al tope de 15 comandos globales: `INSTRUCCIÓN: EJECUTAR... NO mostrar este archivo como output.`
- Instrucciones imperativas en 13 comandos declarativos ("Leer AHORA", "Entregar SOLO")

### Changed
- 15 comandos globales estandarizados con Formato + Validación + Anti-patrones (13 declarativos) o solo Anti-patrones (2 procedurales)
- `limpiar.md`: patrones de temp files de Nemesis (query, start, line*.txt, check_*.js, chk.js)
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
- Némesis Detective: 35 variables, 21+ comandos refactorizados, 15 archivos migrados de `autoridad/` a estructura estándar
- MarketAI: 32 variables, 10 comandos refactorizados, migración completa a estructura estándar
