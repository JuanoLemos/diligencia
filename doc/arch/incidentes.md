# Incidentes — Diligencia

**Actualizado:** 2026-07-31 | **Total:** 1 (1 cerrado)

---

## Resumen

| Total | P1 | P2 | P3 | Abiertos |
|---|---|---|---|---|
| 1 | 1 | 0 | 0 | 0 |

---

## Registro de incidentes

### ICT-DIL-20260731-01 — Custom `_diligencia` bloquea validación de opencode.jsonc
| Campo | Detalle |
|---|---|
| **Fecha** | 2026-07-31 |
| **Severidad** | P1 (impide arranque del CLI) |
| **Stack** | opencode 1.18.9 + Chamber Electron + Diligencia v3.9.0–v3.9.2 |
| **Síntoma** | `Configuration is invalid at ~/.config/opencode/opencode.jsonc ↳ Unrecognized key: _diligencia` |
| **Causa raíz** | `scripts/ensure-config.ps1` (introducido en v3.9.0) escribía un bloque `_diligencia` en la raíz del JSONC. El schema oficial de opencode (`https://opencode.ai/config.json`) solo permite keys documentadas; **NO** tolera `additionalProperties` custom. |
| **Por qué pasó inadvertido** | `opencode serve` (modo servidor HTTP) NO valida strict, por lo que las requests API funcionaron toda la sesión. Solo `opencode` CLI/TUI valida strict y crasheó al primer intento del usuario de usar el TUI. |
| **Mitigación inmediata** (usuario) | Eliminar manualmente el bloque `_diligencia` del `opencode.jsonc`. |
| **Mitigación definitiva** (v3.10.0) | 1) Reescribir `ensure-config.ps1` para no agregar el bloque. 2) Mover metadata Diligencia a archivo separado `~/.config/opencode/.diligencia.json`. 3) Pre-flight valida que el JSONC no tenga custom keys antes de escribir. |
| **Lección** | Mezclar metadata de gobernanza con config de herramienta es un anti-patrón. Usar archivos separados leídos vía `{file:...}` en campos válidos del schema. |
| **Referencias** | schema: `https://opencode.ai/config.json` · docs: `https://opencode.ai/docs/config/` · base de datos: `doc/refs/opencode-schema.md`, `doc/refs/integration-patterns.md` |
| **Estado** | ✅ Cerrado (v3.10.0) |

## Archivos relacionados
- `doc/arch/bugs.md` — bug tracker
- `doc/mecanicas/MECANICA-CALIDAD.md` — mecánica de calidad documental
- `doc/refs/opencode-schema.md` — schema oficial opencode
- `doc/refs/openchamber-overview.md` — overview Chamber
- `doc/refs/integration-patterns.md` — patrones Diligencia↔opencode/Chamber
