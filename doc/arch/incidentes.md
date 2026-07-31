# Incidentes — Diligencia

**Actualizado:** 2026-07-31 | **Total:** 1 (1 cerrado)

---

## Resumen

| Total | P1 | P2 | P3 | Abiertos |
|---|---|---|---|---|
| 2 | 1 | 1 | 0 | 0 |

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
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — bump policy y pre-check

---

## Registro de incidentes

### ICT-DIL-20260731-02 — Bumps excesivos de versión (4 en una sesión)
| Campo | Detalle |
|---|---|
| **Fecha** | 2026-07-31 |
| **Severidad** | P2 (contaminación de histórico) |
| **Stack** | Diligencia v3.9.0 → v3.10.1 + MiniMax M2.7 (provider LLM) |
| **Síntoma** | 4 commits release en 1 sesión: v3.9.1, v3.9.2, v3.10.0, v3.10.1. Análisis: solo 2 ameritaban bump (v3.9.1 por fixes /salud y v3.10.0 por ICT fix). v3.9.2 (45 commits de ruido VAIO) y v3.10.1 (solo docs + agents) NO justificaban. |
| **Causa raíz** | (a) R6 ambigua: "versionar cambios metodológicos" sin definir qué es metodológico. (b) Pre-check ausente: el algoritmo CBP preguntaba al usuario "versionar?" y casi siempre la respuesta era "sí". (c) Personalidad del modelo (MiniMax M2.7): "completion-oriented" — terminaba tareas agregando "el toque final" (bump + tag + push). |
| **Hipótesis DeepSeek vs MiniMax** | El usuario notó que con DeepSeek no pasaba. La diferencia NO es el modelo sino: (a) el algoritmo CBP da permiso ambiguo, (b) cualquier modelo completion-oriented ejecuta la acción. La solución NO es cambiar de modelo, es hacer el algoritmo estricto. |
| **Mitigación definitiva** (v3.10.2) | 1) **R6 refinada en `AGENTS.md`** con criterios explícitos: enumera qué SÍ amerita (commands/, mecánicas/, R-numbers, ICT crítico) y qué NO (heartbeats, docs solos, agents de proyecto, ruido). 2) **Pre-check en `CBP.md`**: detecta cambios al SHELL antes de bumpear. Si no hay match, fuerza `commit` sin tag. 3) **Sección §9.5 en GUIA_DE_BUENAS_PRACTICAS** con checklist de categorías. 4) **ICT documentado** para trazabilidad. |
| **Lección** | Cuando un algoritmo permite ambigüedad, el modelo tiende a tomar la ruta "completa" (bump + tag + push). La solución es el algoritmo estricto, no el modelo. **Pre-check obligatorio** basado en archivos modificados, no en juicio del agente. |
| **Recomendación de modelo** | Para decisiones de versionado, usar **MiniMax M3** (más capaz) o modelo con **temperatura baja** (0.0). Evitar M2.7 para commit-level decisions. |
| **Estado** | ✅ Cerrado (v3.10.2) |

## Archivos relacionados
- `doc/arch/bugs.md` — bug tracker
- `doc/mecanicas/MECANICA-CALIDAD.md` — mecánica de calidad documental
- `doc/refs/opencode-schema.md` — schema oficial opencode
- `doc/refs/openchamber-overview.md` — overview Chamber
- `doc/refs/integration-patterns.md` — patrones Diligencia↔opencode/Chamber
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — bump policy y pre-check
- `AGENTS.md` R6 — versión refinada de la regla
