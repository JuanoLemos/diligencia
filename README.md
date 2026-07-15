# Diligencia

![Status](https://img.shields.io/badge/status-beta-ff69b4?style=flat-square)
![License](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)
![Version](https://img.shields.io/badge/version-v2.7.2-8A2BE2?style=flat-square)
[![Issues](https://img.shields.io/badge/issues-7%20proyectos-181717?style=flat-square)](https://github.com/JuanoLemos/diligencia/issues)

Estructura estándar de documentación para proyectos OpenCode.
Diligencia existe para que tu proyecto tenga memoria. Cada paso deja constancia, cada decisión se registra, cada sesión cierra en orden. Sin burocracia, sin herramientas complejas, sin depender de un solo proveedor de IA.

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

Diligencia está diseñada para **cualquier persona que quiera ordenar su proyecto con ayuda de IA**. Si usás OpenCode y querés dejar de perder tiempo buscando archivos o adivinando qué se hizo en la sesión anterior, Diligencia es para vos.

No requiere que escribas código runtime — Diligencia organiza los artefactos que los agentes generan:
documentación, decisiones de arquitectura, registros de sesión, comandos y tracking de proyecto.
Si tu flujo es `/plan → edición → /CBP`, Diligencia es para vos.

### Niveles de madurez

Diligencia escala con tu proyecto. No necesitás usarlo todo desde el día uno.

| Nivel | Cuándo | Qué usás | Tiempo |
|---|---|---|---|
| **L0 — Arranque** | Idea nueva, cero estructura | `/adaptar` | 5 min |
| **L1 — Ritmo** | Ya codeás, querés orden | `/CBP updoc`, `/commit --push` | 2 min por sesión |
| **L2 — Profesional** | Equipo, PRs, funcionalidades | Agentes SDD, palomas, ADRs | Según complejidad |
| **L3 — Orquesta** | Múltiples proyectos activos | Gran Orquestador, `/propagar`, Chamber | Infraestructura propia |

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
| Diligencia (metodología) | v2.7.2 | ✅ |
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
