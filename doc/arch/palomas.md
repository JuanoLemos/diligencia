# Palomas — Diligencia v2.4.2

Log de consultas a agentes (🕊️ palomas). Cada entrada registra una consulta y su resultado.

| ID | Fecha | Agente | Consulta | Hallazgos | Veredicto | Estado |
|---|---|---|---|---|---|---|
| P001 | 2026-06-28 | @documentador | /documentar --legales | 3 (0 P1, 2 P2, 1 P3) | ⚠️ Faltan NOTICE y SECURITY.md | Pendiente |
| P002 | 2026-06-28 | @documentador | /documentar (auditoría completa) | 21 (5 P1, 10 P2, 6 P3) | ⚠️ Versionado de headers desincronizado; faltan SECURITY.md y NOTICE | Parcial |

Estados: **Pendiente** = sin revisar por MAIN | **Parcial** = algunos hallazgos aplicados | **Aplicada** = todos los hallazgos resueltos | **Ignorada** = descartada por MAIN (R6)

## Archivos relacionados
- `AGENTS.md` — reglas MAIN ↔ AGENTE (Modelo Paloma Mensajera)
- `.opencode/commands/paloma.md` — comando de invocación
