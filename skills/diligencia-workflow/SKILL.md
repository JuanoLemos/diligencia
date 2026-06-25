---
name: diligencia-workflow
description: Flujo completo de trabajo Diligencia: disciplina BUILD, PLAN, /CBP, Meta-PLAN, y reglas de sesión. Usar al iniciar cualquier proyecto adaptado para recordar el ciclo de trabajo correcto.
license: AGPL-3.0
compatibility: opencode
metadata:
  category: diligencia
  version: "1.18.1"
  source: https://github.com/JuanoLemos/diligencia
---

# Diligencia — Workflow

## Ciclo de sesión

```
PRE-SESIÓN          SESIÓN              POST-SESIÓN
──────────          ──────              ───────────
Leer AGENTS.md      /plan → BUILD       /CBP
Revisar $RM         /commit             /version
/estado             /updoc              /pushgh
```

## Reglas inmutables (MANDATO.md)

- M1: AGENTS.md es el SSOT del proyecto
- M2: Estructura documental fija
- M3: Solo /commit, /CBP y /version pueden commitear
- M4: Todo workflow sigue PLAN → BUILD
- M5: Pre-flight de versión Diligencia antes de cualquier /CBP

## Disciplina BUILD

BUILD = aplicar cambios, NO commitear. Solo /commit, /CBP y /version ejecutan git commit.
Al terminar cualquier BUILD, reportar cambios aplicados y sugerir /CBP.

## Comandos autorizados para commit

Solo estos tres comandos pueden ejecutar git commit:
- `/commit` — commit rápido con Conventional Commits
- `/CBP` — orquestador con commit integrado
- `/version` — bump semver + CHANGELOG + commit + tag

## Archivos relacionados

- `MANDATO.md` — 5 mandatos MVP
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` — hábitos y workflows
- `~/.config/opencode/opencode.jsonc` — instrucción BUILD
