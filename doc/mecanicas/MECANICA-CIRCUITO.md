# MECANICA-CIRCUITO — Integridad Lógica y UX v1.0.0

## Propósito

Revisar la integridad lógica del proyecto: handlers, navegación, rutas, estados, feedback. Detecta circuitos rotos que el código compilado no revela pero que rompen la experiencia del usuario.

## Agentes y skills

| Componente | Ubicación | Rol |
|---|---|---|
| `@circuito` | `~/.claude/agents/circuito.md` | Agente read-only que escanea 8 categorías |
| `diligencia-circuito` | `skills/diligencia-circuito/SKILL.md` | Skill cargable por comandos |

## Flujo

```
/circuito [area] → cargar skill → @circuito escanea → tabla de hallazgos

/doctor Fase 1g → cargar skill → @circuito escanea → tabla en Fase 2
                → Fase 3g → hallazgos registrados como bugs P2/P3 en $BUGS

/CBP completo    → /doctor Fase 1g → 3g → bugs automáticos en $BUGS
```

## Las 8 verificaciones

| # | Check | Patrón | Severidad |
|---|-------|--------|-----------|
| 1 | Handlers vacíos | `onClick={fnInexistente}`, `onSubmit` stub | P3 |
| 2 | Callejones sin salida | Modal sin cerrar, loading→null, página sin retorno | P3 |
| 3 | Rutas huérfanas | Endpoint sin fetch consumidor | P3 |
| 4 | Fetch sin endpoint | `fetch("/api/x")` sin ruta backend | P2 |
| 5 | Estados no manejados | Loading/error/empty sin UI | P3 |
| 6 | Navegación rota | Link a ruta inexistente | P2 |
| 7 | Consistencia UX | Misma acción, distinto comportamiento | P3 |
| 8 | Feedback faltante | POST/DELETE sin toast/confirm | P3 |

## Integración con /doctor

### Fase 1g — Diagnóstico
Agregar después de 1f (Backup preventivo):

```
### 1g — Circuito lógico
CARGAR skill("diligencia-circuito")
EJECUTAR los 8 checks sobre el proyecto
ENTREGAR tabla de hallazgos con archivo:línea y severidad
```

### Fase 3g — Corrección
Agregar después de 3f (Post-corrección):

```
### 3g — Circuito
Por cada hallazgo de 1g con archivo:línea:
- REGISTRAR bug en $BUGS (formato: B-NN, severidad según tabla)
- AGREGAR entrada en $CHECKLIST como item pendiente
```

## Relación con otros agentes

| Agente | Qué revisa | Cuándo |
|---|---|---|
| `@circuito` | Handlers, rutas, navegación, UX | `/circuito`, `/doctor` |
| `@consejero` | Decisiones de proyecto, trayectoria | `/plan`, `/next`, `/RM` |
| `@sdd-reviewer` | Código: corrección, seguridad, performance | Post-BUILD, pre-commit |
| `@sdd-verify` | Tests: RED→GREEN→REFACTOR | Post-implement |

## Archivos relacionados

| Archivo | Rol |
|---|---|
| `AGENTS.md` | Mapea archivos frontend/backend |
| `doc/arch/bugs.md` | Destino de hallazgos P2/P3 |
| `CHECKLIST.md` | Items pendientes de circuito |
| `MECANICA-CIRCUITO.md` | Este archivo |
