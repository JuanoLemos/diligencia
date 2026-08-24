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
| M3 | `PENDING.md` se leía en `/CBP` paso 0.f pero nunca existió como archivo — el mecanismo de aviso de cambios globales sin versionar estaba inerte desde que se escribió la regla. Creado en la sesión de Némesis. | Comando | `CBP.md` paso 0.f | Pendiente |
| M4 | Sin chequeo de colisión de IDs en ROADMAP — aparecieron `D-08` y `T-40` duplicados, más IDs `TER.XX` citados sin fila de detalle. Sugerido: `/salud` valida unicidad + que todo ID citado resuelva. | Comando (sugerencia) | `salud.md` | Pendiente |
| M5 | Sin chequeo de "pendiente ya resuelto por otro camino" — ítems 🔴 marcados pendientes que ya estaban hechos bajo otro nombre. Sugerido: `/salud` compara pendientes contra el código. | Comando (sugerencia) | `salud.md` | Pendiente |

Detalle completo: [`mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md`](mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md)

## 2026-08-24 — Némesis Detective

**Versión Diligencia heredada:** v4.2.2 (upgrade corrido el 2026-08-24) · **Origen:** Fase 2.6 de `/adaptar` — correr `scripts/check-docs.js` y verificar cada aviso contra el disco

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M6 | `check-docs.js` no soporta anclas en rutas de variables — `existsSync()` sobre la ruta cruda hace que `ROADMAP.md#tecnico` se reporte inexistente aunque el archivo y la sección existan. Verificado contra el código real: confirmado. | Script del template | `scripts/check-docs.js` | Pendiente |
| M7 | `extractTableValue()` devuelve `cols[2]` por posición fija — en `\| archivo \| fecha \| versión \|` eso es la fecha; en el layout real del template (`\| archivo \| versión \| fecha \| resumen \|`) cae en `—` o `''` según la fila. Verificado: con el layout del propio template el validador no valida nada. | Script del template | `scripts/check-docs.js` | Pendiente |
| M8 | El parser de CHANGELOG solo reconoce `## [X.Y.Z]` (Keep-a-Changelog) y avisa *"Could not determine latest version"* sin decir qué formato espera — falla en silencio útil ante cualquier otro formato (ej. Nemesis usa `🔹 vX.Y.Z`). Verificado contra el código real: confirmado. | Script del template | `scripts/check-docs.js` | Pendiente |

Los 3 traen código, caso real y fix sugerido — ver detalle completo. Se aborda en sesión
separada: requiere mostrar diff propuesto antes de tocar `check-docs.js`.

Detalle completo: [`mutaciones-recibidas/2026-08-24-nemesis_mutaciones.md`](mutaciones-recibidas/2026-08-24-nemesis_mutaciones.md)

## Archivos relacionados
- `doc/arch/ADR_SUMMARY.md` — resumen de ADRs
- `ROADMAP.md` — roadmap de evolución
