# diligencia-docs — Auditoría documental completa

24 checks en 6 categorías. Read-only. Cargable por `/documentar`, `/salud` Fase 1i, y `/CBP` Ola 1.

> **Modo cocinado:** Cuando el agente opera en modo paloma, debe incluir el contenido propuesto (archivos completos o diffs) en la columna "Acción sugerida", listo para que el MAIN lo copie y aplique.

---

## 📁 ESTRUCTURA (4 checks)

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 1 | AGENTS.md SSOT | Variables definidas resuelven a archivos existentes. Tabla de comandos lista los 31 activos. Deprecados registrados. | P1 |
| 2 | COMANDOS.md sync | Cantidad de comandos coincide con AGENTS.md (31). Cada comando en AGENTS.md aparece en COMANDOS.md por grupo. | P2 |
| 3 | HARNESS.md | `.opencode/HARNESS.md` existe con campos Stack, Test, Skills. | P2 |
| 4 | .markdownlint.json | Archivo de configuración de linting markdown existe. | P3 |

## 📁 LEGAL (4 checks) — `/documentar --legales`

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 5 | LICENSE | Presente y con licencia válida (AGPL-3.0, GPL-3.0, etc.) | P1 |
| 6 | NOTICE | Presente (atribución de terceros). | P2 |
| 7 | SECURITY.md | Presente con Scope y Out of Scope definidos. | P2 |
| 8 | LICENSING.md | Presente si hubo cambio de licencia (GPL→AGPL en v2.0.0). | P3 |

## 📁 DOCS INFORMATIVOS (4 checks)

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 9 | Headers con versión | Cada guía/mecánica/ADR tiene formato `# NOMBRE — Descripción vX.Y.Z`. Versión coincide con DILIGENCIA.md. | P2 |
| 10 | Fechas ISO 8601 | Toda fecha en .md usa `YYYY-MM-DD`. Sin formatos DD/MM/YYYY. | P3 |
| 11 | INDEX vs disco | Todos los archivos en `doc/guias/`, `doc/mecanicas/`, `doc/arch/` están registrados en INDEX.md. Sin archivos huérfanos. | P2 |
| 12 | ADR_SUMMARY vs ADR-*.md | Cantidad de ADRs en ADR_SUMMARY.md coincide con archivos `ADR-*\.md` en disco. | P2 |

## 📁 TRACKING (5 checks)

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 13 | ROADMAP coherencia | Items en "Ahora" con 🟡/✅ coinciden con "Siguiente" y "Completado". Sin duplicados ni stale. | P2 |
| 14 | CHECKLIST Dashboard | Última versión registrada en Dashboard coincide con DILIGENCIA.md. | P1 |
| 15 | Trackers existentes | `$BUGS`, `$INCIDENTS`, `$BACKUPS` resuelven a archivos reales. | P2 |
| 16 | Proyectos + propagaciones | `catalogo-proyectos.md` y `propagaciones.md` existen y tienen datos. | P3 |
| 17 | status-salud.md | Existe y no tiene más de 7 días de desactualización. | P3 |

## 📁 COMANDOS (5 checks)

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 18 | Guarda de ejecución | Cada comando en `.opencode/commands/*.md` empieza con `INSTRUCCIÓN: EJECUTAR...` | P2 |
| 19 | Secciones obligatorias | Cada comando declarativo tiene `## Formato de salida`, `## Validación`, `## Anti-patrones`. | P3 |
| 20 | Coincidencia 3 vías | AGENTS.md ↔ COMANDOS.md ↔ `.opencode/commands/*.md` — los mismos comandos en los 3 lugares. Comandos huérfanos (en disco pero no en AGENTS.md) se reportan. | P1 |

---

## 🎯 IDENTIDAD PÚBLICA (4 checks)

| # | Check | Qué valida | Severidad |
|---|-------|-----------|-----------|
| 21 | README.md vigente | Versión en README coincide con DILIGENCIA.md. Badges actualizados. Descripción refleja el propósito real y el tipo de proyecto (Diligencia = plural/gratis, Nemesis = juego pago/comercial). | P2 |
| 22 | Proyectos adaptados vigentes | `catalogo-proyectos.md` y `$PROYECTOS` solo listan proyectos activos (>90 días sin commit → sugerir marcar como 🧊 o remover). | P2 |
| 23 | Identidad pública coherente | AGENTS.md §Identidad describe correctamente qué ES el proyecto (no qué NO es). La descripción en DILIGENCIA.md coincide con la del repo GitHub. | P1 |
| 24 | Documentos comunitarios | `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` existen en proyectos públicos. `LICENSE` es apropiada para el tipo de proyecto (AGPL-3.0 para libres, otra para comerciales). | P3 |

---

## Archivos relacionados
- `.opencode/commands/documentar.md` — comando de invocación
- `.opencode/commands/salud.md` — Fase 1i (carga esta skill)
- `.opencode/commands/CBP.md` — Ola 1 worker
- `AGENTS.md` — tabla de comandos y variables
- `doc/guias/COMANDOS.md` — sidebar reference
