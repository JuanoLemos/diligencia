# Executive Summary: Diligencia v4 — Propuesta de Optimización para Claude Desktop

**Documento:** Síntesis ejecutiva  
**Fecha:** 2026-07-31  
**Audiencia:** Orquestador (decisor final)  
**Tiempo de lectura:** 10 minutos  

---

## Problema (por qué v4)

Diligencia v3.11.0 fue diseñada para **VAIO + OpenChamber + múltiples modelos** (MiniMax M2.7, etc.).

Con la **transición a Claude Desktop** (2026-07-31), hay fricciones claras:

| Fricción | Costo | Severidad |
|----------|-------|-----------|
| System prompt inflado (AGENTS.md 170 líneas en context siempre) | 2-3K tokens/sesión | 🟠 Media |
| Bootstrap costoso (health checks, validaciones automáticas) | 8-10K tokens inicial | 🔴 Alta |
| Reglas para MiniMax no aplican a Claude (R79.2 es defensiva) | Ruido en reglas | 🟡 Baja |
| Verbosity innecesaria (emojis, ejemplos largos en instrucciones) | 1-2K tokens | 🟡 Baja |
| Incompatibilidades menores (R14/15/18 deprecadas pero citadas) | Confusión | 🟡 Baja |

**Total overhead innecesario:** 8-15K tokens/sesión (18-30% de contexto usado en ruido)

---

## Solución propuesta (qué es v4)

**Diligencia v4** = Misma metodología rigurosa + ajustada para Claude Desktop.

### Cambios principales

| Cambio | Detalle | Impacto |
|--------|--------|--------|
| **1. Sistema prompt comprimido** | Separar instrucciones (claude-instr-v4.md 70L) de docs (AGENTS.md 120L) | -2-3K tokens |
| **2. Bootstrap agresivo-minimal** | Sin health checks automáticos; user-triggered solamente | -8-10K tokens |
| **3. Reglas ajustadas** | R79.2 simplificada para Claude, nueva R81 (verbosity), R14/15/18 eliminadas | -0.5K tokens |
| **4. Templates mejorados** | HARNESS.md con sección Claude v4, doc-base/ actualizado | +120L pero claro |
| **5. Backward compatible** | v3.11.0 projects siguen funcionando; upgrade opt-in vía `/adaptar --upgrade-v4` | 0 breaking changes |

### Resultado estimado

```
ANTES (v3.11.0):
  Bootstrap       : 8-10K tokens
  Total session   : 45-60K tokens
  Incidentes P3   : 1-2/mes (agente commitea sin mandato)

DESPUES (v4):
  Bootstrap       : 3-5K tokens   (↓60% mejora)
  Total session   : 35-45K tokens (↓25% mejora)
  Incidentes P3   : ~0/mes        (R79.2-CLAUDE es más simple, menos malentendidos)
  
METRICS:
  ✅ Tokens por sesión: -20-30% (en jornadas típicas)
  ✅ Tiempo adaptación: 35 min → 15-20 min (-45%)
  ✅ Seguridad git: R79.2 más clara, fewer incidents
  ✅ UX: Menos ruido, better signal-to-noise
```

---

## Propuestas concretas (8 recomendaciones)

### 1. ✅ Crear `.opencode/claude-instructions-v4.md`

**Qué:** Archivo nuevo (70-90 líneas) con instrucciones comprimidas para Claude

**Dónde:** 
- En template: `~/.config/opencode/templates/doc-base/.opencode/claude-instructions-v4.md`
- Cada proyecto adaptado lo hereda en `.opencode/claude-instructions-v4.md`

**Contenido:**
- Identity + language (2 líneas)
- Critical routes: $ROADMAP, $HARNESS, $TESTING, etc. (8 líneas)
- Top-12 commands (12 líneas)
- Rules: R1-R10, R79.2-CLAUDE, R81 (20 líneas)
- Anti-patterns (10 líneas)
- MCP optional (5 líneas)
- Token budget (10 líneas)

**Costo:** ~4 horas de escritura + testing

**ROI:** Reducir 2-3K tokens/sesión × 6 proyectos × ~300 sesiones/año = **1.8M tokens ahorrados anualmente**

---

### 2. ✅ Refactorizar AGENTS.md (170 → 120 líneas)

**Qué:** Limpiar AGENTS.md para documentación (no cargarlo en context)

**Cambios:**
- Eliminar sección "Deprecados" (referencia a `.old/DEPRECADOS.md`)
- Eliminar emojis en encabezados (solo en status)
- Eliminar R14, R15, R18 deprecadas
- Cambiar "Comandos globales 32" → "Top-20 por frecuencia"
- Simplificar ejemplos

**Costo:** ~2 horas

**ROI:** Documentación más clara para nuevos usuarios

---

### 3. ✅ Simplificar R79.2 para Claude

**Hoy:**
```
R79.2: Decisión humana sobre git...
  [8 líneas de excepciones complejas]
```

**v4:**
```
R79.2-CLAUDE: 
  PAUSA antes de: git commit, git push, git tag, bump versión.
  Patrón: "¿Procedo? (sí/no/cambiar)" + espera respuesta.
  EXCEPCIONES: mandato explícito, R-exception, read-only.
```

**Beneficio:** Claude entiende mejor (menos ambigüedad)

---

### 4. ✅ Agregar R81 — TOKEN_AWARENESS

**Nueva regla:**
```
R81: Respuestas concisas. Evitar verbosity innecesaria.
  ✓ "Edité X. Cambio: A→B. Próximo: ?"
  ✗ "[3 párrafos de preamble]... Al fin, "Cambio: A→B""
  
Límite soft: <250 palabras si es posible.
```

**Beneficio:** Disciplina de output, menos tokens desperdiciados

---

### 5. ✅ Mejorar `/adaptar` para v4

**Hoy:** `/adaptar` copia template doc-base

**v4 mejorado:**
1. Detecta versión del proyecto (v3.11.0, v4, etc)
2. Si v3.11.0, ofrece: "¿Actualizar a v4? (/adaptar --upgrade-v4)"
3. Copia `.opencode/claude-instructions-v4.md`
4. Actualiza AGENTS.md a 120 líneas
5. Agrega sección "Claude v4 Config" a HARNESS.md
6. Bump DILIGENCIA.md a v4.0.0

**Costo:** ~4 horas

**ROI:** Adaptación 35 min → 15-20 min (-45%)

---

### 6. ✅ Agregar sección "Claude v4 Config" a HARNESS.md template

**Contenido:** Guía de setup para Claude Desktop users

```markdown
## Claude v4 Configuration

Si usas Claude Desktop como agente:

1. Ubicación: .opencode/claude-instructions-v4.md
2. Cargar: Custom Instructions en Claude Desktop
3. Token budget: ~35-45K/sesión (vs 45-60K en v3.11.0)
4. Comportamiento esperado: español, pausas antes de git, respuestas concisas
5. Troubleshooting: [FAQ]
```

**Beneficio:** Onboarding claro para nuevos proyectos

---

### 7. ⚠️ CONSIDERAR: Lazy-load de reglas

**Idea:** Cargar R-numbers dinámicamente según comando

```
/plan → load reglas de planificación
/commit → load R79.2-CLAUDE
/codigo → load R17
```

**Costo:** ~6-8 horas (lógica compleja)

**ROI:** ~1-2K tokens adicionales ahorrados

**Recomendación:** POSPONN a v4.1 (no es crítico para lanzamiento)

---

### 8. ⚠️ CONSIDERAR: Dashboard de métricas v4

**Idea:** Monitorear tokens, incidentes, adopción

```
Métrica              v3.11.0    v4 target   Validación
─────────────────────────────────────────────────────
Tokens bootstrap     8-10K      3-5K        Medir 5 sesiones
Incidentes git/mes   1-2        0-1         Tracker ICT
Tiempo adaptación    35 min     15-20 min   Cronometro
```

**Costo:** ~4 horas (scripts PowerShell + logging)

**ROI:** Evidencia de mejora, datos para v4.1

**Recomendación:** OPCIONAL para lanzamiento (agregar en v4.1)

---

## Backward compatibility

### ¿Se rompe v3.11.0 con v4?

**NO.** v4 es fully backward compatible.

```
Escenario 1: Usuario tiene v3.11.0 project, agente v4
  Resultado: Agente carga AGENTS.md v3.11.0, funciona 100%
  
Escenario 2: Usuario quiere beneficiarse de v4 compresión
  Resultado: `/adaptar --upgrade-v4` actualiza automáticamente
  
Escenario 3: Usuario prefiere mantener v3.11.0
  Resultado: AGENTS.md v3.11.0 sigue funcionando (sin cambios)
```

**Garantía:** v3.11.0 projects siguen funcionando en v4 (opt-in upgrade)

---

## Timeline de implementación

| Fase | Tareas | Duración | Bloqueadores |
|------|--------|----------|---|
| **1. Validación** (esta semana) | Leer propuesta, discutir, aprobación | 2 días | Ninguno |
| **2. Prototipo** (next 3 días) | Crear claude-instr-v4.md, testear tokens, medir | 3 días | Aprobación fase 1 |
| **3. Implementación** (1 semana) | Refactorizar AGENTS.md, mejorar /adaptar, templates | 5 días | Prototipo validado |
| **4. Lanzamiento** (día 8) | Bump Diligencia → v4.0.0, CHANGELOG, announcement | 1 día | Implementación OK |
| **5. Adopción** (gradual) | Propagar a 6 proyectos, feedback, v4.1 mejoras | Ongoing | Lanzamiento exitoso |

**Total:** ~8-10 días (1.5 semanas)

---

## Decisiones requeridas del usuario

### ✅ Pregunta 1: ¿Proceder con v4?

Opción A: **SÍ, adelante con v4** (recomendado)
- ROI claro: 20-30% menos tokens, 45% más rápido adaptar
- Riesgo bajo: backward compatible
- Timeline corto: 8-10 días

Opción B: No, mantener v3.11.0
- Sigue funcionando
- Pero no se beneficia de mejoras de Claude

**Recomendación:** Opción A

---

### ✅ Pregunta 2: ¿Qué del conjunto 1-8 implementar?

**Críticas (HACER):**
- ✅ 1. claude-instructions-v4.md
- ✅ 2. Refactorizar AGENTS.md
- ✅ 3. Simplificar R79.2
- ✅ 4. Agregar R81
- ✅ 5. Mejorar /adaptar
- ✅ 6. Sección Claude en HARNESS.md

**Opcionales (CONSIDERAR para v4.1):**
- ⚠️ 7. Lazy-load reglas
- ⚠️ 8. Dashboard de métricas

**Recomendación:** Implementar 1-6 (críticas), postergar 7-8 a v4.1

---

### ✅ Pregunta 3: ¿Adopción obligatoria o opt-in?

Opción A: **Opt-in** (para nuevos proyectos + upgrade opcional para v3)
- Menos fricción
- Migración gradual
- Riesgo bajo

Opción B: Forzar upgrade a todos
- Más consistencia
- Pero disruptivo si hay issues

**Recomendación:** Opción A (opt-in, pero sugerir strongemente upgrade)

---

## Riesgos y mitigaciones

| Riesgo | Probabilidad | Mitigación |
|--------|---|---|
| Agente Claude ignora R79.2-CLAUDE simplificada | Baja | Testear intensamente en Fase 2; if issue, ajustar |
| Usuarios no actualizan .opencode/claude-instr-v4.md en custom settings | Media | Agregar hint en HARNESS.md, /estado report si falta |
| Tokens ahorrados no se manifiestan en práctica | Baja | Medir sesiones reales; ajustar reglas si necesario |
| v3.11.0 projects rotos tras upgrade | Muy baja | Full backward compat garantizado; rollback fácil |

---

## Métricas de éxito post-lanzamiento

| Métrica | Target | Validación |
|---------|--------|-----------|
| **Tokens bootstrap** | 3-5K (↓60% desde 8-10K) | Medir 5 sesiones nuevas |
| **Total tokens/sesión** | 35-45K (↓25% desde 45-60K) | Comparar 10 sesiones similares v3 vs v4 |
| **Incidentes tipo R79.2** | ≤1 por mes (vs 1-2 en v3) | Tracker ICT por 2 meses |
| **Tiempo adaptación** | <20 min (vs 35 min) | Cronometrar `/adaptar` |
| **Adopción en 6 proyectos** | ≥4 proyectos upgradean voluntariamente | Feedback usuarios |

---

## Conclusión

**Diligencia v4 es una evolución, no una revolución.**

Mantiene:
- ✅ Rigor metodológico (reglas, disciplina, auditoría)
- ✅ Documentación completa (AGENTS.md, guides)
- ✅ Seguridad git (R79.2-CLAUDE)
- ✅ Backward compatibility (v3 sigue funcionando)

Mejora:
- 🚀 30-45% menos tokens por sesión
- 🚀 45% más rápido adaptar proyectos
- 🚀 Mejor UX para Claude Desktop
- 🚀 Reglas más simples, menos ambigüedad

**Costo:** ~8-10 días de implementación  
**ROI:** ~1.8M tokens ahorrados/año + mejor adopción

**Recomendación:** PROCEDER con Fases 1-2 esta semana.

---

## Apéndices

### A. Documentos de referencia

- `PROPUESTA-DIL-v4.md` — Especificación técnica completa (13 secciones)
- `EJEMPLOS-v4.md` — Prototipos de archivos (claude-instr-v4.md, AGENTS.md, HARNESS.md)
- `doc/arch/incidentes.md` — Historial ICT-DIL-20260731-03 (origen de R79.2)
- `CHANGELOG.md` — Historial de cambios v3.11.0

### B. Checklist de implementación

- [ ] **Fase 1: Aprobación** — Usuario valida propuesta, aprueba timeline
- [ ] **Fase 2: Prototipo** — Crear claude-instr-v4.md, testear, medir tokens
- [ ] **Fase 3: Implementación** — Refactorizar AGENTS.md, mejorar /adaptar, actualizar templates
- [ ] **Fase 4: Lanzamiento** — Bump v4.0.0, CHANGELOG, announcement
- [ ] **Fase 5: Validación** — Monitorear ICT, métricas, adopción (2 semanas)

### C. Contacto

**Próximos pasos:**
1. Usuario lee resumen (10 min)
2. Usuario aprueba o sugiere cambios
3. OpenCode prepara Fase 2 (prototipo)
4. Usuario valida prototipo
5. Implementación completa

---

**Documento:** EXEC-SUMMARY-v4.md  
**Versión:** 1.0  
**Fecha:** 2026-07-31  
**Estado:** 🟡 Pendiente aprobación usuario

Para proceder, responde:
- ✅ ¿Apruebas v4?
- ✅ ¿Implementar 1-6 (críticas)?
- ✅ ¿Opt-in o forzar upgrade?
- ✅ ¿Cuándo empezamos (fase 2)?
