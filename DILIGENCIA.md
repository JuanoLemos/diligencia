# Diligencia v1.7.2 — Estructura estándar de documentación

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
