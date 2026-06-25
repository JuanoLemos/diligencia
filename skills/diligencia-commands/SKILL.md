---
name: diligencia-commands
description: Referencia rápida de los 47 comandos Diligencia. Categorizados por función: sesión, documentación, diagnóstico, roadmap, utilidades. Usar cuando se necesita saber qué comando usar para cada situación.
license: AGPL-3.0
compatibility: opencode
metadata:
  category: diligencia
  version: "1.18.1"
  source: https://github.com/JuanoLemos/diligencia
---

# Diligencia — Commands Reference

## Sesión (6)

| Comando | Qué hace |
|---|---|
| `/CBP` | Orquestador vinculante (commit/parcial/full/updoc/doctor/version) |
| `/commit` | Commit rápido con Conventional Commits |
| `/version` | Bump semver + CHANGELOG + PRE-FLIGHT |
| `/plan` | Planificar tarea en modo lectura |
| `/pushgh` | Push a GitHub |
| `/reanudar` | Recuperar sesión tras interrupción |

## Documentación (7)

| Comando | Qué hace |
|---|---|
| `/updoc` | Auditoría y sync documental (Fases A→H) |
| `/estado` | Reporte rápido del proyecto |
| `/explica` | Explicación en 3 capas (criollo + técnico + impacto) |
| `/+guia` | Crear guía desde template |
| `/upguia` | Actualizar guía existente |
| `/+mec` | Crear mecánica desde template |
| `/upmec` | Actualizar mecánica existente |

## Diagnóstico & Salud (5)

| Comando | Qué hace |
|---|---|
| `/doctor` | Cuidado integral (3 fases) |
| `/salud` | Generar status-salud.md |
| `/diligencia-check` | Validar estructura ADR-003 |
| `/informe-salud` | Reporte cross-proyecto ($PROYECTOS) |
| `/health` | Verificar sintaxis y consistencia |

## Roadmap (5)

| Comando | Qué hace |
|---|---|
| `/rm` | Revisar ROADMAP por área |
| `/+rm` | Agregar item al ROADMAP |
| `/next` | Próximos 5 pasos |
| `/checklist` | Cruce RM + Checklist |
| `/foco` | Enfocar agente en área |

## Adaptación & Legal (4)

| Comando | Qué hace |
|---|---|
| `/adaptar` | Adaptar proyecto a Diligencia (Flujos A/B/C) |
| `/legal` | Verificar documentos legales |
| `/deprecar` | Deprecar archivos obsoletos |
| `/notify` | Toggle de notificación remota |

## Utilidades (9)

| Comando | Qué hace |
|---|---|
| `/debug` | Análisis profundo |
| `/limpiar` | Limpiar temporales |
| `/backup` | Backup pre-edit |
| `/backupall` | Zip completo del proyecto |
| `/bug` | Registrar bug |
| `/incidente` | Registrar incidente runtime |
| `/report` | Reporte consolidado |
| `/news` | Leer y distribuir $NEWS_FILE |
| `/apply` | Aplicar handoff file a código |

## Archivos relacionados

- `doc/guias/GUIA_DE_COMANDOS.md` — referencia completa
- `doc/guias/GUIA_REFERENCIA_RAPIDA.md` — chuleta de 1 página
