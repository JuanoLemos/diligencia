# Palomas — Diligencia v2.4.2

Log de consultas a agentes (🕊️ palomas). Cada entrada registra una consulta, su resultado y qué hizo el MAIN. Las palomas individuales siguen `doc/arch/paloma-template.md`.

| ID | Fecha | Agente | Consulta | Hallazgos | Archivos afectados | Estimación | Urgencia | Veredicto | Estado | Acción MAIN |
|---|---|---|---|---|---|---|---|---|---|---|---|
| P001 | 2026-06-28 | @documentador | /documentar --legales | 3 (0 P1, 2 P2, 1 P3) | NOTICE.md, SECURITY.md, LICENSING.md | 🔧 | 🚨 | ⚠️ Faltan NOTICE y SECURITY.md | ✅ Actuado | NOTICE + SECURITY.md creados. LICENSING.md corregido. |
| P002 | 2026-06-28 | @documentador | /documentar (completo) | 21 hallazgos | AGENTS.md, COMANDOS.md, ROADMAP.md, +12 docs | 🏗️ | ⏳ | ⚠️ Varios docs stale | 🟡 En revisión | Pendiente de aplicar |
| P003 | 2026-06-28 | @documentador | /paloma "manifiesto diligencia" — auditoría de... | 15 (3 P1, 7 P2, 5 P3) | MANIFIESTO.md, README.md, GUIA_DE_BUENAS_PRACTICAS.md | 🔧 | 🚨 | ⚠️ Falta etimología, tono contractual | ✅ Actuado | MANIFIESTO + README + GUIA mejorados |
| P004 | 2026-06-28 | @documentador | /documentar --estructura (plan validación) | 1 (0 P1, 1 P2, 0 P3) | AGENTS.md (variable $PALOMAS) | ⚡ | 📅 | ✅ $PALOMAS agregada | 📬 Pendiente | — |

## Estados

| Estado | Significado | Símbolo |
|---|---|---|---|
| 📝 Plan | Paloma en planificación (borrador). No lista para MAIN | 📝 |
| 📬 Pendiente | Publicada. Lista para MAIN evaluar | 📬 |
| 🟡 En revisión | MAIN está evaluando las sugerencias | 🟡 |
| ✅ Actuado | MAIN aplicó los cambios (total o parcial) | ✅ |
| 🗑️ Ignorado | MAIN decidió no aplicar | 🗑️ |

## Columnas de triage

| Columna | Valores | Qué significa para MAIN |
|---|---|---|
| **Estimación** | ⚡ <5min / 🔧 15-30min / 🏗️ >1h | Cuánto tiempo tomaría aplicar la paloma completa |
| **Urgencia** | 🚨 antes de release / ⏳ este sprint / 📅 cuando haya tiempo | Cuándo debería actuar MAIN |
| **Archivos afectados** | Lista de rutas | Qué partes del proyecto se tocan |

## Archivos relacionados
- `AGENTS.md` — reglas MAIN ↔ AGENTE (Modelo Paloma Mensajera)
- `.opencode/commands/paloma.md` — comando de invocación
- `doc/arch/paloma-template.md` — template estándar para palomas individuales
- `doc/arch/paloma-main-plan.md` — reglas activas del MAIN hacia agentes
