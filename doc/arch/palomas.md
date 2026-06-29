# Palomas — Diligencia v2.4.2

Log de consultas a agentes (🕊️ palomas). Cada entrada registra una consulta, su resultado y qué hizo el MAIN.

| ID | Fecha | Agente | Consulta | Hallazgos | Veredicto | Estado | Acción MAIN |
|---|---|---|---|---|---|---|---|
| P001 | 2026-06-28 | @documentador | /documentar --legales | 3 (0 P1, 2 P2, 1 P3) | ⚠️ Faltan NOTICE y SECURITY.md | ✅ Actuado | NOTICE + SECURITY.md creados. LICENSING.md corregido. |
| P002 | 2026-06-28 | @documentador | /documentar (completo) | 21 hallazgos | ⚠️ Varios docs stale | 🟡 En revisión | Pendiente de aplicar |

## Estados

| Estado | Significado |
|---|---|
| 📬 Pendiente | Paloma recibida, MAIN no evaluó aún. Default al registrarse. |
| 🟡 En revisión | MAIN está evaluando las sugerencias. |
| ✅ Actuado | MAIN aplicó los cambios (total o parcial). |
| 🗑️ Ignorado | MAIN decidió no aplicar. |

## Archivos relacionados
- `AGENTS.md` — reglas MAIN ↔ AGENTE (Modelo Paloma Mensajera)
- `.opencode/commands/paloma.md` — comando de invocación
