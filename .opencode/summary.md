# Session Summary — 2026-06-05

## Current Version
Diligencia v1.15.0 (bumped from v1.14.0)

## Key Changes This Session

### Documental Enforcement (3-capas)
1. **opencode.jsonc** — 6 reglas de `/version` enforcement inyectadas en toda sesión (rules: version-on-close, pre-commit-check, commit-format-cc, doc-sync-check, no-stale-on-close, summary-update)
2. **scripts/check-docs.js** — script autónomo que valida integridad: INDEX.md vs CHANGELOG, headers sincronizados, $VARIABLES resolubles, sin leaks de versión de metodología en proyectos
3. **.husky/pre-commit** template en doc-base con gancho check-docs

### Template Cleanup
- `identidad.md` y `MANDATO.md` (doc-base and adapted projects): versiones de metodología removidas de headers — ya no leak v1.x.x en headers de proyecto
- `/version` paso 8c mejorado: compara contenido antes de copiar, preserva placeholders del proyecto destino

### /adaptar Updates
- **Flujo A** nuevo paso 11.5: cablea enforcement documental en proyectos nuevos (opencode.jsonc rules + scripts/check-docs.js + pre-commit hook)
- **Flujo C** Fase 1 nuevo paso 4: enforcement de sync en upgrades (comparar versión local vs global, forzar sync si stale)
- Migration table: v1.14.0 → v1.15.0 entry added

### proyecto-cliente Sync
- INDEX.md actualizado (críticos v0.2.0→v0.3.0, DILIGENCIA.md v1.14.0)
- identidad.md y MANDATO.md sincronizados desde template (sin versión de metodología)
- check-docs.js creado, npm script agregado, pre-commit hook agregado

## Active Files / Architecture
- **Global commands**: `~/.config/opencode/commands/` (adaptar.md, version.md, etc.)
- **Templates**: `~/.config/opencode/templates/doc-base/` (DILIGENCIA.md, identidad.md, MANDATO.md, status-salud.md, v1.15.0)
- **Scripts**: `scripts/check-docs.js` in Diligencia + adapted projects
- **DOCS criticos**: INDEX.md, CHANGELOG.md, DILIGENCIA.md (managed by /version)
- **DOCS informativos**: guías y mecánicas (managed by /updoc)

## Known Issues
- 9 docs STALE en INDEX.md (guias y mecánicas con versiones v1.10.3–v1.13.0 vs v1.15.0 actual)
- 3 D3 gaps en /explica scope: ADR_SUMMARY.md, identidad.md, MANDATO.md no listados
- status-salud.md stale (v1.13.0), no regenerado

## Next Steps (suggested)
1. `npm run check-docs` — verify integrity post-bump
2. Regenerate `status-salud.md` with `/salud` command
3. `/updoc` to sync stale guías/mecánicas
4. Update `/explica` scope to include missing D3 docs
