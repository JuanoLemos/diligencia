# Índice: Propuesta Diligencia v4 para Claude Desktop

**Tipo:** Guía de navegación  
**Fecha:** 2026-07-31  
**Lectura recomendada:** En orden (abajo)  

---

## Documentos de esta propuesta

Esta propuesta se compone de 4 documentos en `doc/arch/`:

### 1. **EXEC-SUMMARY-v4.md** (10 min lectura)

**Para:** Orquestador (decisor final)  
**Contenido:**
- Problema (por qué v4)
- Solución (qué cambia)
- 8 recomendaciones concretas
- ROI estimado
- Decisiones requeridas del usuario
- Métricas de éxito

**Empezar aquí si:** Necesitas entender la propuesta rápido

**Pregunta clave:** "¿Aprobamos v4 o mantenemos v3.11.0?"

---

### 2. **PROPUESTA-DIL-v4.md** (30 min lectura)

**Para:** Arquitectos + implementadores  
**Contenido:**
- Resumen ejecutivo
- 12 propuestas detalladas (1-12):
  1. System prompt compresión
  2. Bootstrap agresivo-minimal
  3. Nuevo comando `/adaptar-v4` (o mejora)
  4. Reglas nuevas/ajustadas (R79.2, R81)
  5. Templates mejorados
  6. Métricas de éxito
  7. Incompatibilidades a resolver
  8. Backward compatibility
  9-12. Decisiones de arquitectura + plan de migración
- Checklist de implementación
- Referencias y casos de uso

**Empezar aquí si:** Necesitas entender el diseño técnico

**Pregunta clave:** "¿Cómo implementamos cada cambio?"

---

### 3. **EJEMPLOS-v4.md** (20 min lectura)

**Para:** Implementadores  
**Contenido:**
- Prototipo `.opencode/claude-instructions-v4.md` (85 líneas, código real)
- AGENTS.md refactorizado (120 líneas, código real)
- HARNESS.md con sección Claude (120 líneas nuevas, código real)
- Resumen de cambios por archivo (tabla)
- Flujo de carga en Claude Desktop (diagrama)
- Migration script preview (pseudo-código)

**Empezar aquí si:** Necesitas ver el código exacto que se va a escribir

**Pregunta clave:** "¿Qué aspecto tiene exactamente v4?"

---

### 4. **v4-INDICE.md** (este archivo, 5 min lectura)

**Para:** Todos  
**Contenido:**
- Guía de navegación
- Resumen por documento
- Flujo de lectura recomendado
- Preguntas clave
- Cómo proceder

---

## Flujos de lectura recomendados

### 🚀 Flujo RÁPIDO (Orquestador, 15 min)

1. Leer esta guía (v4-INDICE.md) — 5 min
2. Leer EXEC-SUMMARY-v4.md — 10 min
3. **Decidir:** ¿Aprobamos v4? (Sí/No/Cambios)

**Output esperado:** Decisión de proceder (o feedback para ajustar)

---

### 📐 Flujo DISEÑO (Arquitecto, 45 min)

1. Leer EXEC-SUMMARY-v4.md — 10 min
2. Leer PROPUESTA-DIL-v4.md (secciones 1-8) — 25 min
3. Leer EJEMPLOS-v4.md (código real) — 10 min
4. **Validar:** Diseño técnico OK?

**Output esperado:** Aprobación técnica + feedback de implementación

---

### 💻 Flujo IMPLEMENTACIÓN (Developer, 60 min)

1. Leer EXEC-SUMMARY-v4.md — 10 min
2. Leer PROPUESTA-DIL-v4.md (secciones 1-5, 9-10) — 20 min
3. Leer EJEMPLOS-v4.md completo — 20 min
4. **Preparar:** Tareas concretas de codificación

**Output esperado:** Tareas estimadas + timeline + dependencias

---

### 📚 Flujo COMPLETO (Auditor/Revisor, 90 min)

1. Leer v4-INDICE.md (esta guía) — 5 min
2. Leer EXEC-SUMMARY-v4.md — 10 min
3. Leer PROPUESTA-DIL-v4.md completo — 30 min
4. Leer EJEMPLOS-v4.md completo — 20 min
5. **Revisar:** Todos los aspectos (completitud, consistencia, riesgos)

**Output esperado:** Reporte de auditoría + recomendaciones finales

---

## Mapa conceptual (relaciones entre documentos)

```
┌─────────────────────────────────────────────────────────┐
│ Problema: v3.11.0 ineficiente para Claude Desktop     │
│ (8-15K tokens overhead, bootstrap costoso)             │
└────────────┬────────────────────────────────────────────┘
             │
             v
┌─────────────────────────────────────────────────────────┐
│ EXEC-SUMMARY-v4.md                                     │
│ "¿Qué es v4? ROI? ¿Aprobamos?" (10 min, decisión)     │
└────────────┬────────────────────────────────────────────┘
             │
             ├──> SÍ, aprobamos v4
             │
             v
┌─────────────────────────────────────────────────────────┐
│ PROPUESTA-DIL-v4.md                                    │
│ "¿Cómo hacemos v4?" (30 min, diseño técnico)           │
└────────────┬────────────────────────────────────────────┘
             │
             ├──> 12 propuestas detalladas
             ├──> Decisiones de arquitectura
             ├──> Plan de migración
             │
             v
┌─────────────────────────────────────────────────────────┐
│ EJEMPLOS-v4.md                                         │
│ "¿Qué código escribimos?" (20 min, implementación)     │
└────────────┬────────────────────────────────────────────┘
             │
             ├──> claude-instructions-v4.md (prototipo)
             ├──> AGENTS.md refactorizado (prototipo)
             ├──> HARNESS.md mejorado (prototipo)
             ├──> Migration script
             │
             v
        Fases 2-4:
        Validación → Implementación → Lanzamiento
        (8-10 días)
```

---

## Preguntas frecuentes (FAQ)

### P: ¿Cuál documento leo primero?

**R:** Depende de tu rol:
- **Orquestador:** EXEC-SUMMARY (decisión rápida)
- **Arquitecto:** PROPUESTA (diseño completo)
- **Developer:** EJEMPLOS (código)
- **Revisor:** Todo en orden (validación completa)

---

### P: ¿Cuánto tarda implementar v4?

**R:** 8-10 días (1.5 semanas):
- Fase 1 (validación): 2 días
- Fase 2 (prototipo): 3 días
- Fase 3 (implementación): 5 días
- Fase 4 (lanzamiento): 1 día
- Fase 5 (adopción): ongoing

*Ver sección "Timeline" en EXEC-SUMMARY o PROPUESTA*

---

### P: ¿Se rompe v3.11.0 con v4?

**R:** **NO.** Backward compatible 100%. 
- Proyectos v3.11.0 siguen funcionando sin cambios
- Upgrade a v4 es opt-in vía `/adaptar --upgrade-v4`
- No hay breaking changes forzados

*Ver sección "Backward compatibility" en EXEC-SUMMARY*

---

### P: ¿Cuál es el ROI real?

**R:** ~20-30% menos tokens por sesión + 45% más rápido adaptar.

Ejemplo:
- **Hoy (v3.11.0):** 45-60K tokens/sesión, 35 min adaptar
- **Con v4:** 35-45K tokens/sesión, 15-20 min adaptar
- **Ahorro anual:** ~1.8M tokens + ~200 horas adaptación

*Ver "Resultado estimado" en EXEC-SUMMARY*

---

### P: ¿Qué cambios son obligatorios vs opcionales?

**R:** 

**Obligatorios (Fases 1-4, 8-10 días):**
1. claude-instructions-v4.md
2. Refactorizar AGENTS.md
3. Simplificar R79.2
4. Agregar R81
5. Mejorar /adaptar
6. Sección Claude en HARNESS.md

**Opcionales (v4.1, postergar):**
7. Lazy-load de reglas
8. Dashboard de métricas

*Ver sección "8 recomendaciones" en EXEC-SUMMARY*

---

### P: ¿Quién necesita aprobación para proceder?

**R:** El usuario (jlemo) en 3 decisiones:

1. ✅ ¿Aprobamos v4? (Sí/No)
2. ✅ ¿Implementamos 1-6 críticas? (Sí/No)
3. ✅ ¿Opt-in upgrade o forzar? (Recomendado: opt-in)

*Ver sección "Decisiones requeridas" en EXEC-SUMMARY*

---

## Cómo proceder

### Paso 1: LECTURA (Esta sesión)

- [ ] Leo EXEC-SUMMARY-v4.md (10 min)
- [ ] Leo guía de navegación (v4-INDICE, 5 min)
- [ ] Decido: ¿Aprobamos v4?

**Salida:** Decisión de usuario (Sí/No/Cambios)

---

### Paso 2: VALIDACIÓN (Si SÍ a Paso 1)

- [ ] Arquitecto + Developer leen PROPUESTA + EJEMPLOS (60 min)
- [ ] Revisor audita completitud (90 min)
- [ ] Equipo valida: diseño OK? Riesgos mitigados?

**Salida:** Aprobación técnica

---

### Paso 3: IMPLEMENTACIÓN (Si validación OK)

- [ ] Fase 2 (Prototipo): crear claude-instr-v4.md, testear tokens (3 días)
- [ ] Fase 3 (Build): refactorizar AGENTS.md, mejorar /adaptar, templates (5 días)
- [ ] Fase 4 (Release): bump v4.0.0, CHANGELOG, announcement (1 día)

**Salida:** Diligencia v4.0.0 listo

---

### Paso 4: ADOPCIÓN (Ongoing)

- [ ] Propagar a 6 proyectos (gradual, opt-in)
- [ ] Monitorear ICT + métricas (2 semanas)
- [ ] Feedback → v4.1 mejoras

**Salida:** v4 establecido en ecosistema

---

## Responsabilidades por rol

| Rol | Documento clave | Decisión | Entregable |
|-----|---|---|---|
| **Usuario (jlemo)** | EXEC-SUMMARY | ¿Aprobamos v4? | Aprobación/feedback |
| **Arquitecto** | PROPUESTA (1-8) | ¿Diseño OK? | Validación técnica |
| **Developer** | EJEMPLOS + PROPUESTA (9-10) | ¿Cómo codificamos? | Tareas de implementación |
| **Revisor** | Todo (completo) | ¿Completitud + riesgos? | Reporte de auditoría |
| **QA** | EXEC-SUMMARY + métricas | ¿ROI validado? | Reporte post-lanzamiento |

---

## Timeline recomendado

```
SEMANA 1:
  Lunes    (hoy)     : Leer propuesta, decidir ✅
  Martes-Miércoles   : Validación técnica
  Jueves             : Aprobación + kick-off Fase 2

SEMANA 2:
  Lunes-Martes       : Fase 2 (Prototipo)
  Miércoles          : Fase 3 comienza (Build)
  Jueves-Viernes     : Fase 3 continúa

SEMANA 3:
  Lunes-Martes       : Fase 3 finaliza
  Miércoles          : Fase 4 (Release)
  Jueves-Viernes     : Fase 5 (Adopción comienza)

SEMANAS 4-5:
  Monitoreo + feedback (adopción gradual)
```

---

## Checklist para proceder

- [ ] **Usuario:** Leí EXEC-SUMMARY (10 min)
- [ ] **Usuario:** Entiendo problema + solución
- [ ] **Usuario:** Aprobé v4 (Sí/No/Cambios)
- [ ] **Usuario:** Designé arquitecto + developer
- [ ] **Arquitecto:** Leí PROPUESTA (30 min)
- [ ] **Arquitecto:** Validé diseño técnico
- [ ] **Developer:** Leí EJEMPLOS (20 min)
- [ ] **Developer:** Estimé tareas + timeline
- [ ] **Equipo:** Alineados en Fases 1-4
- [ ] **Próximo paso:** Kick-off Fase 2

---

## Archivos relacionados en repo

```
doc/arch/
├── EXEC-SUMMARY-v4.md      ← Empieza aquí (orquestador)
├── PROPUESTA-DIL-v4.md     ← Diseño técnico (arquitecto)
├── EJEMPLOS-v4.md          ← Código real (developer)
├── v4-INDICE.md            ← Esta guía
├── incidentes.md           ← Historial (referencia)
└── bugs.md                 ← Bug tracker

dot-opencode/
├── HARNESS.md              ← Será mejorado en Fase 3

templates/doc-base/.opencode/
└── (será creado)           ← claude-instructions-v4.md template

DILIGENCIA.md               ← Será bumped a v4.0.0
AGENTS.md                   ← Será refactorizado (120L)
CHANGELOG.md                ← Será actualizado v4.0.0
```

---

## Contacto y escalada

**Si tienes preguntas sobre:**

- ✅ **Propuesta general:** Ver EXEC-SUMMARY o PROPUESTA
- ✅ **Código específico:** Ver EJEMPLOS
- ✅ **Timeline/Riesgos:** Ver PROPUESTA (secciones 9-10)
- ✅ **ROI/Métricas:** Ver EXEC-SUMMARY (sección métricas)
- ✅ **Backward compat:** Ver EXEC-SUMMARY o PROPUESTA (sección 8)

**Próximo paso:** Responde las 3 preguntas de decisión en EXEC-SUMMARY.

---

## Resumen ejecutivo (TL;DR)

| Aspecto | Detalle |
|---------|---------|
| **Problema** | v3.11.0 consume 8-15K tokens innecesarios para Claude |
| **Solución** | v4: Bootstrap mínimo, instrucciones comprimidas, reglas ajustadas |
| **ROI** | 20-30% menos tokens, 45% más rápido adaptar |
| **Riesgo** | Bajo (backward compatible) |
| **Tiempo** | 8-10 días de implementación |
| **Próximo paso** | Usuario aprueba v4 en EXEC-SUMMARY |

---

**Documento:** v4-INDICE.md  
**Versión:** 1.0  
**Fecha:** 2026-07-31  
**Próximo revisor:** Usuario (decisión)

---

## 🎯 ACCIÓN REQUERIDA

**Lee EXEC-SUMMARY-v4.md (10 min) y responde:**

1. ¿Aprobamos Diligencia v4?
2. ¿Implementamos 1-6 críticas?
3. ¿Cuándo empezamos (esta semana)?

**Respuesta a:** Este chat, sección de conclusión.
