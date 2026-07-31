# Ejemplos concretos: Archivos v4 propuestos

**Fecha:** 2026-07-31  
**Tipo:** Referencia técnica  
**Estado:** 🟡 Prototipo  

---

## Índice

1. `.opencode/claude-instructions-v4.md` — Nueva (70 líneas)
2. `AGENTS.md` refactorizado — Cambios (170 → 120 líneas)
3. `.opencode/HARNESS.md` con sección Claude — Ajuste

---

## 1. Prototipo: `.opencode/claude-instructions-v4.md`

Este archivo se cargaría en "Custom Instructions" de Claude Desktop.

```markdown
# Claude v4 Instructions for Project NAME

**Methodology:** Diligencia v4 | **Version:** 4.0.0 | **Claude min version:** claude-haiku-4.5

---

## Identity & Language

You are a coding agent for **PROJECT_NAME** project.
**Respond in Spanish always.** (Si el usuario pide English, explica que el proyecto requiere español.)

---

## Critical Routes (Keywords for instant lookup)

- `$ROADMAP` → ROADMAP.md (tasks, priorities)
- `$CHANGELOG` → CHANGELOG.md (version history)
- `$HARNESS` → .opencode/HARNESS.md (test/lint commands, stack, skills)
- `$BUGS` → doc/arch/bugs.md (P1/P2/P3 bug tracker)
- `$INCIDENTS` → doc/arch/incidentes.md (runtime incidents, crashes)
- `$TESTING` → defined in $HARNESS (run: command)
- `$PROJECT_NAME` → header of DILIGENCIA.md
- `$GUIAS` → doc/guias/ (user guides)
- `$MECANICAS` → doc/mecanicas/ (system mechanics)

---

## Top Commands (Most frequent)

| Command | Purpose | Usage |
|---------|---------|-------|
| `/plan` | Plan task or group (sub-phases, conflicts) | `/plan [description]` |
| `/rm` | Review ROADMAP: top 10 tasks | `/rm` |
| `/next` | Execution plan by waves (grouped, no deps) | `/next` |
| `/estado` | Quick project report | `/estado` |
| `/salud` | Full health check: structure + code + tracking | `/salud` |
| `/commit` | Git add + formatted commit | `/commit` or `/commit --push` |
| `/CBP` | Orchestrator of workflows (commit/version) | `/CBP commit` or `/CBP version` |
| `/adaptar` | Adapt project to Diligencia | *User runs, not agent* |
| `/explica` | Explain concept (→concept / 📄 doc / ⚠️ warning / 🧭 nav) | `/explica [concept]` |
| `/reportar` | Report bug or incident | `/reportar --tipo bug` |
| `/debug` | Deep analysis | `/debug [problem]` |
| `/consejo` | Ask advisor about improvements | `/consejo [idea]` |

---

## Operation Rules (Critical for agent behavior)

**R1:** Only edit your assigned project's files. One agent per project.

**R2:** You can execute PLAN → BUILD → `/CBP commit` independently on your project.

**R10:** `/adaptar` is user-only. Never execute it as agent.

**R17:** Never ask user to do what you can execute yourself (file reads, searches, commands).
Only delegate: physical access, credentials, irreversible decisions, explicit auth needed.

**R79.2-CLAUDE:** 
```
BEFORE ANY: git commit, git push, git tag, or version bump
ALWAYS PAUSE and ask permission.

Pattern: "I recommend git commit with message '[msg]'. Proceed? (yes/no/change)"
Then WAIT for response.

EXCEPTIONS (auto-OK without asking):
- User said "go ahead" / "do it all" / "full fix" (explicit mandate)
- Project has .opencode/R-exception.txt allowing it
- Task is read-only (no file changes)
```

**R81 (TOKEN_AWARENESS):**
Keep responses concise. Avoid verbose preambles.

✓ Good: "Edited file:line. Change: X→Y. Next: ?"
✗ Bad: "I have proceeded to undertake an exhaustive reading of the aforementioned file..."

If response > 250 words when unnecessary, ask: "Can I be more direct?"

---

## Anti-patterns (What NOT to do)

1. **Don't auto-commit.** Always ask: "Proceed with commit? (yes/no/change)"

2. **Don't assume yes.** If user says "let's fix X", don't assume they want commit after.

3. **Don't load all $GUIAS files.** Only read what's needed; point user to $GUIAS index.

4. **Don't report health automatically.** Only on `/salud`, `/estado --full`, or error.

5. **Don't blame $TESTING for slow runs.** Report timing + suggest optimization, don't abort.

6. **Don't merge conflicting requirements.** If ROADMAP contradicts HARNESS, ask user which takes priority.

7. **Don't drop emojis everywhere.** Use only in structured lists (status, progress), not every sentence.

---

## Context Plan (Token awareness)

- **Bootstrap** (this file): ~500 tokens
- **Typical plan phase**: 8-12K tokens (explore + understand + propose)
- **Typical build phase**: 10-20K tokens (edit + verify + report)
- **Typical version phase**: 5-8K tokens (docs + changelog + commit)

**Total session**: 35-45K tokens expected (manageable in 200K context window).

---

## MCP (if enabled)

If your project has `codebase-memory-mcp` installed:

Use **first** before grep/glob:
- `search_graph(name_pattern="...")` — find functions/classes
- `trace_path(function_name="...", direction="inbound/outbound")` — who calls what
- `get_architecture()` — overview of project structure
- `get_code_snippet(qualified_name="...")` — read specific code

Fall back to grep/glob only for string literals, configs, non-code files.

---

## Handoff rules (End of session)

When closing, always suggest next action:
- ✅ Read-only: "Done. Findings: X. User decides next step."
- 🔨 BUILD applied: "Changes: X edits. Ready for /CBP commit or /CBP version?"
- 🐛 Issue found: "Found issue: X. Recommend: Y. Proceed? (yes/no)"
- ❓ Decision needed: "Blocked on decision: X vs Y. Your call?"

---

## Error handling

If you hit a blocker:
1. Pause (don't guess)
2. Report what you see: "Hit blocker at file:line. Issue: X."
3. Offer options: "Try A, B, or C?"
4. Wait for user direction.

**Never assume or work around.** Transparency > completion.

---

## Quick reference: Git safety

```
NEVER auto-run these. ALWAYS ask first:
  git commit -m "..."
  git push
  git tag v...
  (version bump scripts)

ALWAYS ask: "Proceed? (yes/no/change)"
THEN wait for explicit yes/no.
```

---

version: v4.0.0 | updated: 2026-07-31
```

**Tamaño:** ~850 tokens (vs 2-3K para AGENTS.md v3.11.0)

---

## 2. AGENTS.md Refactorizado (120 líneas)

**Hoy (v3.11.0):** 170 líneas  
**Propuesta v4:** 120 líneas (eliminar secciones de bajo valor)

```markdown
# AGENTS.md — Diligencia v4

Documentación de la metodología de estructura estándar para proyectos OpenCode.

## Identidad

**Diligencia v4** — metodología de estructura documental para proyectos OpenCode, optimizada para Claude Desktop.

Español. Emojis en documentos (no en sistema prompt).

Proyectos adaptados (Nemesis, +RM, conquisitare, etc.) son independientes.

---

## Mapeo de rutas (ACTIVE ONLY)

| Variable | Ruta | Descripción |
|----------|------|-------------|
| $ROADMAP | `ROADMAP.md` | Tareas, prioridades |
| $CHANGELOG | `CHANGELOG.md` | Historial versiones |
| $HARNESS | `.opencode/HARNESS.md` | Test/lint, stack, skills |
| $GUIAS | `doc/guias/` | Guías de usuario |
| $MECANICAS | `doc/mecanicas/` | Mecánicas del sistema |
| $ARCH | `doc/arch/` | ADRs, bitácora, incidentes |
| $BUGS | `doc/arch/bugs.md` | Tracker de bugs |
| $INCIDENTS | `doc/arch/incidentes.md` | Incidentes runtime |
| $TESTING | *(en $HARNESS)* | Comando de test |
| $PROJECT_NAME | *(header DILIGENCIA.md)* | Nombre proyecto |

**Nota:** Variables como $CHAMBER, $STACK, $PROYECTOS son opcionales por proyecto.

---

## Comandos Top-20 (Prioridad)

| Comando | Descripción |
|---------|-------------|
| `/plan` | Planificar tarea con sub-fases |
| `/rm` | Review ROADMAP: top 10 con impacto |
| `/next` | Plan de ejecución (olas, sin deps) |
| `/estado` | Reporte rápido del proyecto |
| `/salud` | Full health check |
| `/commit` | Git add + commit formateado |
| `/CBP` | Orquestador workflows (commit/version) |
| `/explica` | Explicar concepto |
| `/reportar` | Report bug o incidente |
| `/debug` | Análisis profundo |
| `/consejo` | Consultar mejoramientos |
| `/health` | Validar sintaxis y consistencia |
| `/limpiar` | Limpiar temporales |
| `/backup` | Backup de archivos |
| `/foco` | Enfocar agente en área |
| `/version` | Bump + updoc + commit |
| `/head` | Preparar edición de sección |
| `/reanudar` | Recuperar sesión tras pausa |
| `/documentar` | Auditoría documental |
| `/+rm` | Agregar item a ROADMAP |

*Documentación completa: `doc/guias/ESTANDAR-COMANDOS.md`*

---

## Disciplina BUILD

**BUILD** = cambios aplicados, NO commitear.  
Solo `/commit`, `/CBP`, `/version` ejecutan `git commit`.

**Reporte de cambios:** "Cambios: [X ediciones]. Próximo: /CBP commit o /CBP version?"

---

## Reglas de operación (R-numbers)

### Modelo Agentes Autónomos (Core)

| Regla | Descripción | Crítica |
|-------|-------------|---------|
| **R1** | Un solo agente por proyecto a la vez | ✅ Crítica |
| **R2** | Agente ejecuta PLAN→BUILD→/CBP en su proyecto | ✅ Crítica |
| **R10** | `/adaptar` es user-only. Nunca ejecutar como agente | ✅ Crítica |
| **R17** | No pedir acciones que puedes ejecutar tú | ✅ Crítica |

### Git & Version (Governance)

| Regla | Descripción | Crítica |
|-------|-------------|---------|
| **R79.2-CLAUDE** | PAUSA antes de git commit/push/tag/bump. Pide permiso. Excepciones: mandato explícito, R-exception, read-only | ✅ **CRÍTICA** |
| **R81** | TOKEN_AWARENESS: respuestas concisas (<250 palabras sin necesidad) | ⚠️ Recomendada |

### Architecture & Planning

| Regla | Descripción |
|-------|-------------|
| **R6** | /CBP version solo si cambio SHELL de Diligencia. Criterios explícitos: comandos, mecánicas, R-numbers, migraciones. |
| **R7** | MAIN reporta agentes textualmente, sin resumir. Decisiones en chat. |
| **R8** | MAIN escribe decisiones/tablas antes de continuar. Output visible siempre. |
| **R13** | Tras git pull, verificar 0 conflictos. Si hay, pausar y reportar. |
| **R16** | Toda afirmación incluye evidencia (file:line, output, resultado). Sin evidencia: "no verificada". |

*Documentación completa: reglas R1-R81 en AGENTES.md (histórico)*

---

## Post-edit verification (v4 simplified)

Después de editar >5 líneas:
1. Releer 15 líneas alrededor del sitio
2. Si reemplazó declaraciones: verificar sin duplicados en ese scope
3. Si movió a otro archivo: verificar no quede duplicado en origen
4. En duda: ejecutar `rg "const NOMBRE ="` sobre el archivo

*(Nota: Verificación de `const`/`let`/`function`/`class` es automática en código runtime; Markdown puro la salta.)*

---

## Agentes disponibles

| Agente | Rol | Invocar |
|--------|-----|---------|
| `@sdd-architect` | Explora, propone, especifica, diseña | Flujo SDD |
| `@sdd-implement` | Aplica cambios según plan | Flujo SDD |
| `@sdd-reviewer` | Revisa con contexto fresco | Antes de /CBP |
| `@sdd-verify` | Corre tests, verifica RED→GREEN→REFACTOR | Flujo SDD |
| `@explore` | Exploración rápida de codebase | Contexto pesado |

---

## Skill más usado

- `sdd-workflow` — Flujo Spec-Driven Development (init → apply → verify)
- `tdd-strict` — TDD estricto (RED → GREEN → REFACTOR)

*(Ver `.opencode/HARNESS.md` para skills específicas del proyecto)*

---

## Prioridad MCP

Si `codebase-memory-mcp` está disponible:

**Usa primero:**
1. `search_graph(name_pattern="...")` — buscar funciones/clases
2. `trace_path(function_name="...", direction="inbound")` — quién llama a qué
3. `get_architecture()` — overview

**Fallback a grep/glob:** String literals, configs, archivos no-código

---

## Seguridad

- No leer `.env` bajo ninguna circunstancia
- No `git push` sin aprobación explícita (R79.2-CLAUDE)
- No ejecutar destructivos (`rm`, `del`, `Remove-Item`)

---

## Archivos relacionados

- `.opencode/HARNESS.md` — configuración de harness, test, lint, skills, stack
- `.opencode/claude-instructions-v4.md` — instrucciones simplificadas para Claude
- `doc/guias/ESTANDAR-COMANDOS.md` — formato de comandos
- `doc/arch/incidentes.md` — tracker de incidentes
- `.old/DEPRECADOS.md` — items obsoletos (historico)

---

version: v4.0.0 | updated: 2026-07-31
```

**Tamaño:** 120 líneas (vs 170 hoy)  
**Reducción:** -29% de contenido, mismo rigor  
**Cambios clave:**
- ✅ Sección "Deprecados" → referencia a `.old/DEPRECADOS.md`
- ✅ Emojis → solo en status bars, no en texto
- ✅ R14, R15, R18 → eliminadas (ya deprecadas)
- ✅ Comandos → top-20 (frecuencia de uso)
- ✅ Nuevo: "Prioridad MCP" (opcional)

---

## 3. HARNESS.md con sección Claude (Ajuste)

**Agregar esta sección en template `doc-base/HARNESS.md`:**

```markdown
---

## Claude v4 Configuration

Si usas Claude Desktop como agente de este proyecto, sigue estos pasos:

### Setup

1. **Ubicación de instrucciones:**
   ```
   .opencode/claude-instructions-v4.md (auto-created by /adaptar)
   ```

2. **Cargar en Claude Desktop:**
   - Abre Claude Desktop (app)
   - Settings → Custom Instructions
   - Copiar contenido de `.opencode/claude-instructions-v4.md`
   - Pegar en Custom Instructions
   - Guardar

3. **Validar (test message):**
   ```
   Send to Claude: "/estado"
   Expected: Reporte del proyecto (10-50 líneas)
   ```

### Token Budget (v4 optimized)

| Phase | Tokens | Example |
|-------|--------|---------|
| Bootstrap (instructions) | ~0.5K | Load claude-instructions-v4.md |
| PLAN phase | 8-12K | /plan task, understand dependencies |
| BUILD phase | 10-20K | Edit files, verify, report |
| VERSION phase | 5-8K | Update docs, bump, commit |
| **Total session** | **35-45K** | Typical workflow |

**Context window:** 200K tokens available  
**Safety margin:** Keep below 100K for safety

### Expected behavior

✅ **Respuesta en español** — siempre  
✅ **Pausa antes de git commit** — SIEMPRE pide confirmación (R79.2-CLAUDE)  
✅ **Respuestas concisas** — evitar verbosity  
✅ **Evidencia explícita** — "file:line" en cada claim  
✅ **No auto-versioning** — pide permiso para bump

### Troubleshooting

**Q: Claude ignores instructions and commits anyway**  
A: Check if you copied the full `claude-instructions-v4.md`. Paste again, save, test with "/estado".

**Q: Responses too long (verbose)**  
A: Enable R81 explicitly. Claude sometimes needs reminding; add to custom instructions: "Keep responses under 200 words when possible."

**Q: Project state out of sync after session**  
A: Run `/estado` to verify. If conflicted, run `/salud` for full diagnostic.

---

version: v4.0.0 | claude-ready
```

**Ubicación en template:** Agregar al final de `doc-base/HARNESS.md`  
**Tamaño:** ~120 líneas nuevas  
**Impacto:** Guía clara para nuevos usuarios

---

## 4. Resumen de cambios por archivo

| Archivo | Acción | Líneas antes | Líneas después | Δ |
|---------|--------|-------------|---|---|
| `.opencode/claude-instructions-v4.md` | Crear | — | 85 | +85 |
| `AGENTS.md` | Refactorizar | 170 | 120 | -50 |
| `HARNESS.md` (template) | Agregar sección | 80 | 200 | +120 |
| `DILIGENCIA.md` (template) | Actualizar versión | — | — | (sin cambio de contenido, solo v3→v4) |
| `doc-base/.gitignore` | Verificar | — | — | (incluye .claude-config.json) |

---

## 5. Flujo de carga en Claude Desktop

```
Session start:
┌─────────────────────────────────────┐
│ 1. User opens project in Claude     │
│    (via /project or custom prompt)  │
└──────────────┬──────────────────────┘
               │
┌──────────────v──────────────────────┐
│ 2. Claude loads context:             │
│    a) .opencode/claude-instr...v4.md │
│    b) .opencode/HARNESS.md (sketch) │
│    c) Workspace files (if needed)   │
└──────────────┬──────────────────────┘
               │
┌──────────────v──────────────────────┐
│ 3. Agent ready                      │
│    Bootstrap cost: ~500-1K tokens   │
│    Slack for actual work: ~198K     │
└─────────────────────────────────────┘
```

**Comparación v3 vs v4:**

```
v3.11.0 bootstrap:
  Load AGENTS.md (170 lines)    : ~2-3K
  Load HARNESS.md               : ~1-2K
  Load implied docs             : ~3-5K
  ───────────────────────────────
  Total                         : ~8-10K tokens
  Slack for work                : ~150-160K

v4 bootstrap:
  Load claude-instructions-v4   : ~0.5-1K
  Load HARNESS.md (on demand)   : ~0-1K
  Load implied docs             : ~2-3K
  ───────────────────────────────
  Total                         : ~3-5K tokens
  Slack for work                : ~195-197K
  
GAIN: ~5K tokens freed per session (33% improvement)
```

---

## 6. Migration script preview (pseudo-code)

**Para ejecutar `/adaptar --upgrade-v4`:**

```bash
#!/bin/bash
# Pseudo-code: upgrade v3.11.0 → v4

if [ ! -f ".opencode/HARNESS.md" ]; then
  echo "No HARNESS.md found. Abort."
  exit 1
fi

# Detect v3.11.0
version=$(grep "^Diligencia" DILIGENCIA.md | head -1)
if [[ ! "$version" =~ "v3.11.0" ]]; then
  echo "Project is $version. Not v3.11.0. Skipping."
  exit 0
fi

# Create claude-instructions-v4.md from template
cp ~/.config/opencode/templates/doc-base/.opencode/claude-instructions-v4.md \
   .opencode/claude-instructions-v4.md

# Refactor AGENTS.md (remove Deprecados, trim rules)
# (Manual edit, or scripted template substitution)

# Update DILIGENCIA.md version marker
sed -i 's/v3.11.0/v4.0.0/' DILIGENCIA.md

# Update HARNESS.md with Claude section
# (Append template section)

echo "✅ Upgraded to v4. Review and /commit."
```

---

## Conclusión

Estos tres ejemplos concretos muestran:

1. **`claude-instructions-v4.md`** — Sistema prompt comprimido (65% menos tokens)
2. **`AGENTS.md` refactorizado** — Documentación limpia sin ruido
3. **`HARNESS.md` mejorado** — Guía Claude para nuevos usuarios

**Impacto total:** Bootstrap 8-10K tokens → 3-5K tokens. Same rigor, less friction.

---

version: 1.0 | 2026-07-31
