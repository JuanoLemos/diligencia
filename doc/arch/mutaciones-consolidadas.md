# Mutaciones consolidadas — Diligencia v1.0.0

Observaciones recibidas de proyectos adaptados, registradas vía `/mutacion`.
Cada entrada representa una desviación del estándar que podría sugerir una evolución de Diligencia.

---

## 2026-08-23 — Némesis Detective

**Versión Diligencia heredada:** v4.2.1 · **Origen:** sesión de trabajo real (no auditoría teórica)

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M1 | `circuito`: 2 puntos ciegos — permiso incompatible con el llamador (ruta con consumidor real que igual falla siempre por rol distinto + `.catch()` vacío que oculta el 403), y promesas del prompt sin respaldo en la UI (el prompt suprime su propia alternativa textual asumiendo botones que no existen). Ya aplicado localmente como chequeos 4b/4c. | Agente global | `agents/circuito.md` | Pendiente |
| M2 | ✅ **Bootstrap del lock producía falsos positivos destructivos.** Confirmado y corregido en Diligencia v4.2.2 (2026-08-23) — se adoptó el fix propuesto por Nemesis: schema de lock con `sha256` + `template_sha256` + `origen` (comparación de 3 → 4 vías). Ver `MECANICA-LOCK.md` v1.1.0 §4. | Mecánica | `MECANICA-LOCK.md`, `adaptar.md` Fase 2.5 | **Aplicado (v4.2.2)** |
| M3 | `PENDING.md` se leía en `/CBP` paso 0.f pero nunca existió como archivo — el mecanismo de aviso de cambios globales sin versionar estaba inerte desde que se escribió la regla. Creado en la sesión de Némesis. | Comando | `CBP.md` paso 0.f | Pendiente |
| M4 | Sin chequeo de colisión de IDs en ROADMAP — aparecieron `D-08` y `T-40` duplicados, más IDs `TER.XX` citados sin fila de detalle. Sugerido: `/salud` valida unicidad + que todo ID citado resuelva. | Comando (sugerencia) | `salud.md` | Pendiente |
| M5 | Sin chequeo de "pendiente ya resuelto por otro camino" — ítems 🔴 marcados pendientes que ya estaban hechos bajo otro nombre. Sugerido: `/salud` compara pendientes contra el código. | Comando (sugerencia) | `salud.md` | Pendiente |

Detalle completo: [`mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md`](mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md)

## Archivos relacionados
- `doc/arch/ADR_SUMMARY.md` — resumen de ADRs
- `ROADMAP.md` — roadmap de evolución
