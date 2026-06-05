# ROADMAP — Diligencia

Metodología de estructura estándar para proyectos OpenCode.

Última actualización: 2026-06-05

---

## Stack

- Metodología documental (sin código runtime)
- Dependencias: OpenCode, `templates/doc-base/`, `ADAPTAR-COMANDOS.md`
- Proyectos adaptados: Némesis Detective, MarketAI

---

## Ahora (Now)

*(nada en progreso actualmente)*

## Siguiente (Next)

| Item | Prioridad | Estado |
|---|---|---|
| +Backup en /doctor | P2 | 🔴 Pendiente |
| +up github | P2 | 🔴 Pendiente |
| +guia usuario noob, usando primera vez AI | P2 | 🔴 Pendiente |
| +ayuda en worktree para recomendar acciones de buenas practicas | P2 | 🔴 Pendiente |
| +status-salud: reporte de salud del proyecto integrado en /CBP | P2 | 🔴 Pendiente |
| +meta-orquestador: /CBP adaptado a agentes y skills con detección automática | P2 | 🔴 Pendiente |
| +revisión de agentes y skills: compatibilidad con circuito, actualizar docs | P2 | 🔴 Pendiente |
| +Meta-PLAN: fase PRO con confirmación única previa a BUILD (FLASH) | P2 | 🔴 Pendiente |
| +informe-salud inter-proyecto basado en estructura Diligencia | P3 | 🔴 Pendiente |

## Futuro (Later)

| Item | Prioridad | Estado |
|---|---|---|
| CLI tool independiente | P3 | 🔴 Pendiente |
| Plugin marketplace | P3 | 🔴 Pendiente |

## Completado

| Item | Instancia |
|---|---|
| Documentación completa del sistema (ADRs + guías + estructura) | v1.0 |
| ADRs de arquitectura (001-003) | v1.0 |
| Guías de uso + adaptación | v1.0 |
| GUIA_DE_BUENAS_PRACTICAS.md — hábitos y workflows para el desarrollador | v1.6 |
| Template `incidentes.md` en doc-base (externalizado para /adaptar) | v1.6 |
| Template `sesion.md` en doc-base (journal multi-agente) | v1.6 |
| Template doc-base (7 archivos) | v1.0 |
| Comando global /adaptar (Diligencia v1.0) | v1.0 |
| Migración Némesis Detective | v1.0 |
| Migración MarketAI | v1.0 |
| ADAPTAR-COMANDOS.md v1.3 | v1.0 |
| Estandarización comandos globales (guarda + imperativo + Formato/Validación/Anti-patrones) | v1.1 |
| 12 comandos Nemesis adaptados a globales (29 total) + /adaptar copia comandos | v1.2 |
| ROADMAP stale data corregido (Ahora→Completado, duplicados Next) | v1.3 |
| AGENTS.md actualizado: 29 comandos + variables faltantes | v1.3 |
| /updoc mejorado: auditoría documental entre versiones | v1.3 |
| CHECKLIST sincronizado (ADRs/guías tildados, duplicado P3 removido) | v1.3 |
| GUIA_DE_COMANDOS.md actualizado a v1.3: 30 comandos + /explica + arquitectura + categorías | v1.3 |
| `diligencia-check` — validación automática de estructura (ADR-003, variables, comandos, versión) | v1.3 |
| HARNESS.md integrado al estándar: template, ADR-003, /adaptar, diligencia-check | v1.3 |
| MECANICA-DOCUMENTAL.md reestructurada con índice y 6 secciones (motor, tracking, QA, sesión, conservación, anti-patrones) | v1.6 |
| Comando `/deprecar` para deprecar archivos/estructuras obsoletas | v1.4 |
| Comando `/bug` — reportar bugs en $BUGS con template estándar | v1.5 |
| Comando `/incidente` — registrar crashes runtime en $INCIDENTS | v1.5 |
| `GUIA_ECOSISTEMAS.md` — mapa de ecosistemas y fronteras entre comandos | v1.7.2 |
| CHANGELOG adopta Keep a Changelog: `[Unreleased]` + 6 categorías (Added, Changed, Deprecated, Removed, Fixed, Security) | v1.7.2+ |
| ADR lifecycle states (Proposed → Accepted → Deprecated → Superseded) con campos `Supersedes`/`Superseded by` | v1.7.2+ |
| `/commit` — validación de formato Conventional Commits (tipo/scope obligatorios) | v1.7.2+ |
| `/version` — soporte `[YANKED]` en CHANGELOG, migración automática de `[Unreleased]` | v1.7.2+ |
| `/doctor` — cuidado integral del proyecto | v1.8.0 |
| Plantillas por stack (Node, Python, Go) | v1.8.0 |
| GUIA_REFERENCIA_RAPIDA.md | v1.8.0 |
| Integración con CI/CD — GitHub Actions workflow de validación de estructura (Category A/ADR-003) | v1.9.0 |
| `/version` — autodetección post-/doctor: si `[Unreleased]` contiene `/doctor`, sugiere `patch` | v1.10.0 |
| `/doctor` — circuito → `/version patch` tras correcciones en Fase 3 | v1.10.0 |
| `/reanudar` — recuperar sesión tras interrupción brusca (pérdida de conexión, brutalstop) | v1.10.0 |
| Template DILIGENCIA.md y adaptar.md sincronizados a v1.10.0 (bug: reportaban v1.7.1 y v1.3) | v1.10.1 |
| `/version`: si proyecto = Diligencia, actualiza template + adaptar.md al versionar | v1.10.1 |
| `/updoc`: D5 — detección de staleness template vs proyecto | v1.10.1 |
