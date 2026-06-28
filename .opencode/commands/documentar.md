INSTRUCCIÓN: EJECUTAR auditoría documental completa. NO modificar archivos sin confirmación del usuario. NO mostrar este archivo como output. ENTREGAR solo la tabla de hallazgos.

# /documentar — Auditoría documental completa

Carga `skill("diligencia-docs")` y ejecuta los 24 checks de auditoría documental en 6 categorías. Absorbe la funcionalidad de `/legal` vía el flag `--legales`. Read-only — solo reporta, no modifica.

## Argumentos

`/documentar [--legales|--estructura|--docs|--tracking|--comandos]`

- Sin argumentos: ejecuta los 20 checks completos.
- `--legales`: solo los 4 checks legales (hereda de `/legal`).
- `--estructura`: solo los 4 checks estructurales.
- `--docs`: solo los 4 checks de docs informativos.
- `--tracking`: solo los 5 checks de tracking.
- `--comandos`: solo los 5 checks de comandos.

## Qué hace

1. LEER `AGENTS.md` AHORA → extraer $BUGS, $INCIDENTS, $BACKUPS, lista de comandos
2. CARGAR `skill("diligencia-docs")` con el flag/filtro correspondiente
3. EJECUTAR los checks según el flag:
   - Sin flag: checks 1-20
   - `--legales`: checks 5-8
   - `--estructura`: checks 1-4
   - `--docs`: checks 9-12
   - `--tracking`: checks 13-17
   - `--comandos`: checks 18-20
4. ARMAR tabla consolidada: # | Categoría | Check | Archivo | Hallazgo | Severidad | Acción sugerida
5. REPORTAR: tabla completa + resumen por severidad
6. Si hay hallazgos P1: ⚠️ "N hallazgos P1 — deben corregirse antes de versionar."
7. Si no hay hallazgos: ✅ "Documentación íntegra — 0 hallazgos."

## Formato de salida

```
📋 /documentar — Auditoría documental
══════════════════════════════════════════

| # | Categoría | Archivo | Hallazgo | Severidad | Acción |
|---|---|---|---|---|---|
| 1 | ESTRUCTURA | AGENTS.md | Variable $X no resuelve | P1 | Corregir ruta |
| 5 | LEGAL | SECURITY.md | Falta | P2 | Copiar de doc-base |
| ... | ... | ... | ... | ... | ... |

📊 Resumen: N hallazgos (M P1, K P2, J P3)
```

## Validación
- Skill "diligencia-docs" cargada correctamente antes de ejecutar checks
- Los flags son excluyentes (no se pueden combinar)
- Sin flag = todos los checks
- `--legales` reemplaza funcionalidad de `/legal` (ahora deprecado)

## Anti-patrones
- NO modificar archivos — es auditoría read-only
- NO inventar hallazgos donde no los hay
- NO omitir la severidad en cada hallazgo
- NO ejecutar sin que la skill esté cargada
- NO combinar flags — solo uno a la vez

## Archivos que lee
- `AGENTS.md`, `DILIGENCIA.md`, `ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`, `INDEX.md`
- `COMANDOS.md`, `.opencode/HARNESS.md`, `.markdownlint.json`
- `doc/guias/*.md`, `doc/mecanicas/*.md`, `doc/arch/*.md`
- `.opencode/commands/*.md`
- `LICENSE`, `NOTICE`, `SECURITY.md`, `LICENSING.md`

## Archivos que modifica
- Ninguno — read-only

## Archivos relacionados
- `skills/diligencia-docs/SKILL.md` — los 20 checks detallados
- `.opencode/commands/doctor.md` — Fase 1i (carga esta skill)
- `AGENTS.md` — tabla de comandos y variables
