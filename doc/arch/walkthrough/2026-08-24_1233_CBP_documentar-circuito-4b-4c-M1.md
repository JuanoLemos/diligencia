# Walkthrough — Documentar chequeos 4b/4c de circuito (mutación M1)

**Fecha:** 2026-08-24 12:33 · **Comando:** `/CBP` (vía `/mutacion`) · **Modelo:** claude-sonnet-5

---

## Qué se hizo

Nemesis reportó (mutación M1, tanda del 2026-08-23, reconfirmada con más urgencia el
2026-08-24 — 4ª instancia del patrón en producción) que `agents/circuito.md` tenía 2 chequeos
nuevos aplicados en código, registrados en `PENDING.md` desde el día del cambio, pero
**nunca versionados**. Se cerró la deuda: bump patch, entrada en CHANGELOG/DILIGENCIA, y
`PENDING.md` vaciado.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| `~/.claude/commands/adaptar.md` | v4.2.2 → v4.2.3; fila de migración documentando 4b/4c |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.2.3 |
| `~/.claude/commands/PENDING.md` | Vaciado — entrada consumida |
| `doc/arch/mutaciones-consolidadas.md` | M1: Pendiente → Aplicado (v4.2.3) |

`agents/circuito.md` en sí **no se tocó** — los chequeos 4b/4c ya estaban ahí desde el
2026-08-23. Esta sesión solo documenta y versiona lo que ya corría.

## Decisiones

| Decisión | Fundamento |
|---|---|
| No re-escribir `circuito.md` | El código del agente ya era correcto y estaba en uso — reescribirlo hoy sería tocar algo que funciona solo para cambiar la fecha del commit. El gap era de versionado, no de implementación |
| Documentar la causa del retraso en el CHANGELOG, no solo el qué | El mecanismo (`PENDING.md` + `/CBP` paso 0.f) funcionó como se diseñó — la entrada estaba ahí desde el día 1. El retraso fue no correr el paso 0.f en las corridas de `/CBP` intermedias de esta sesión (2026-08-23, fix de M2). Vale la pena que quede escrito: es una falla de ejecución mía, no del diseño de la mecánica |

## Evidencia (R16)

- `PENDING.md` tenía la entrada exacta desde el 2026-08-23, con la fecha original del cambio
- `agents/circuito.md:35` y `:46` — chequeos 4b y 4c presentes, confirmados antes de escribir esta entrada
- Nemesis reporta 4 instancias del patrón que 4c persigue en 2 días, la última: campo de estado leído por frontend inexistente en backend

## Pendientes

- [ ] M6, M7, M8 (validador `check-docs.js`) — pendientes, se abordan en sesión separada: requieren mostrar diff propuesto antes de tocar código (no son solo documentación, como M1)
- [ ] M3, M4, M5 de la tanda anterior — siguen sin tocar

## Commits

| Ref | Mensaje |
|---|---|
| `v4.2.3` | `docs(agentes): documentar chequeos 4b/4c de circuito — deuda de PENDING.md (M1)` |
