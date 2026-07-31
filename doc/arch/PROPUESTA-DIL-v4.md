# Propuesta: Diligencia v4 — Optimización para Claude Desktop

**Fecha:** 2026-07-31  
**Tipo:** Propuesta de diseño (Read-only, no aplica cambios)  
**Estado:** 🟡 En evaluación  
**Audiencia:** Orquestador + arquitectos de Diligencia  

---

## Resumen ejecutivo

Diligencia v3.11.0 está diseñada para VAIO (servidor remoto) + OpenChamber, pero desde la transición a **Claude Desktop** (2026-07-31), hay fricciones puntuales:

1. **Sistema prompt inflado** — 170 líneas de AGENTS.md en context cada sesión
2. **Bootstrap costoso** — Diligencia check, health checks, validaciones ocurren siempre, consumen ~8-10K tokens por sesión
3. **Reglas para otros modelos** — R79.2 era para MiniMax; Claude ya es safety-conscious
4. **Verbosity innecesaria** — Templates y emojis optimizados para UI visual no sirven en terminal
5. **Incompatibilidades menores** — Algunas reglas R-numbers ya no aplican (R14/R15/R18 fueron deprecadas pero siguen citadas)

**Objetivo de v4:** Reducir fricción, mantener rigor, adaptar a Claude sin comprometer la metodología.

**Métricas de éxito:**
- ✅ Menos tokens por sesión inicial (~20-30% reducción)
- ✅ Menos incidentes tipo ICT-DIL-20260731-03 (agente decide git sin mandato)
- ✅ Mejor adopción en nuevos proyectos (adaptación 30 min → 15 min)
- ✅ Compatible con v3.11.0 (breaking change explícito si es necesario)

---

## 1. System Prompt v4 — Compresión y reordenamiento

### Propuesta 1.1: Estructura de dos capas

**Hoy (v3.11.0):**
```
AGENTS.md = 170 líneas
  ├─ Identidad (3 líneas) — redundante, se dice al inicio del prompt
  ├─ Idioma (4 líneas) — redundante, "responde en español" ya está en opencode.jsonc
  ├─ Mapeo de rutas (38 líneas) — crítico, se usa para resolver $ROADMAP etc
  ├─ Comandos globales (36 líneas) — tabla de 32 comandos (crítica para búsqueda)
  ├─ Focus (3 líneas) — ruido
  ├─ Disciplina BUILD (8 líneas) — crítica, BUILD ≠ commit
  ├─ Deprecados (24 líneas) — histórico, bajo valor operacional
  ├─ Modelo Agentes (32 líneas) — reglas R1-R17, R79.2 (críticas)
  └─ MCP + Archivos (18 líneas) — opcionales, no todos los usuarios usan MCP
```

**Propuesta v4:** Split en dos archivos con roles claros

1. **`.opencode/claude-instructions-v4.md`** (140 líneas comprimidas)
   - **Inline en system prompt de la sesión** — cargado por Claude Desktop automáticamente
   - Contiene SOLO lo crítico:
     - Identidad + idioma (comprimido a 2 líneas)
     - Mapeo de rutas activas (descartar deprecadas)
     - Comandos top-12 + cómo usarlos
     - R1-R10, R79.2 (reglas de operación)
     - Anti-patrones principales (sin ejemplos largos)
   
2. **`AGENTS.md`** (refactorizado a 120 líneas)
   - Documentación de referencia (no en system prompt)
   - Mantiene completitud histórica
   - Gitignore: Diligencia no cargo este archivo per-session; solo `.opencode/claude-instructions-v4.md` entra en context

**Beneficio:** Menos ruido, menos tokens, mejor signal-to-noise.

---

### Propuesta 1.2: Palabras clave nuevo formato

**Hoy:** Bloques named `## Mapeo de rutas`, `| Variable | Ruta |` → búsqueda lenta
**v4:** Palabras clave explícitas:

```markdown
## RUTAS (Keywords: $ROADMAP $CHANGELOG $GUIAS $HARNESS $TESTING)

$ROADMAP       → ROADMAP.md
$CHANGELOG     → CHANGELOG.md
$HARNESS       → .opencode/HARNESS.md
...
```

**Beneficio:** Claude indexa better, búsqueda instantánea por token.

---

### Propuesta 1.3: Excepciones ajustadas

**Eliminar (en v4):**
- Sección "Deprecados" — referencia solo en `.old/DEPRECADOS.md` dentro del repo
- Emojis en sistema prompt — usar solo en docs visuales (UI, markdown)
- R14, R15, R18 — ya deprecadas en v3.10.3, no repetir
- `$CHAMBER`, `$STACK` — definir SOLO si el proyecto lo usa, no por defecto

**Agregar (en v4):**
- `TOKEN_BUDGET` explícito por fase (bootstrap ~5K, plan ~10K, build ~15K, etc.)
- `CLAUDE_VERSION_MIN = claude-haiku-4.5` (si Haiku es el target)
- Excepción explícita: "Si el usuario pide commit/push/bump, SIEMPRE pausa; no es EXCEPTO a menos que diga 'adelante sin preguntar'"

---

## 2. Bootstrap mejorado — De "lazy" a "aggressive-minimal"

### Propuesta 2.1: Eliminación de checks innecesarios

**Hoy (v3.11.0):**
```
1. Lee .opencode/HARNESS.md (si existe)
2. Valida sintaxis YAML/JSON (si es config)
3. Escanea ROADMAP.md staleness
4. Ejecuta diligencia-check si proyectos adaptados
5. Reporta salud si R03 o R04 lo piden
```

→ **Costo:** 8-10K tokens para "hello"

**v4 propuesto:**
```
1. Solo si el usuario pide:
   - /estado → full health check
   - /salud → bootstrap + full check
   - /plan → bootstrap solo proyecto actual
2. Por defecto: charla limpia, sin checks automáticos
3. Error detección solo si el usuario lo pide explícitamente (/health)
```

**Beneficio:** Reducir ~70% tokens de bootstrap, conversación más fluida.

**Trade-off:** Usuario debe ser más proactivo en `/estado`. Mitigar: incluir hint en respuesta de bienvenida.

---

### Propuesta 2.2: Lazy-loading de reglas

**v4:** Cargar reglas dinámicamente por contexto

```
Si usuario pide:
  - /plan, /rm, /next → load Reglas de planificación (R6, R79.2)
  - /adaptar → load Reglas de adaptación (R1, R2, R10)
  - /commit, /CBP → load Reglas de git (R79.2 **only**)
  - Exploración código → load R17 (no pedir acciones)
```

No cargar todas las R-numbers de una. Ahorrar ~2-3K tokens.

---

## 3. Nuevo comando `/adaptar-v4`

### Propuesta 3.1: ¿Comando nuevo o mejora a `/adaptar`?

**Opción A (recomendada):** Mejorar `/adaptar` existente (one version forward)
- No bifurcar comandos
- `/adaptar` detecta versión del agente (Claude vs. otro) y adapta automáticamente
- v3.11.0 projects siguen funcionando con v4 agente (compatibilidad)
- Solo pedir `/adaptar --upgrade-v4` si quieren beneficiarse de compresión

**Opción B (compleja):** Crear `/adaptar-v4`
- Riesgo: usuarios confundidos, dos paths de adaptación
- Ventaja: v3 y v4 coexisten sin conflictos
- No recomendado a menos que v4 sea breaking change

**Propuesta final:** OPCION A. Mejorar `/adaptar` para:
1. Detectar `AGENTS.md` existente; si es v3.11.0, ofrecer upgrade interactivo
2. Crear `.opencode/claude-instructions-v4.md` si no existe
3. Mantener AGENTS.md para documentación (no cargar en context)

---

## 4. Reglas nuevas o ajustadas

### Propuesta 4.1: Simplificación de R79.2 para Claude

**Hoy (v3.10.3, para MiniMax):**
```
R79.2: Decisión humana sobre git: 
  el agente SIEMPRE debe esperar autorización explícita 
  antes de git commit, git push, git tag o bumpear versión...
  [Excepciones largas y complejas]
```

**v4 (para Claude, más simple):**
```
R79.2-CLAUDE: 
  Antes de cualquier git commit/push/tag/bump, PAUSA.
  Patrón: "¿Procedo con git commit? (sí/no/cambiar)" + espera respuesta.
  
  EXCEPCIONES:
  - Usuario dice "dale con todo" o "haz fix completo" (mandato explícito)
  - Archivo R-excepción en .opencode/ lo autoriza
  - Tarea read-only pura (no toca archivos)
```

**Beneficio:** Más conciso, Claude entiende mejor.

---

### Propuesta 4.2: Eliminar/Ajustar reglas que ya no aplican

**Eliminar de v4:**
- R14, R15, R18 — ya deprecadas, solo referencia histórica en `.old/`
- Sección de "Emojis" en sistema prompt — mantener en docs, no en instrucciones core

**Ajustar:**
- R13 (git pull) → Simplificar a: "Tras git pull, verificar 0 conflictos; si hay conflicto, pausa"
- R16 (evidencia) → Ya está en OpenCode core; mencionar apenas

---

### Propuesta 4.3: Nueva regla para control de verbosity

**R81 (nueva para v4):**
```
TOKEN_AWARENESS:
  Los prompts de Claude son prolix. Mantener respuestas concisas:
  
  ✓ Bueno: "Edité archivo:línea. Cambio: X→Y. Próximo paso: ?"
  ✗ Malo: "Procedí a realizar una exhaustiva lectura del archivo en cuestión, 
            para lo cual consulté 50 líneas del mismo, analizando cada párrafo..."
  
  Flag: Si la respuesta supera 300 palabras sin ser necesario, 
        preguntarse: "¿puedo ser más directo?"
```

**Beneficio:** Disciplina de output. Combate verbosity de Claude.

---

## 5. Templates mejorados — Cambios a `doc-base/`

### Propuesta 5.1: Ajustes a `AGENTS.md` template

**Cambios en template `doc-base/AGENTS.md`:**

1. **Sección "Idioma" → opcional** (si el proyecto usa español; si es English, dropear)
2. **Emojis → solo en "Estado de items"** (no en encabezados)
3. **Mapeo de rutas → referencias activas solo** (descartar `$CHAMBER`, `$STACK` si no aplican)
4. **Comandos → top-20, no 32** (priorizar por frecuencia de uso)
5. **Nuevo campo: "Modelo de agente"** — documentar si es Claude, DeepSeek, etc.

**Impacto:** Template de 100 líneas (hoy 170).

---

### Propuesta 5.2: Nuevo archivo `.opencode/claude-instructions-v4.md`

**Crear en templates:**
```
doc-base/.opencode/claude-instructions-v4.md (70-90 líneas)

Contenido:
- 2 líneas: Identidad + idioma
- 8 líneas: Rutas críticas ($ROADMAP, $HARNESS, etc.)
- 12 líneas: Top-12 comandos con invocación
- 20 líneas: Reglas operacionales (R1-R10, R79.2-CLAUDE, R81)
- 15 líneas: Anti-patrones principales
- 10 líneas: MCP (si aplica)
```

**Cómo entra en Claude Desktop:**
- OpenCode carga automáticamente archivos en `.opencode/` → context
- O usuario lo pega manualmente en "Custom instructions" de Claude

---

### Propuesta 5.3: Nueva sección en HARNESS.md

**Agregar sección "Claude v4 Config":**

```markdown
## Claude v4 Configuration

Si usas Claude Desktop como agente de este proyecto:

### Custom Instructions
- Archivo base: `.opencode/claude-instructions-v4.md`
- Copiar contenido a "Custom Instructions" en Claude
- Reemplazar $PROYECTO_NAME con nombre actual

### Tokens
- Bootstrap esperado: ~3-5K tokens
- Plan típico: ~8-12K tokens
- Build típico: ~10-20K tokens (según complejidad)

### Qué esperar
- Respuestas en español
- Pausas antes de git commit
- Compresión de output (sin sacrificar claridad)
```

**Beneficio:** Guía clara para nuevos usuarios de v4.

---

## 6. Métricas de éxito — Validación de v4

### Propuesta 6.1: Dashboard de mejora

| Métrica | v3.11.0 | v4 esperado | Validación |
|---------|---------|------------|-----------|
| Tokens bootstrap | 8-10K | 3-5K | Medir 5 sesiones iniciales |
| Tokens total/sesión | 45-60K | 35-45K | Comparar sesiones similares |
| Incidentes git | 3/mes (r79.2) | 1/mes | Contador en ICT tracker |
| Tiempo adaptación | 35 min | 15-20 min | Cronometrar `/adaptar` |
| Claridad de instrucciones | Subjetivo | Scoring | Feedback usuario |

---

### Propuesta 6.2: Incidentes monitoreados

Crear métrica explícita:

```
ICT-DIL-v4-MONITOR: Seguimiento post-lanzamiento
  
Alertas:
- Si ICT tipo "agente decide commit sin mandato" → P1, revisar R79.2-CLAUDE
- Si ICT tipo "verbose innecesario" → P2, revisar R81
- Si tiempo adaptación > 25 min → P2, revisar /adaptar
```

---

## 7. Incompatibilidades a resolver

### Propuesta 7.1: Emojis en Markdown

**Hoy:** ✅ 🔴 🟡 🟢 📋 — Funciona en GitHub, Markdown viewers
**v4:** Mismo soporte; agregar nota en HARNESS.md para usuarios que prefieren sin emojis

**Recomendación:** Mantener emojis, son útiles. NO es incompatibilidad.

---

### Propuesta 7.2: Markdown complejos

**Hoy:** Tables, nested lists, frontmatter YAML
**v4:** Mismo soporte. Claude maneja bien tablas.

**Sin incompatibilidades detectadas.**

---

### Propuesta 7.3: Sintaxis de comandos

**Hoy:** `/comando --flag --key=value`
**v4:** Mantener igual, Claude entiende perfectamente.

**Sin incompatibilidades.**

---

### Propuesta 7.4: Metadata JSON

**Hoy:** `.codebase-memory.json`, `opencode.jsonc`, `model-policy.json`
**v4:** Mismo soporte, sin incompatibilidades.

**Recomendación:** Agregar `.claude-config.json` opcional (equivalente a model-policy.json para Claude):

```json
{
  "model": "claude-haiku-4.5",
  "temperature": 0.5,
  "max_tokens": 4096,
  "system_prompt_file": ".opencode/claude-instructions-v4.md",
  "context_window": "200k"
}
```

---

## 8. Compatibilidad hacia atrás — Breaking changes explícitos

### Propuesta 8.1: ¿v4 es compatible con v3.11.0 projects?

**Respuesta: SÍ, con adaptación gradual**

| Escenario | v3.11.0 Project | v4 Agent | Resultado |
|-----------|---|---|---|
| Usuario abre proyecto v3.11.0 con agente v4 | AGENTS.md v3.11.0 existe | Agente carga ambos, prioriza v4 instructions | ✅ Compatible |
| Usuario quiere beneficiarse de v4 compresión | Lee AGENTS.md v3.11.0 | Ejecuta `/adaptar --upgrade-v4` | ✅ Upgrade transparente |
| Usuario prefiere mantener v3.11.0 | AGENTS.md v3.11.0 sin upgrade | Agente respeta; no fuerza v4 | ✅ Compatible |

**Regla: No hay breaking change forzado. v4 es opt-in para proyectos existentes.**

---

### Propuesta 8.2: Timeline de deprecación

```
v4.0 (NOW):  
  - Lanza v4 framework, instructiones mejoradas
  - v3.11.0 proyectos siguen funcionando 100%
  - Ofrecer upgrade interactivo vía `/adaptar --upgrade-v4`

v4.1 (Q2 2027):
  - Marcar v3.11.0 como "stable-legacy"
  - Documentar path de migración
  - Notas de "¿considerar upgrading?" en logs

v5.0 (Q4 2027):
  - v3.11.0 marcado como EOL (end-of-life)
  - Pero aún funciona si no se toca
```

---

## 9. Cambios a regulaciones/workflow

### Propuesta 9.1: BUILD para Diligencia

**Hoy:** BUILD = aplicar cambios, no commitear
**v4:** Mantener igual, es buena práctica.

**Ajustar solo la terminología:**
```
BUILD = cambios aplicados, contexto actualizado, listos para /CBP
Reportar: "Cambios: [X ediciones]. Próximo: ¿/CBP commit o /CBP version?"
```

---

### Propuesta 9.2: Disciplina de delegación

**Hoy:** Trigger a `@explore` si leer 4+ archivos
**v4:** Ajustar a 5-6 archivos (porque Claude tiene más contexto)

```
Delegación v4:
- Leer 5+ archivos NO triviales → considerar @explore
- Tocar 3+ archivos código → usar @sdd-implement
- Sesión > 25 tool calls → pausar, considerar delegación
```

---

## 10. Plan de migración

### Fase 1: Validación (Esta semana)

1. ✅ Propuesta leída y aprobada (estás aquí)
2. 📋 Crear `.opencode/claude-instructions-v4.md` prototipo
3. 📋 Testear con Diligencia mismo (proyecto v3.11.0)
4. 📋 Medir tokens: comparar v3.11.0 vs. v4

**Salida:** Prototipo functional, métricas iniciales

---

### Fase 2: Implementación (Next week)

1. 📋 Actualizar template `doc-base/` con v4 files
2. 📋 Refactorizar AGENTS.md (170 → 120 líneas)
3. 📋 Crear `.opencode/claude-instructions-v4.md` official
4. 📋 Actualizar `/adaptar` para soportar v4 (detect + adapt)
5. 📋 Bump Diligencia a v4.0 (CHANGELOG + DILIGENCIA.md)

**Salida:** v4.0 ready for launch

---

### Fase 3: Adopción (Ongoing)

1. 📋 Propagar a 6 proyectos adaptados (oferta, no forzar)
2. 📋 Documentar guía "Migrating to v4" en GUIAS
3. 📋 Monitorear ICT tracker por nuevos incidentes
4. 📋 Feedback loop: ajustar reglas según experiencia real

**Salida:** v4 establecido, adopción gradual

---

## 11. Decisiones de arquitectura

### 11.1: Compresión del system prompt

| Opción | Pros | Contras | Recomendación |
|--------|------|---------|---|
| **A) Eliminar AGENTS.md, solo claude-instructions-v4.md** | Mínimo contexto | Pierdo documentación + auditoría | ❌ No |
| **B) Mantener ambos, priorizar v4 en context** | Documentación + eficiencia | Poco más complicado | ✅ **RECOMENDADO** |
| **C) Gijar AGENTS.md solo en git, no en context** | Máximo contexto-lean | Confusión de usuarios | ⚠️ Parcial |

**Decisión: OPCION B** — Mantener AGENTS.md como referencia, cargar solo `claude-instructions-v4.md` en context.

---

### 11.2: Backward compatibility

| Opción | Pros | Contras | Recomendación |
|--------|------|---------|---|
| **A) Breaking change: v3 → v4 no compatible** | Limpio | Migración obligatoria | ❌ Disruptivo |
| **B) Compatible pero con warnings** | Gradual | Confusión inicial | ⚠️ Aceptable |
| **C) Full backward compatible (opt-in upgrade)** | Mejor UX | Mantenimiento doble | ✅ **RECOMENDADO** |

**Decisión: OPCION C** — Full backward compatible. Upgrade opt-in vía `/adaptar --upgrade-v4`.

---

### 11.3: Cuando cargar reglas R-numbers

| Opción | Pros | Contras | Recomendación |
|--------|------|---------|---|
| **A) Cargar todas las R-numbers siempre** | Completitud | 3-5K tokens extra | ❌ Ineficiente |
| **B) Cargar dinámicamente según comando** | Eficiente | Lógica compleja | ✅ **RECOMENDADO** |
| **C) Cargar solo en demanda (usuario pide)** | Mínimo | Menos proactivo | ⚠️ Alternativa |

**Decisión: OPCION B** — Lazy-load reglas por contexto (plan, commit, código, etc).

---

## 12. Recomendaciones finales

### ✅ HACER en v4:

1. **Crear `.opencode/claude-instructions-v4.md`** (70-90 líneas, crítico)
2. **Refactorizar AGENTS.md** → 120 líneas, eliminar ruido
3. **Ajustar R79.2** → simplificada para Claude
4. **Agregar R81** (TOKEN_AWARENESS) — disciplina de verbosity
5. **Mejorar `/adaptar`** → detectar v3 vs v4, ofrecer upgrade
6. **Actualizar templates** → agregar "Claude v4 Config" en HARNESS.md

### ⚠️ CONSIDERAR:

7. Lazy-load de reglas (complejo, bajo ROI si contexto es <100K tokens)
8. Dashboard de métricas v4 (útil para validación, pero overhead inicial)

### ❌ NO HACER:

9. Crear `/adaptar-v4` (bifurca comandos)
10. Breaking change a v3 (mantener compatibilidad)
11. Emojis → Mantener, son útiles
12. Reescribir AGENTS.md "from scratch" (mantener historia)

---

## 13. Impacto estimado

### Tokens por sesión

```
v3.11.0:
  Bootstrap (health checks)       : 8-10K
  Load AGENTS.md (170 líneas)     : 2-3K
  Load HARNESS.md                 : 1-2K
  Load other docs                 : 2-5K
  ──────────────────────────────────
  Total overhead                  : 13-20K (28-30% de sesión típica)

v4 optimizado:
  Bootstrap (minimal)              : 2-3K
  Load claude-instructions-v4.md   : 0.5-1K (70 líneas)
  Load HARNESS.md (solo si needed) : 1-2K (on-demand)
  Load other docs (on-demand)      : 2-5K
  ──────────────────────────────────
  Total overhead                   : 5.5-11K (12-20% de sesión típica)

Ahorro estimado                   : ~6-9K tokens/sesión (30-45%)
```

---

## Apéndices

### A. Checklist de implementación

- [ ] Validar propuesta (leer documento)
- [ ] Crear prototipo `claude-instructions-v4.md`
- [ ] Testear con Diligencia mismo (medir tokens)
- [ ] Refactorizar AGENTS.md template
- [ ] Mejorar `/adaptar` para v4
- [ ] Bump Diligencia → v4.0
- [ ] Documentar CHANGELOG v4.0
- [ ] Propagar a 6 proyectos (opcional)
- [ ] Monitorear ICT por 2 semanas

### B. Referencias

- `doc/arch/incidentes.md` → ICT-DIL-20260731-03 (origen de R79.2)
- `AGENTS.md` → Reglas R1-R81
- `CHANGELOG.md` → Historia de cambios
- `templates/doc-base/` → Archivos template a actualizar

### C. Casos de uso validados

**Caso 1: Nuevo proyecto adaptado a v4**
```
1. Usuario corre /adaptar (detecta v4)
2. Copia claude-instructions-v4.md a su .opencode/
3. Carga en Claude Desktop custom instructions
4. Sesión inicial = 5K tokens (vs 15K en v3.11.0)
5. ✅ Win: 66% menos tokens, mismo valor
```

**Caso 2: Proyecto v3.11.0 existente**
```
1. Usuario abre proyecto con agente v4
2. Agente detecta AGENTS.md v3.11.0
3. Pregunta: "¿Actualizar a v4? (/adaptar --upgrade-v4)"
4. Usuario elige: sí → ejecución automática
5. ✅ Win: opt-in, sin breaking changes
```

---

## Conclusión

Diligencia v4 es una **evolución, no una revolución**. Mantiene rigor metodológico (reglas, disciplina, auditoría) mientras reduce fricción operacional para Claude Desktop.

**Impacto:** 30-45% menos tokens, mejor UX, mismo control. **Costo:** ~2-3 días de implementación.

**Recomendación:** Proceder con Fase 1 (validación) esta semana.

---

**Fecha de creación:** 2026-07-31  
**Versión:** 1.0  
**Próximo revisor:** @sdd-architect (validación de propuesta)
