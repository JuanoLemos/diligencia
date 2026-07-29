# verdades.md — Hechos verificados de Diligencia

Este archivo contiene hechos verificados mediante comandos o lectura directa.
No se pierde con compactación de contexto. Cada entrada incluye `verify:` con
el comando que la respalda.

---

## Versión actual

| Hecho | Valor | Verify |
|---|---|---|
| Versión Diligencia | v3.7.1 | `DILIGENCIA.md:1` |
| Fecha | 2026-07-29 | `CHANGELOG.md:5` |
| Repositorio | `https://github.com/JuanoLemos/diligencia.git` | `AGENTS.md` variable `$REPO` |
| Rama por defecto | `master` | `git branch --show-current` |
| Contenido | Metodología documental pura (Markdown, sin código runtime) | `HARNESS.md` — "stack: none (metodologia documental sin codigo runtime)" |

---

## Reglas críticas (las que más se violan)

| Regla | Texto | Verify |
|---|---|---|
| R6 | MAIN solo versiona cuando cambia la metodología Diligencia (comandos, mecánicas, templates) | `AGENTS.md:157` |
| R15 | Monitoreo bidireccional vía `git fetch` antes de cada respuesta | `AGENTS.md:166` |
| Disciplina BUILD | BUILD = aplicar cambios, NO commitear. Solo /commit, /CBP, /version ejecutan git commit | `AGENTS.md:117-119` |
| Seguridad | No leer `.env` bajo ninguna circunstancia | Global AGENTS.md |
| Seguridad | No hacer `git push` sin aprobación explícita | Global AGENTS.md |

---

## Métricas de la sesión 2026-07-29

Verificadas con `git log --since="2026-07-20" --until="2026-07-29"`.

| Métrica | Valor | Verify |
|---|---|---|
| Commits totales (9 días) | 433 | `git log --oneline --since="2026-07-20" --until="2026-07-29" \| measure \| % Count` |
| Version bumps (chore release) | 12 (v3.0.0 → v3.6.0) | `git log --oneline --since="2026-07-20" --grep="chore(release):"` |
| Infra/VAIO commits | ~420 (~97%) | `git log --oneline --since="2026-07-20" --grep="VAIO\|heartbeat\|tunnel\|task"` |
| Commits metodología real | ~15 (~3%) | Diferencia: total - infra - bumps |

---

## Archivos de reglas

| Archivo | Reglas | Propósito | Verify |
|---|---|---|---|
| `~/.config/opencode/AGENTS.md` | ~18 | Reglas globales del harness (todos los proyectos) | Lectura directa |
| `AGENTS.md` (proyecto) | ~85 | Reglas específicas Diligencia | Lectura directa |
| `HARNESS.md` | ~22 | Config test/lint/skills/stack | Lectura directa |
| `CBP.md` | ~35 | Orquestador workflows CBP | Lectura directa |
| `version.md` | ~30 | Reglas de versionado | Lectura directa |
| `commit.md` | ~25 | Reglas de commit | Lectura directa |
| IDENTIDAD-*.md | ~45 | Límites de roles Circuito/Chamber | Lectura directa |
| 36 comandos adicionales | ~300+ | Reglas procedurales | Lectura directa |
| **Total estimado** | **~500+** | | |

---

## Commits de esta sesión (a medida que se ejecutan)

| Commit | Cambio | Fecha |
|---|---|---|
| *(pendiente)* | Reforma estructural: verdades.md, R16, R17, R6/R15 rewrite, enforcement | 2026-07-29 |

---

## Versión actual (post-reforma)

| Hecho | Valor | Verify |
|---|---|---|
| Versión Diligencia | v3.7.1 | `DILIGENCIA.md:1` |
| R16 activa | Sí | `AGENTS.md:171` |
| R17 activa | Sí | `AGENTS.md:172` |
| R6 reescrita | Sí | `AGENTS.md:161` |
| R15 reescrita | Sí | `AGENTS.md:170` |
| verdades.md existe | Sí | `doc/verdades.md` |
| validate-commit.ps1 | Creado | `scripts/validate-commit.ps1` |
| git hooks | README + commit-msg creados | `.opencode/hooks/` |
