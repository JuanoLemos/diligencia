# Walkthrough — Fix: MECANICA-CALIDAD era una referencia colgada

**Fecha:** 2026-08-14 14:06 · **Comando:** `/CBP` · **Modelo:** claude-opus-5

---

## Qué se hizo

`MECANICA-CALIDAD.md` nunca se copiaba a los proyectos adaptados, pero varios comandos
globales la invocaban por nombre. En v4.2.0 el problema empeoró: le puse adentro la Definición
de Hecho y la referencié tres veces desde `/CBP`, que corre en todos los proyectos. Resultado:
`/CBP` en Nemesis mandaba a leer un archivo que ahí no existe.

Se la convirtió en mecánica canónica (se copia y sincroniza como las demás) y se marcó su §3
como exclusiva del repo de Diligencia.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| `doc/mecanicas/MECANICA-CALIDAD.md` | §3 marcada "solo repo de Diligencia"; v1.1 → v1.2 |
| Template `doc/mecanicas/MECANICA-CALIDAD.md` | **Copiada** — ahora canónica |
| Template `INDEX.md` | Tablas de Mecánicas y Referencias pre-cargadas (nacían vacías) |
| `~/.claude/commands/adaptar.md` | Fila de migración v4.2.0 → v4.2.1; v4.2.1 |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.2.1 |

## Decisiones

| Decisión | Fundamento |
|---|---|
| Hacerla canónica en vez de sacarle el DoD | Se revisó sección por sección: **5 de 6 aplican a cualquier proyecto** (estándar de ROADMAP, estándar de documentos, estilo markdown, autocheck, DoD). Solo §3 es interna. Mover el DoD a otro lado habría dejado las otras 4 igual de inaccesibles |
| Marcar §3 en vez de partir el archivo en dos | Partirlo daba dos mecánicas que hay que mantener sincronizadas por un solo párrafo de diferencia. Una nota al principio de §3 cuesta menos y no crea drift |
| Pre-cargar el `INDEX.md` del template | Nacía declarando tablas vacías de Mecánicas y Referencias, cuando `/adaptar` sí instala 4 mecánicas, bitácora y plantilla de walkthrough. El INDEX de un proyecto nuevo arrancaba desactualizado desde el minuto cero |

## Evidencia (R16)

- Ausente del template: `templates/.../doc/mecanicas/` listaba solo `MANDATO`, `MECANICA-AUDIO`, `MECANICA-LOCK`
- Ausente de Nemesis: `nemesis/doc/mecanicas/` sin coincidencias para "calidad"
- Referenciada igual: `adaptar.md:237` (Fase 2.6) y `CBP.md:527, 533, 559`
- No estaba deprecada: sin marcas de deprecación en `ROADMAP.md` ni `doc/arch/`; versión activa v1.1

## Pendientes

- [ ] R83 sigue como P1 pendiente ("propagar v4.2.0 a los 6 proyectos"), pero el usuario indicó que **propagar quedó deprecado** y que correrá `/adaptar` por proyecto. Falta marcarlo 🗑️ Deprecado con esa nota

## Commits

| Ref | Mensaje |
|---|---|
| `v4.2.1` | `fix(mecanicas): MECANICA-CALIDAD pasa a canonica — referencia colgada en proyectos` |
