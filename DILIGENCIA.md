# Diligencia v2.6.1 — Estructura estándar de documentación

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
| proyecto-alfa Detective | 2026-05-08 | ✅ |
| proyecto-beta | 2026-05-08 | ✅ |

## Historial

| Versión | Fecha | Cambios |
|---|---|---|
| v2.0.0 | 2026-06-26 | @consejero + @circuito: agentes de decisión e integridad lógica. 2 skills nuevas. 2 mecánicas nuevas. 2 comandos nuevos. 5 comandos mejorados. /doctor +1g +3g. INDEX sincronizado. Licencia AGPL-3.0. MANIFIESTO.md. |
| v1.19.0 | 2026-06-25 | Skills Chamber + catálogo proyectos + audit Chamber + 6/6 al día. Identidad definida. |
| v1.18.1 | 2026-06-23 | Emojis liberados. ROADMAP R22-R28 (planloop, loop, OpenChamber hub, upstream watch). |
| v1.18.0 | 2026-06-23 | Planes A+B+C: contexto L0/L1/L2, graphify, claude-mem, .graphifyignore, INDEX L0. |
| v1.17.9 | 2026-06-23 | Licencia GPL-3.0 → AGPL-3.0. MANIFIESTO.md creado (6 principios). SECURITY.md template mejorado. |
| v1.17.8 | 2026-06-23 | Auditoría completa de variables: $STACK y $PROJECT_NAME definidas, $NEWS_FILE removida. Deprecación de 5 comandos rotos (/+pend, /+rmi, /news, /notify, /qa). Guías sincronizadas. |
| v1.17.7 | 2026-06-06 | 3 themes (naranja, verde, celeste) + GUIA_THEMES actualizada + instrucción BUILD en opencode.jsonc. |
| v1.17.6 | 2026-06-06 | Part A fixes: commit usa /commit, parcial con Meta-PLAN, version confirmación única, Steps 6→12, doctor loop. |
| v1.17.5 | 2026-06-06 | Guarda BUILD anti-commiteo heredable. Banners, AGENTS, adaptar paso 5. |
| v1.17.4 | 2026-06-06 | Fase 2.5.5 — themes sincronizados por /adaptar. GUIA_THEMES actualizada. |
| v1.17.3 | 2026-06-06 | /explica: 3 capas (criollo + técnico + impacto). |
| v1.16.6 | 2026-06-06 | Fase 2.6 calidad documental en /adaptar (escanea .md, migra ROADMAP a estándar). Dispatch dinámico (question() en CBP). Regla #16: disciplina de bump al editar globales. |
| v1.16.5 | 2026-06-06 | Plan legal: GUIA_LEGAL.md, NOTICE/SECURITY.md templates, /legal. Plan multi-repo: MECANICA-WORKTREE.md, GUIA_MULTI_REPO.md. Plan calidad: MECANICA-CALIDAD.md, ROADMAP template estándar. 39 comandos. |
| v1.16.4 | 2026-06-06 | /CBP adaptación escalativa (commit/parcial/full + dispatch). Meta-PLAN paralelo 4 workers. GUIA_DE_INFORMES.md. $MECANICAS, $NEWS_FILE. |
| v1.16.3 | 2026-06-06 | Provider-agnostic: PRO→razonamiento, FLASH→ejecución. GUIA_ONBOARDING.md (api key genérica). /informe-salud inter-proyecto. SDD agents nota ADAPTAR. |
| v1.16.2 | 2026-06-05 | /doctor backup preventivo + backup log. $BACKUPS/$BACKUP_KEEP. Labels 15 guías bump. |
| v1.16.1 | 2026-06-05 | Higiene pública: sanitizar paths, redactar proyectos privados, audiencia (desarrollador→orquestador). |
| v1.16.0 | 2026-06-05 | GitHub readiness: README.md, LICENSE (GPL-3.0), .gitignore, CONTRIBUTING.md, CODE_OF_CONDUCT.md. GUIA_DE_CONTRIBUCION.md (guía), MECANICA-ENFORCEMENT.md (mecánica). CI workflow en .github/workflows/. |
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
| v1.2 | 2026-05-31 | 12 comandos proyecto-alfa adaptados a globales (+mec, upmec, +rm, backup, backupall, foco, news, version, report, apply, head, notify) — 29 comandos fundamentales totales. /adaptar copia comandos al proyecto. |
| v1.1 | 2026-05-31 | Estándar de comandos: guarda + imperativo + Formato/Validación/Anti-patrones obligatorias |
| v1.0 | 2026-05-08 | Convención inicial: doc-base template, $variables en AGENTS.md, dos capas de comandos, /adaptar global |

## Archivos relacionados
- `ROADMAP.md` — roadmap de la metodología
- `CHECKLIST.md` — checklist de tareas
- `CHANGELOG.md` — historial de versiones
- `AGENTS.md` — variables de ruta y comandos
