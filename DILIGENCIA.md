# Diligencia v1.15.3 — Estructura estándar de documentación

Sello de metodología para proyectos OpenCode.

---

## Qué es

Diligencia es una convención de estructura de documentación para proyectos OpenCode.
Define dónde vive cada tipo de archivo, cómo se nombran las variables de ruta, y cómo se organizan los comandos.

## Convención

| Tipo | Ubicación |
|---|---|
| Roadmap | `ROADMAP.md` (raíz) |
| Checklist | `CHECKLIST.md` (raíz) |
| Changelog | `CHANGELOG.md` (raíz) |
| ADRs, sistema, bitácora | `doc/arch/` |
| Guías de usuario | `doc/guias/` (incluye `ESTANDAR-COMANDOS.md`) |
| Mecánicas del juego | `doc/mecanicas/` |
| Variables de ruta | `AGENTS.md` → `Mapeo de rutas` |
| Comandos locales | `.opencode/commands/` |
| Harness | `.opencode/HARNESS.md` (test, lint, skills, stack) |
| Comandos globales | `~/.config/opencode/commands/` |

## Proyectos adaptados

| Proyecto | Fecha | Estado |
|---|---|---|
| Diligencia (autor) | 2026-05-31 | ✅ |
| Némesis Detective | 2026-05-08 | ✅ |
| MarketAI | 2026-05-08 | ✅ |

## Historial

| Versión | Fecha | Cambios |
|---|---|---|
| v1.15.3 | 2026-06-05 | Idioma español como Buena Práctica: templates AGENTS.md y HARNESS.md incluyen sección "Idioma". opencode.jsonc instructions: +"Siempre responde en español". GUIA_DE_BUENAS_PRACTICAS.md §10. |
| v1.15.2 | 2026-06-05 | /circuito → /CBP rename + 12 stale labels bump + gaps resueltos (CHANGELOG v1.14.0, GUIA_DE_ADAPTACION step 11.5). /CBP default → completo. |
| v1.15.1 | 2026-06-05 | Sync documental masivo: /updoc — 14 labels stale corregidos, INDEX sincronizado. /explica scope expandido (identidad, MANDATO, ADR_SUMMARY, status-salud). /doctor — tracking actualizado (CHECKLIST, ROADMAP). /salud regenerado. CBP corrections en /CBP commands. |
| v1.15.0 | 2026-06-05 | Documental enforcement en 3 capas: check-docs.js, opencode.jsonc instructions (6 reglas /version), pre-commit hook template. /adaptar step 11.5 (cablea enforcement) + Flujo C paso 4 (sync upgrades). /version paso 8c mejorado. Templates sin versiones de metodología. |
| v1.14.0 | 2026-06-05 | /version con PRE-FLIGHT integral (6 checks A-F). Micro-circuito pre-flight detecta alertas (staleness, salud, /explica scope, template, cross-refs, variables) y pregunta forzar/abortar antes del bump. Circuito /updoc → /version cerrado. |
| v1.13.0 | 2026-06-03 | Nuevos documentos metodológicos: ADR_SUMMARY.md, identidad.md (guía), MANDATO.md (mandato Director). Skill rebirth-protocol para continuidad multi-sesión. adr-template.md enriquecido. CHECKLIST.md con dashboard de versiones. |
| v1.12.0 | 2026-06-02 | Meta-PLAN (PRO) + BUILD (FLASH) en /CBP. /salud BUILD*. Meta-orquestador con agentes/skills. |
| v1.11.0 | 2026-06-02 | /CBP — orquestador de workflows vinculantes. "Próximo paso en el circuito" removido de comandos individuales. MECANICA-CBP.md en doc-base. |
| v1.10.3 | 2026-06-02 | Circuito cíclico PLAN→BUILD vinculante entre comandos. /updoc, /version, /doctor: sección "Próximo paso en el circuito". MECANICA-CBP.md nueva mecánica. GUIA_DE_BUENAS_PRACTICAS.md §9 loop diagram. |
| v1.10.1 | 2026-06-01 | Bug fix: /adaptar reportaba v1.7.1 por template DILIGENCIA.md y adaptar.md stalé. /version ahora sincroniza template+adaptar al versionar Diligencia. /updoc D5 detecta staleness. |
| v1.10.0 | 2026-06-01 | `/version`: autodetección post-/doctor sugiere patch. `/doctor`: circuito → `/version patch` tras correcciones. Nuevo `/reanudar`: recuperación de sesión tras interrupción brusca. |
| v1.9.1 | 2026-06-01 | `/doctor` sobre Diligencia: items stale en ROADMAP.md movidos de Siguiente a Completado. CHANGELOG.md con entrada de /doctor. Gap D2 cerrado (diligencia-check.yml referenciado explícitamente en /adaptar). |
| v1.9.0 | 2026-06-01 | Integración con CI/CD: GitHub Actions workflow de validación de estructura Diligencia (Category A/ADR-003). Copiado automáticamente por /adaptar vía doc-base. |
| v1.8.0 | 2026-06-01 | CHANGELOG Keep a Changelog, ADR lifecycle, /commit Conventional Commits, /version [YANKED]+migración, plantillas stack (Node/Python/Go), GUIA_REFERENCIA_RAPIDA.md, /explica mejorado, comandos --auto delegate desde /version. |
| v1.7.2 | 2026-06-01 | GUIA_ECOSISTEMAS.md: mapa de 9 ecosistemas, cadenas de orquestación, reglas de frontera. Cross-refs actualizadas en GUIA_DE_COMANDOS.md, /explica, ROADMAP, CHECKLIST. |
| v1.7.1 | 2026-06-01 | Adopción semver 3-partes (vX.Y.Z). /doctor ejecutado sobre Diligencia: bugs.md, incidentes.md, .opencode/commands/ creados en disco. /version, /diligencia-check, template DILIGENCIA.md actualizados para compatibilidad vX.Y.Z. |
| v1.7.0 | 2026-06-01 | /doctor — comando unificado de cuidado integral (orquesta 6 sub-comandos en 3 fases). Tracking documental sincronizado (AGENTS, GUIA_COMANDOS, BUENAS_PRACTICAS, ROADMAP, CHECKLIST). |
| v1.6 | 2026-06-01 | MECANICA-DOCUMENTAL.md reestructurada con índice y 6 secciones. Templates bugs/incidentes/sesion completados. GUIA_DE_BUENAS_PRACTICAS.md creada. /updoc Fase D cross-ref añadida. /health stack-aware. |
| v1.5 | 2026-05-31 | Comandos /bug, /incidente. $BUGS, $INCIDENTS en AGENTS.md. Template bugs.md en doc-base. |
| v1.4 | 2026-05-31 | Template HARNESS.md en doc-base. Diligencia .opencode/HARNESS.md propio. ADR-003 actualizado. |
| v1.3 | 2026-05-31 | ROADMAP stale data corregido (Ahora→Completado). AGENTS.md actualizado a 29 comandos + variables faltantes. /updoc mejorado con auditoría documental entre versiones. CHECKLIST sincronizado. /adaptar con conciencia de versión. |
| v1.2 | 2026-05-31 | 12 comandos Nemesis adaptados a globales (+mec, upmec, +rm, backup, backupall, foco, news, version, report, apply, head, notify) — 29 comandos fundamentales totales. /adaptar copia comandos al proyecto. |
| v1.1 | 2026-05-31 | Estándar de comandos: guarda + imperativo + Formato/Validación/Anti-patrones obligatorias |
| v1.0 | 2026-05-08 | Convención inicial: doc-base template, $variables en AGENTS.md, dos capas de comandos, /adaptar global |
