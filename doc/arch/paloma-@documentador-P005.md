# Paloma @documentador — P005

**Fecha:** 2026-07-04 | **Agente:** @documentador | **Version proyecto:** v2.6.6
**Consulta:** Auditoria de COMANDOS.md v2.6.6 — completitud, coherencia, seccion AGENTES, circuitos, referencias stale

---

## Resumen ejecutivo

Auditoria focalizada sobre COMANDOS.md (v2.6.6). El archivo esta bien estructurado y los 31 comandos coinciden con AGENTS.md. Se detectaron 12 hallazgos: 7 sobre COMANDOS.md directamente (flags faltantes, conteo engañoso de agentes, circuito @circuito ausente) y 5 sobre archivos externos con referencias stale (28/37/38 comandos en lugar de 31).

---

## Tabla de hallazgos — COMANDOS.md

| # | Categoria | Archivo | Hallazgo | Severidad |
|---|---|---|---|---|
| H1 | AGENTES | COMANDOS.md L63-68 | /paloma: faltan flags --descartar y --pendiente. El comando real tiene 10 flags; COMANDOS.md lista 8. | P2 |
| H2 | AGENTES | COMANDOS.md L42 | Header dice AGENTES (10 + 3 circuitos) pero hay 8 agentes + 2 comandos, no 10 agentes. | P2 |
| H3 | AGENTES | COMANDOS.md L73-76 | Circuitos de calidad: solo 3 (SDD, Paloma, Documental). Falta el circuito de integridad de @circuito. | P2 |
| H4 | COHERENCIA | AGENTS.md L80 | Header dice 30 fundamentales pero la tabla tiene 31 filas. | P2 |
| H5 | AGENTES | COMANDOS.md L76 | Circuito Paloma simplificado: omite estado En revision y transiciones --revisar, --pendiente, --descartar. | P3 |
| H6 | AGENTES | COMANDOS.md L76 | Circuito Documental: /documentar -> /agentes-sync no refleja relacion real (son comandos independientes). | P3 |

## Tabla de hallazgos — Archivos externos (referencias stale)

| # | Categoria | Archivo | Hallazgo | Severidad |
|---|---|---|---|---|
| H7 | STALE | GUIA_CHAMBER.md L11 | Dice los 28 comandos. Son 31. Visible en panel lateral de Chamber. | P2 |
| H8 | STALE | skills/diligencia-docs/SKILL.md L13-14 | Checks #1 y #2 referencian 28 comandos activos. Son 31. ¡Genera falsos positivos en cada auditoria! | P2 |
| H9 | STALE | GUIA_DE_COMANDOS.md L3 | Dice 38 comandos fundamentales. Son 31 activos (+ deprecados). | P3 |
| H10 | STALE | GUIA_REFERENCIA_RAPIDA.md L170 | Dice referencia completa de 37 comandos. Son 31. | P3 |
| H11 | INDEX | GUIA_DE_COMANDOS.md | INDEX.md registra v1.16.4 pero el archivo dice v1.16.3. Desincronizado. | P3 |
| H12 | STALE | ux-check.md L1 | Header dice v2.1.1. Version muy desactualizada. | P3 |


---

## Contenido cocinado

### H1 — Flags /paloma faltantes (COMANDOS.md L68)

Linea actual:
    --revisar PNNN, --archivar PNNN, --reabrir PNNN

Reemplazar por:
    --revisar PNNN, --archivar PNNN, --reabrir PNNN
    --descartar PNNN    descartar paloma-plan sin publicar
    --pendiente PNNN    revertir revision (revisando -> pendiente)

### H2 — Header AGENTES (COMANDOS.md L42)

Linea actual:
    ## AGENTES (10 + 3 circuitos)

Reemplazar por:
    ## AGENTES (8 agentes + 2 comandos + 3 circuitos)

### H3 — Circuito de integridad (COMANDOS.md L76, despues de la linea Documental)

Agregar:
    Integridad:      @circuito -> /circuito [area] -> reporte de handlers/rutas/navegacion

### H4 — Header AGENTS.md (AGENTS.md L80)

Linea actual:
    ## Comandos globales heredados — 30 fundamentales

Reemplazar por:
    ## Comandos globales heredados — 31 fundamentales

### H7 — GUIA_CHAMBER.md L11

Linea actual:
    - **Ver COMANDOS.md** — los 28 comandos agrupados por accion (CREAR/PLANIFICAR/EJECUTAR/REVISAR/CUIDAR)

Reemplazar por:
    - **Ver COMANDOS.md** — los 31 comandos agrupados por accion (CREAR/PLANIFICAR/EJECUTAR/REVISAR/CUIDAR/AGENTES)

### H8 — skills/diligencia-docs/SKILL.md

Linea 13: Cambiar los 28 activos -> los 31 activos
Linea 14: Cambiar AGENTS.md (28) -> AGENTS.md (31)

---

## Checklist de aplicacion

- [ ] H2: Corregir header AGENTES en COMANDOS.md (8 agentes + 2 comandos)
- [ ] H1: Agregar --descartar y --pendiente en seccion /paloma de COMANDOS.md
- [ ] H3: Agregar circuito de integridad @circuito
- [ ] H4: Corregir header 30 -> 31 en AGENTS.md
- [ ] H7: Corregir 28 -> 31 en GUIA_CHAMBER.md
- [ ] H8: Corregir 28 -> 31 en skills/diligencia-docs/SKILL.md (URGENTE)
- [ ] H5: Expandir circuito Paloma (opcional, P3)
- [ ] H9-H12: Corregir conteos stale en GUIA_DE_COMANDOS.md, GUIA_REFERENCIA_RAPIDA.md, INDEX sync, ux-check.md

---

## Riesgo de no actuar

- H8 (CRITICO): skill diligencia-docs con 28 genera FALSOS POSITIVOS en cada /documentar futuro
- H1: flags --descartar/--pendiente existen pero son invisibles para usuarios
- H7: Chamber muestra 28 comandos en panel lateral (dato incorrecto visible)

---

## Resumen

| Tipo | Cantidad | IDs |
|---|---|---|
| P1 | 0 | — |
| P2 | 6 | H1, H2, H3, H4, H7, H8 |
| P3 | 6 | H5, H6, H9, H10, H11, H12 |
| Total | 12 hallazgos | |

**Veredicto:** COMANDOS.md funcionalmente completo (31/31 comandos coinciden con AGENTS.md). La seccion AGENTES tiene 3 omisiones corregibles. 5 archivos externos tienen referencias stale al conteo antiguo de comandos.

**Archivos afectados:** COMANDOS.md, AGENTS.md, GUIA_CHAMBER.md, skills/diligencia-docs/SKILL.md, GUIA_DE_COMANDOS.md, GUIA_REFERENCIA_RAPIDA.md, ux-check.md

**Estimacion:** 15-30min | **Urgencia:** Este sprint
