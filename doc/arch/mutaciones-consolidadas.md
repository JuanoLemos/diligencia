# Mutaciones consolidadas — Diligencia v1.0.0

Observaciones recibidas de proyectos adaptados, registradas vía `/mutacion`.
Cada entrada representa una desviación del estándar que podría sugerir una evolución de Diligencia.

---

## 2026-08-23 — Némesis Detective

**Versión Diligencia heredada:** v4.2.1 · **Origen:** sesión de trabajo real (no auditoría teórica)

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M1 | ✅ `circuito`: 2 puntos ciegos — permiso incompatible con el llamador (4b) y promesas del prompt sin respaldo en la UI (4c). Aplicado en código desde 2026-08-23, documentado y versionado en Diligencia v4.2.3 (2026-08-24) — 1 día de deuda de gobernanza vía `PENDING.md`. | Agente global | `agents/circuito.md` | **Aplicado (v4.2.3)** |
| M2 | ✅ **Bootstrap del lock producía falsos positivos destructivos.** Confirmado y corregido en Diligencia v4.2.2 (2026-08-23) — se adoptó el fix propuesto por Nemesis: schema de lock con `sha256` + `template_sha256` + `origen` (comparación de 3 → 4 vías). Ver `MECANICA-LOCK.md` v1.1.0 §4. | Mecánica | `MECANICA-LOCK.md`, `adaptar.md` Fase 2.5 | **Aplicado (v4.2.2)** |
| M3 | ✅ `PENDING.md` se leía pero nunca existió — y al crearlo se vio el gap más profundo: **nadie lo escribe automáticamente**, así que el mecanismo dependía de memoria humana (y ya había fallado con M1). Fix: `~/.claude/shell-lock.json` — manifiesto de huellas de los 45 archivos del shell, que permite a `/CBP` **detectar solo** qué cambió. `PENDING.md` queda para explicar el porqué. | Comando | `CBP.md` paso 0.f, `MECANICA-LOCK.md` §7 | **Aplicado (v4.3.0)** |
| M4 | ✅ Chequeo `1h` en `/salud`: IDs duplicados, colgados y saltos de secuencia. Al probarlo contra el propio ROADMAP de Diligencia apareció la causa raíz: el estándar mandaba descartar el ID al completar un ítem, garantizando citas colgadas — corregido en `MECANICA-CALIDAD.md` §1. | Comando | `salud.md` 1h, `MECANICA-CALIDAD.md` §1 | **Aplicado (v4.3.0)** |
| M5 | ✅ Chequeo `1i` en `/salud`: cruza pendientes contra CHANGELOG, existencia de archivos citados y estado de dependencias. Reporta con confianza y evidencia; nunca cierra un ítem solo (R79.2). | Comando | `salud.md` 1i | **Aplicado (v4.3.0)** |

Detalle completo: [`mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md`](mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md)

## 2026-08-24 — Némesis Detective

**Versión Diligencia heredada:** v4.2.2 (upgrade corrido el 2026-08-24) · **Origen:** Fase 2.6 de `/adaptar` — correr `scripts/check-docs.js` y verificar cada aviso contra el disco

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M6 | ✅ `check-docs.js` no soportaba anclas en rutas de variables — `existsSync()` sobre la ruta cruda hacía que `ROADMAP.md#tecnico` se reportara inexistente. Fix: separar el ancla antes de resolver + validar que el heading exista (slugs con normalización de tildes). | Script del template | `scripts/check-docs.js` | **Aplicado (v4.2.4)** |
| M7 | ✅ `extractTableValue()` leía `cols[2]` por posición fija — con el layout del propio template no validaba nada. Fix: busca la columna "Versión" por nombre de encabezado. | Script del template | `scripts/check-docs.js` | **Aplicado (v4.2.4)** |
| M8 | ✅ El parser de CHANGELOG solo reconocía `## [X.Y.Z]` y avisaba sin decir qué esperaba. Fix: acepta 3 patrones (`## [X.Y.Z]`, `## vX.Y.Z`, prefijo + `vX.Y.Z`), mensaje de fallback accionable. | Script del template | `scripts/check-docs.js` | **Aplicado (v4.2.4)** |

Los 3 se verificaron con pruebas de comportamiento real (layout de fábrica, escenario tipo
Némesis con los 3 problemas combinados, y un caso de versión genuinamente distinta) antes de
darlos por resueltos — ver `doc/arch/walkthrough/` para el detalle completo de las pruebas.

Detalle completo: [`mutaciones-recibidas/2026-08-24-nemesis_mutaciones.md`](mutaciones-recibidas/2026-08-24-nemesis_mutaciones.md)

## Archivos relacionados
- `doc/arch/ADR_SUMMARY.md` — resumen de ADRs
- `ROADMAP.md` — roadmap de evolución
