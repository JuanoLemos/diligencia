---
name: diligencia-health
description: Diagnóstico y monitoreo de salud para proyectos Diligencia. Cubre /doctor, /salud, /diligencia-check y /informe-salud. Usar cuando el usuario necesita revisar la integridad estructural del proyecto.
license: AGPL-3.0
compatibility: opencode
metadata:
  category: diligencia
  version: "1.18.1"
  source: https://github.com/JuanoLemos/diligencia
---

# Diligencia — Health

## Comandos disponibles

| Comando | Qué hace |
|---|---|
| `/doctor` | Diagnóstico integral (3 fases: estructura + código + corrección) |
| `/salud` | Genera `doc/arch/status-salud.md` con 10 indicadores |
| `/diligencia-check` | Validación estructural en 4 categorías (ADR-003, variables, comandos, versión) |
| `/informe-salud` | Reporte consolidado multi-proyecto (escanea $PROYECTOS) |

## Cuándo usar cada uno

| Situación | Comando |
|---|---|
| Proyecto recién adaptado | `/diligencia-check` |
| Revisión periódica | `/doctor` |
| Después de cambios documentales | `/salud` |
| Múltiples proyectos a la vez | `/informe-salud` |

## Flujo típico

```
/diligencia-check  → valida estructura
/doctor            → diagnostica + corrige
/salud             → genera reporte
/informe-salud     → cross-proyecto (si $PROYECTOS definido)
```

## Archivos relacionados

- `~/.config/opencode/commands/doctor.md`
- `~/.config/opencode/commands/salud.md`
- `~/.config/opencode/commands/diligencia-check.md`
- `~/.config/opencode/commands/informe-salud.md`
