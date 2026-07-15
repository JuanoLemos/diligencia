# MANDATO — Diligencia v1.17.2

Diligencia es una metodología de estructura documental para proyectos OpenCode.
Un solo archivo define lo que todo proyecto hereda.

---

## Los 6 mandatos

Lo mínimo que Diligencia garantiza en cada proyecto adaptado vía `/adaptar`.
Inmutable — no se negocia, no se desactiva.

| M# | Mandato | Verificado por |
|----|---------|---------------|
| M1 | AGENTS.md es el SSOT del proyecto (variables, comandos, contexto) | `/adaptar` Flujo A |
| M2 | Estructura documental fija: `doc/guias/`, `doc/mecanicas/`, `doc/arch/`, INDEX.md, ROADMAP.md, CHANGELOG.md, ROADMAP.md, DILIGENCIA.md | `/diligencia-check` |
| M3 | Solo `/commit`, `/CBP` y `/version` pueden ejecutar git commit | Regla #17 |
| M4 | Todo workflow sigue PLAN (razonamiento, solo lectura) → BUILD (ejecución, escritura) | `/CBP` |
| M5 | Pre-flight de versión — `/CBP` verifica si el proyecto tiene una versión de Diligencia atrasada y ofrece `/adaptar` antes de cualquier otra acción | `/CBP` Paso 0d |
| M6 | **Chamber pertenece a Diligencia.** Todo código, UI, tray, skills y configuración en openchamber son dominio de Diligencia. Las modificaciones en Chamber se rigen por las mismas reglas que Diligencia: PLAN→BUILD, /commit, /CBP. | `AGENTS.md` §Identidad |

---

## Lo que NO es Diligencia

| No es Diligencia | Decisión de cada proyecto |
|---|---|
| Stack tecnológico | Node, Python, Go... |
| Modelo de IA | DeepSeek, OpenAI, Anthropic... |
| Código fuente | src/, test/, config/ |
| Negocio del proyecto | Reglas de juego, monetización, features |
| CI/CD pipeline | GitHub Actions, scripts de deploy |
| Testing framework | Jest, pytest, Mocha... |

---

## Cómo evoluciona

```
Diligencia repo → mejora → bump de versión → /adaptar propaga → /CBP pre-flight avisa si hay staleness
```

No hay otro canal. Los proyectos nunca están obligados a actualizar, pero `/CBP` les recuerda que hay novedades.

## Archivos relacionados
- `doc/guias/identidad.md` — identidad del proyecto
- `doc/arch/ADR_SUMMARY.md` — resumen de ADRs
