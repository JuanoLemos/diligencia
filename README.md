# Diligencia

![Status](https://img.shields.io/badge/status-beta-ff69b4?style=flat-square)
![License](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)
![Version](https://img.shields.io/badge/version-v2.4.2-8A2BE2?style=flat-square)
[![Issues](https://img.shields.io/badge/issues-7%20proyectos-181717?style=flat-square)](https://github.com/JuanoLemos/diligencia/issues)

Estructura estándar de documentación para proyectos OpenCode.
Diligencia es una metodología **plural y gratuita** para mejorar la experiencia de desarrollo con agentes IA.

Diligencia define dónde vive cada tipo de archivo, cómo se nombran las variables de ruta, cómo se organizan los comandos y cómo mantener la documentación sincronizada con el código.

---

## Quickstart

```bash
# Adaptar un proyecto existente a Diligencia
/adaptar

# Ver el estado de salud del proyecto (8 fases de diagnóstico)
/salud

# Auditoría documental completa (24 checks en 6 categorías)
/documentar

# Plan de ejecución por olas (agrupa tareas por dependencias)
/next

# Sincronizar documentación antes de cerrar sesión
/CBP updoc

# Cerrar sesión con versionado
/CBP version
```

## ¿Para quién es Diligencia?

Diligencia está diseñada para **operadores y orquestadores de agentes IA** que trabajan con OpenCode.
No requiere que escribas código runtime — Diligencia organiza los artefactos que los agentes generan:
documentación, decisiones de arquitectura, registros de sesión, comandos y tracking de proyecto.
Si tu flujo es `/plan → edición → /CBP`, Diligencia es para vos.

## Estructura del repositorio

```
/
├── AGENTS.md              — Variables de ruta y comandos del proyecto
├── CHANGELOG.md           — Historial versionado (Keep a Changelog)
├── CHECKLIST.md           — Tracking operativo de tareas
├── DILIGENCIA.md          — Sello de la metodología
├── INDEX.md               — Catálogo de documentación
├── ROADMAP.md             — Estrategia y próximos pasos
├── README.md              — Esta página
├── LICENSE                — AGPL-3.0
├── .markdownlint.json     — Reglas de Markdown
├── .gitignore
├── doc/
│   ├── arch/              — ADRs, bitácora, reportes de salud
│   ├── guias/             — Guías de usuario y contribución
│   └── mecanicas/         — Mecánicas documentales
└── .opencode/
    ├── HARNESS.md          — Configuración de test/lint/skills
    └── commands/           — Comandos locales del proyecto
```

## Metodología

| Concepto | Descripción |
|---|---|
| **ADR-003** | Estructura estándar de documentación — árbol de archivos obligatorios y opcionales |
| **Enforcement 3 capas** | Runtime (opencode.jsonc), pre-commit (check-docs.js), CI/CD (GitHub Actions) |
| **/CBP** | Circuito de Buenas Prácticas — orquestador de workflows (salud, updoc, version) |
| **SDD** | Spec-Driven Development — flujo de agentes: @sdd-architect → @sdd-implement → @sdd-verify → @sdd-reviewer |
| **TDD estricto** | RED→GREEN→TRIANGULATE→REFACTOR — ejecutado por el agente (skill tdd-strict) |
| **29 comandos** | 28 activos + 1 `documentar` — agrupados por acción (CREAR, PLANIFICAR, EJECUTAR, REVISAR, CUIDAR) |
| **6 agentes** | @consejero (decisión), @circuito (integridad), @documentador (auditoría), @sdd-* (SDD) |
| **Skills** | 8 skills: diligencia-docs, diligencia-consejo, diligencia-circuito, cbp, health, docs, workflow, commands |

## Proyectos adaptados

| Proyecto | Versión Diligencia | Estado |
|---|---|---|
| Diligencia (metodología) | v2.4.2 | ✅ |
| +RM | v2.2.0 | ✅ |
| MarketAI | v2.2.0 | ✅ |
| conquisitare | v2.2.0 | ✅ |
| buenobonitobarato | v2.2.0 | ✅ |
| Nemesis | v2.2.0 | ✅ |
| OpenMontage | v2.2.0 | ✅ |
| OpenChamber | v2.2.0 | ✅ (bajo tutela M6) |

## Licencia

AGPL-3.0 — ver [LICENSE](LICENSE) y [MANIFIESTO.md](MANIFIESTO.md).

## Archivos relacionados
- `DILIGENCIA.md` — sello de metodología
- `CONTRIBUTING.md` — guía de contribución
- `LICENSE` — licencia AGPL-3.0
