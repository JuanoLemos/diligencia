---
name: diligencia-docs
description: Sincronización y auditoría documental para proyectos Diligencia. Cubre /updoc, /estado, INDEX.md, ROADMAP.md y el catálogo documental. Usar cuando el usuario necesita mantener sus documentos al día.
license: AGPL-3.0
compatibility: opencode
metadata:
  category: diligencia
  version: "1.18.1"
  source: https://github.com/JuanoLemos/diligencia
---

# Diligencia — Docs

## Comandos disponibles

| Comando | Qué hace |
|---|---|
| `/updoc` | Auditoría documental (Fases A→H: INDEX, stale, gaps, cross-refs) |
| `/estado` | Reporte rápido: git log, diff, RM, CHECKLIST, recomendaciones |
| `/+guia` | Crear nueva guía en `doc/guias/` desde template |
| `/+mec` | Crear nueva mecánica en `doc/mecanicas/` desde template |

## Estructura documental

```
doc/
├── guias/       → Guías de uso (12+)
├── mecanicas/   → Mecánicas del proyecto (21+)
├── arch/        → ADRs + SISTEMA + bitácora
├── qa/          → Situaciones a revisar
└── pendientes/  → Pendientes de revisión
```

## Cuándo sincronizar

- Después de crear/eliminar guías o mecánicas
- Cuando INDEX.md muestra labels stale
- Antes de un release (`/CBP full` lo hace automático)

## Archivos relacionados

- `~/.config/opencode/commands/updoc.md`
- `~/.config/opencode/commands/estado.md`
- `doc/guias/GUIA_DE_COMANDOS.md`
