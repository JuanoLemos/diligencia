# Diligencia

Estructura estándar de documentación para proyectos OpenCode.

Diligencia define dónde vive cada tipo de archivo, cómo se nombran las variables de ruta, cómo se organizan los comandos y cómo mantener la documentación sincronizada con el código.

---

## Quickstart

```bash
# Adaptar un proyecto existente a Diligencia
/adaptar

# Ver el estado de salud documental
/diligencia-check

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
├── LICENSE                — GPL-3.0
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
| **/CBP** | Circuito de Buenas Prácticas — orquestador de workflows (updoc, doctor, version) |
| **SDD** | Spec-Driven Development — flujo de agentes: @sdd-architect → @sdd-implement → @sdd-verify → @sdd-reviewer |
| **TDD estricto** | RED→GREEN→TRIANGULATE→REFACTOR — ciclo ejecutado por el agente (skill tdd-strict) |

## Proyectos adaptados

| Proyecto | Fecha | Estado |
|---|---|---|
| Diligencia (autor) | 2026-05-31 | ✅ |
| proyecto-alfa Detective | 2026-05-08 | ✅ |
| proyecto-beta | 2026-05-08 | ✅ |

## Licencia

GPL-3.0 — ver [LICENSE](LICENSE).
