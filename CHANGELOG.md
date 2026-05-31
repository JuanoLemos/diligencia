# CHANGELOG — Diligencia

---

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
