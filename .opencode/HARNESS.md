# HARNESS.md — Diligencia

Harness global: `~/.config/opencode/`
Versión: 2.0.0 | Creado: 2026-05-31

---

## Comandos del proyecto

| Tipo | Comando | Notas |
|---|---|---|
| Test | *(no configurado)* | Proyecto documental sin test runner |
| Lint | *(no configurado)* | |
| Verify | `/diligencia-check` | Valida estructura, variables, comandos, versión |
| Start | *(no aplica)* | |

## Documento SSOT del proyecto

Archivo principal: `AGENTS.md`

## Skills locales del proyecto

| Skill | Ruta |
|---|---|
| diligencia-cbp | `skills/diligencia-cbp/SKILL.md` |
| diligencia-health | `skills/diligencia-health/SKILL.md` |
| diligencia-docs | `skills/diligencia-docs/SKILL.md` |
| diligencia-workflow | `skills/diligencia-workflow/SKILL.md` |
| diligencia-commands | `skills/diligencia-commands/SKILL.md` |
| diligencia-consejo | `skills/diligencia-consejo/SKILL.md` |
| diligencia-circuito | `skills/diligencia-circuito/SKILL.md` |

## Stack

- Metodología documental (sin código runtime)
- Markdown + OpenCode
- Sin dependencias de compilación

## Convenciones

- Idioma: español (todas las respuestas del agente deben ser en español)
- Versiones: vX.Y semver
- Prefijos: P1/P2/P3 (prioridad), ADR-NNN (arch)
- Comandos: guarda + secciones estándar (ESTANDAR-COMANDOS.md)

## Archivos críticos

- `AGENTS.md` (variables y comandos)
- `ROADMAP.md` (plan)
- `ROADMAP.md (tareas y planning)
- `doc/arch/ADR-*.md` (decisiones arquitectónicas)
- `doc/guias/ESTANDAR-COMANDOS.md` (estándar)

## Harness activo

- [x] Agentes SDD globales disponibles
- [x] HARNESS.md completado
- [ ] TDD (sin test runner)
- [x] Post-edit verification activa (AGENTS.md + HARNESS.md)

## Archivos relacionados
- `AGENTS.md` — variables de ruta y comandos
- `doc/guias/ESTANDAR-COMANDOS.md` — estándar de formato de comandos
