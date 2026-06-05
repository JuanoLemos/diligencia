# CHECKLIST — Diligencia

---

## Dashboard

| Versión | Estado | Descripción |
|---|---|---|
| v1.15.0 | ✅ | Documental enforcement 3 capas + /adaptar migration table + version leaks |
| v1.12.0 | ✅ | Meta-PLAN + BUILD en /CBP, /salud, meta-orquestador |
| v1.11.0 | ✅ | /CBP vinculante, MECANICA-CBP.md |
| v1.10.x | ✅ | Circuito cíclico, /reanudar, staleness fix |
| v1.9.x | ✅ | CI/CD, /doctor sobre Diligencia |
| v1.8.0 | ✅ | Keep a Changelog, ADR lifecycle, plantillas stack |

**Completado:** 6/7 versiones (86%)

### Bloqueadores

Ninguno activo.

### Próximo milestone

Cerrar v1.15.1 con /CBP updoc -> BUILD -> /version patch.

---

## P1 — Documentación core

- [x] Template doc-base (7 archivos)
- [x] Comando global /adaptar (Diligencia v1.0)
- [x] ADAPTAR-COMANDOS.md v1.3
- [x] DILIGENCIA.md — sello de metodología
- [x] GUIA_DE_USO.md — manual completo (v1.0)
- [x] GUIA_DE_ADAPTACION.md — proceso de migración (v1.0)
- [x] GUIA_DE_COMANDOS.md — referencia de 33 comandos (v1.5)
- [x] ADR-001: Arquitectura de dos capas (v1.0)
- [x] ADR-002: Sistema de variables (v1.0)
- [x] ADR-003: Estructura estándar de archivos (v1.0)

## P2 — Proyectos adaptados

- [x] Némesis Detective
- [x] MarketAI

## P2 — Estandarización de comandos globales

- [x] ESTANDAR-COMANDOS.md creado en doc/guias/ (incluye guarda + imperativo como requerimiento)
- [x] rm.md — Formato + Validación + Anti-patrones
- [x] next.md — Formato + Validación + Anti-patrones
- [x] checklist.md — Formato + Validación + Anti-patrones
- [x] estado.md — Formato + Validación + Anti-patrones
- [x] updoc.md — Formato + Validación + Anti-patrones
- [x] debug.md — Formato + Validación + Anti-patrones
- [x] health.md — Formato + Validación + Anti-patrones
- [x] +rmi.md — Formato + Validación + Anti-patrones
- [x] +guia.md — Formato + Validación + Anti-patrones
- [x] +pend.md — Formato + Validación + Anti-patrones
- [x] qa.md — Formato + Validación + Anti-patrones
- [x] upguia.md — Formato + Validación + Anti-patrones
- [x] plan.md — Formato + Validación + Anti-patrones
- [x] limpiar.md — Anti-patrones (procedural)
- [x] commit.md — Anti-patrones (procedural)

## P2 — Comandos fundamentales globales (v1.2)

- [x] `+mec` — Crear documento desde template
- [x] `upmec` — Actualizar documento existente
- [x] `+rm` — Agregar ítem a $RM
- [x] `backup` — Backup pre-edit genérico
- [x] `backupall` — Zip completo del proyecto
- [x] `foco` — Enfocar agente en área
- [x] `news` — Leer y distribuir $NEWS_FILE
- [x] `version` — Cerrar sesión: bump, updoc, commit
- [x] `report` — Reporte consolidado (fusión claude+upclaude)
- [x] `apply` — Aplicar handoff file a código
- [x] `head` — Preparar edición de sección en archivo
- [x] `notify` — Toggle de notificación remota
- [x] `/explica` — explicación breve de conceptos
- [x] `/diligencia-check` — validación automática de estructura
- [x] `/adaptar` modificado: copia comandos globales a .opencode/commands/ del proyecto
- [x] Nemesis cleanup: 12 archivos removidos, 3 archivados, AGENTS.md actualizado
- [x] HARNESS.md integrado al estándar: template, ADR-003, diligencia-check, /adaptar
- [x] `/deprecar` — deprecar archivos/estructuras obsoletas
- [x] `/bug` — reportar bugs en $BUGS con template estándar
- [x] `/incidente` — registrar crashes runtime en $INCIDENTS
- [x] GUIA_DE_BUENAS_PRACTICAS.md — hábitos y workflows para el desarrollador
- [x] MECANICA-DOCUMENTAL.md — mapa del motor documental
- [x] Template `incidentes.md` en doc-base (externalizado para /adaptar)
- [x] Template `sesion.md` en doc-base (journal multi-agente)
- [x] `/doctor` — cuidado integral del proyecto (estructura + código + tracking + limpieza)
- [x] `/reanudar` — recuperar sesión tras interrupción brusca
- [x] Template DILIGENCIA.md y adaptar.md sincronizados a v1.10.0 (bug: reportaban v1.7.1 y v1.3)
- [x] `/version`: si proyecto = Diligencia, actualiza template + adaptar.md al versionar
- [x] `/updoc`: D5 — detección de staleness template vs proyecto

## P2 — Próximos

- [x] `GUIA_ECOSISTEMAS.md` — mapa de ecosistemas y fronteras
- [x] CHANGELOG adopta Keep a Changelog: `[Unreleased]` + 6 categorías
- [x] ADR lifecycle states (Proposed → Accepted → Deprecated → Superseded)
- [x] `/commit` validación Conventional Commits (tipo/scope obligatorio)
- [x] `/version` soporte `[YANKED]` + migración automática de `[Unreleased]`

## P3 — Mejoras futuras

- [x] Script de validación de estructura
- [x] Plantillas por stack
- [x] Guía de referencia rápida
- [x] Integración con CI/CD — GitHub Actions workflow de validación de estructura Diligencia (Category A)
