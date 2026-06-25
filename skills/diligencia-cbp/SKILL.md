---
name: diligencia-cbp
description: Orquestador vinculante de Diligencia. Cierra sesiones, versiona proyectos y mantiene el orden documental. Usar cuando el usuario necesita commitear cambios, cerrar una etapa de trabajo o mantener la documentación sincronizada.
license: AGPL-3.0
compatibility: opencode
metadata:
  category: diligencia
  version: "1.18.1"
  source: https://github.com/JuanoLemos/diligencia
---

# Diligencia — /CBP

## Qué es

`/CBP` (Commit + BUILD + Plan) es el orquestador central de Diligencia. Decide automáticamente qué camino tomar según el working tree y ejecuta el workflow adecuado.

## Cuándo usarlo

- Al final de cada sesión de trabajo
- Cuando el working tree tiene cambios sin commitear
- Para cerrar una etapa y versionar

## Caminos disponibles

| Camino | Cuándo se usa |
|---|---|
| `commit` | Solo código modificado, 0 docs |
| `parcial` | 1-5 docs, sin nuevas guías/mecánicas |
| `full` | 5+ docs o milestones |
| `updoc` | Post-sesión con auditoría completa |
| `doctor` | Diagnóstico integral |
| `version` | Versionado standalone |

## Cómo se ejecuta

```
/CBP              → detección automática del camino
/CBP commit       → commit rápido
/CBP parcial      → sync documental ligero
/CBP full         → ciclo completo con Meta-PLAN
```

El orquestador lee `~/.config/opencode/commands/CBP.md` para el SSOT del flujo.

## Reglas

- Solo /commit, /CBP y /version pueden ejecutar git commit (Regla #17)
- Todo workflow sigue PLAN (razonamiento) → BUILD (ejecución)
- Pre-flight verifica versión Diligencia antes de actuar

## Archivos relacionados

- `~/.config/opencode/commands/CBP.md` — especificación completa
- `doc/mecanicas/MECANICA-CBP.md` — circuito documentado
- `doc/mecanicas/MECANICA-FLUJO.md` — flujo detallado
