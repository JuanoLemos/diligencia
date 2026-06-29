# Paloma Main Plan — Diligencia v2.4.2

Canal de comunicación **MAIN → AGENTE**. El MAIN escribe aquí reglas, directivas y feedback para los agentes. Cada agente lee este archivo al iniciar o al consultar `/paloma --news`.

| Fecha | Destinatario | Tipo | Mensaje |
|---|---|---|---|
| 2026-06-28 | @documentador | Regla | Modo cocinado: cuando reportes un hallazgo que requiera crear/editar un archivo, incluí el contenido COMPLETO (cocinado) en la columna "Acción sugerida". El MAIN copia y aplica. |
| 2026-06-28 | @documentador, @consejero, @circuito | Regla | Modo paloma: en chat separado del MAIN, solo investigás, analizás y reportás en tabla. NUNCA proponés BUILD, ni escribir archivos, ni /commit, ni /version. |
| 2026-06-28 | @documentador, @consejero, @circuito | Regla | R1-bis activa: podés escribir exclusivamente `doc/arch/paloma-AGENTE-PNNN.md` como archivo de paloma. Cualquier otra escritura está prohibida. |

<!-- PALOMA-MAIN-PLAN:ACTIVE-RULES -->
- @documentador: Modo cocinado activo
- @documentador, @consejero, @circuito: Modo paloma activo (solo reportar, nunca BUILD)
- @documentador, @consejero, @circuito: R1-bis activa (escribir solo paloma-*.md)
<!-- /PALOMA-MAIN-PLAN:ACTIVE-RULES -->

## Cómo funciona

1. El MAIN escribe entradas en esta tabla cuando necesita comunicar algo a uno o varios agentes.
2. El agente, al iniciar o al ejecutar `/paloma --news`, lee este archivo y procesa las reglas.
3. Las reglas se consideran vigentes hasta que el MAIN las remueva explícitamente.
4. Si un agente no está listado en "Destinatario", la regla no aplica para él.

## Archivos relacionados
- `doc/arch/palomas.md` — log de palomas (AGENTE → MAIN)
- `.opencode/commands/paloma.md` — comando de invocación
- `AGENTS.md` — reglas MAIN ↔ AGENTE (Modelo Paloma Mensajera)
