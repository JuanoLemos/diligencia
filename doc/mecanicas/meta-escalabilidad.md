# META-ESCALABILIDAD — Detección automática de camino en /CBP v1.16.3

Mecánica de adaptación escalativa del orquestador /CBP: detecta automáticamente el camino óptimo (commit/parcial/full) según el working tree del proyecto.

---

## Árbol de decisión

| Señal de entrada | Camino | Qué ejecuta |
|---|---|---|
| Solo código fuente modificado, 0 docs tocados | **commit** | `git add -A` + commit + push. Sin doc sync ni versión ni Meta-PLAN. |
| 1-5 docs tocados, sin nuevas guías/mecánicas | **parcial** | `/updoc` Fases A→F + `/version` patch + push. Sin Meta-PLAN profundo, sin agentes, sin /salud, sin /doctor. |
| 5+ docs tocados, nuevas guías/mecánicas, milestones, o working tree sucio de múltiples sesiones | **full** | Meta-PLAN paralelo (4 workers) + BUILD + agentes/skills. |

## Algoritmo de detección

```
1. git status --porcelain → clasificar archivos:
   - Código: src/**, auth/**, tests/**, tools/**, config/**, *.js, *.ts, *.py, *.go
   - Doc: doc/**, design/**, *.md, INDEX.md, ROADMAP.md, CHECKLIST.md, AGENTS.md
2. Contar docs vs código
3. Determinar camino según árbol de decisión
4. Presentar sugerencia al usuario
5. Ejecutar workflow confirmado
```

## Invocación y despacho

| Invocación | Comportamiento |
|---|---|
| `/CBP` (sin argumento) | Ejecuta detección automática → árbol de decisión → pregunta al usuario |
| `/CBP commit` | Salta directo a `commit`. Sin detección. |
| `/CBP parcial` | Salta directo a `parcial`. Sin detección. |
| `/CBP full` | Salta directo a `full` con Meta-PLAN paralelo. Sin detección. |

## Forzado explícito

| Comando | Fuerza |
|---|---|
| `/CBP commit` | Camino commit directo, sin preguntar |
| `/CBP parcial` | Camino parcial directo |
| `/CBP full` | Camino full (equivale a `/CBP completo`) |

## Decisión por escenario

| Escenario | Camino recomendado |
|---|---|
| Sesión de código puro (bugs, features en src/) | `commit` |
| Código + toqué 1 doc de pasada | `commit` |
| Toqué varios docs, nada de código | `parcial` |
| Cierro milestone/fase (v0.3→v0.4) | `full` |
| Working tree sucio de 3+ sesiones acumuladas | `full` |
| Creé/eliminé guías o mecánicas nuevas | `parcial` o `full` |
| Quiero "ver cómo va el proyecto" | NO USAR /CBP — usar `/estado` o `/doctor` standalone |

## Archivos relacionados
- `CBP.md` — especificación completa del orquestador y dispatch
- `MECANICA-CBP.md` — circuito de trabajo cíclico
