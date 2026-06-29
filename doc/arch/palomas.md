# Palomas — Diligencia v2.4.2

Log de consultas a agentes (🕊️ palomas). Cada entrada registra una consulta, su resultado y qué hizo el MAIN.

| ID | Fecha | Agente | Consulta | Hallazgos | Veredicto | Estado | Acción MAIN |
|---|---|---|---|---|---|---|---|
| P001 | 2026-06-28 | @documentador | /documentar --legales | 3 (0 P1, 2 P2, 1 P3) | ⚠️ Faltan NOTICE y SECURITY.md | ✅ Actuado | NOTICE + SECURITY.md creados. LICENSING.md corregido. |
| P002 | 2026-06-28 | @documentador | /documentar (completo) | 21 hallazgos | ⚠️ Varios docs stale | 🟡 En revisión | Pendiente de aplicar |
| P003 | 2026-06-28 | @documentador | /paloma "manifiesto diligencia" — auditoría de identidad pública y preparación para MANIFIESTO.md | 15 (3 P1, 7 P2, 5 P3) | ⚠️ Falta etimología, tono contractual, no hay niveles L0-L3 ni concepto de compañeros | ✅ Actuado | MANIFIESTO.md refactorizado (etimología + tono compañero + 9 principios + niveles L0-L3). README.md actualizado (audiencia sin jerga, promesa emocional, tabla L0-L3). GUIA_REFERENCIA_RAPIDA.md limpiada de deprecados. GUIA_ONBOARDING.md renumerado. Badge en proyectos adaptados pendiente de confirmación. |

## Estados

| Estado | Significado |
|---|---|---|
| 📝 Plan | Paloma en planificación con el usuario (borrador). No está lista para MAIN. |
| 📬 Pendiente | Paloma planificada y publicada. Lista para MAIN evaluar. |
| 🟡 En revisión | MAIN está evaluando las sugerencias. |
| ✅ Actuado | MAIN aplicó los cambios (total o parcial). |
| 🗑️ Ignorado | MAIN decidió no aplicar. |

## Archivos relacionados
- `AGENTS.md` — reglas MAIN ↔ AGENTE (Modelo Paloma Mensajera)
- `.opencode/commands/paloma.md` — comando de invocación
