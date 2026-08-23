# Walkthrough — Fix bug de bootstrap en diligencia-lock.json (mutación M2)

**Fecha:** 2026-08-23 20:40 · **Comando:** `/CBP` (vía `/mutacion` + `/revision`) · **Modelo:** claude-sonnet-5

---

## Qué se hizo

Némesis envió una mutación (M2, vía `/mutacion`) reportando que el bootstrap de
`diligencia-lock.json` producía falsos positivos destructivos: casi revirtió `identidad.md`,
`MANDATO.md` y una `MECANICA-AUDIO.md` más nueva que la del template. Se verificó la mutación
contra el código real de `MECANICA-LOCK.md` y `adaptar.md` Fase 2.5 (no se aceptó el reporte a
ciegas), se confirmó como bug de diseño genuino, y se aplicó el fix propuesto por Nemesis.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| `doc/mecanicas/MECANICA-LOCK.md` | §2 (schema JSON), §4 (comparación 3→4 vías), §5 (bootstrap). v1.0.0 → v1.1.0 |
| Template `MECANICA-LOCK.md` | Sincronizado, idéntico a Diligencia |
| Template `INDEX.md` | Versión de `MECANICA-LOCK.md` actualizada |
| `~/.claude/commands/adaptar.md` | Fase 2.5 reescrita (bootstrap conservador, comparación 4 vías); paso 9c (Flujo A); fila de migración v4.2.1→v4.2.2; v4.2.2 |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.2.2 |
| `doc/arch/mutaciones-consolidadas.md` | M2: Pendiente → Aplicado (v4.2.2) |

## Decisiones

| Decisión | Fundamento |
|---|---|
| Adoptar el schema de Nemesis (`template_sha256` + `origen`) en vez de diseñar uno propio | Ya estaba probado contra el caso real que lo motivó, es retrocompatible (agrega campos, no saca ninguno), y reinventar la rueda no aportaba nada — el diseño de Nemesis ataca la causa exacta |
| Bootstrap **nunca** sincroniza en su propia pasada, ni siquiera para los casos obviamente seguros (`origen: template`) | Alternativa descartada: sincronizar de una vez los archivos que en bootstrap resultan idénticos al template. Se descartó porque mezclar "registrar" con "sincronizar" en la misma pasada es exactamente el tipo de atajo que causó el bug original — separar las dos operaciones en el tiempo es lo que permite razonar sobre "qué cambió desde cuándo" en la pasada siguiente |
| Fila `origen: override` + template avanzó → informar, no forzar ni bloquear | Consistente con R79.2 y con la regla 22 de `/CBP` (DoD informa, no bloquea): el override es intencional, el usuario decide si vale la pena revisarlo contra la evolución del template |
| No reescribir retroactivamente los locks ya bootstrapeados con el bug viejo | No existen todavía — ningún proyecto adaptado antes de esta sesión llegó a correr `/adaptar` bajo v4.2.0/v4.2.1 con bootstrap real (Nemesis detectó el problema *durante* su propio bootstrap, no lo dejó consolidado). Los 5 proyectos restantes van a bootstrapear directo con el schema corregido |

## Evidencia (R16)

- Bug reproducido leyendo el código real: `MECANICA-LOCK.md:86` (v1.0.0, antes del fix) — "tomando el estado actual como base"; `adaptar.md:205-208` (antes del fix) — mismo texto en Fase 2.5 paso 1
- Confirmado que `identidad.md`/`MANDATO.md` divergen del template por diseño en cualquier proyecto adaptado (placeholder `[Nombre del Sistema]` reemplazado en Flujo A) — la condición que dispara el bug no es un edge case, es el estado normal de todo proyecto
- Reporte original: `doc/arch/mutaciones-recibidas/2026-08-23-nemesis_mutaciones.md`, sección "M2 — Detalle"

## Pendientes

- [ ] Los 5 proyectos que faltan propagar (`+RM`, `MarketAI`, `conquisitare`, `buenobonitobarato`, `OpenMontage`) van a bootstrapear directo con el schema v1.1.0 — sin acción adicional
- [ ] M1, M3, M4, M5 de la misma tanda de mutaciones de Nemesis siguen `Pendiente` — no se tocaron en esta sesión, solo M2 por ser la más severa

## Commits

| Ref | Mensaje |
|---|---|
| `v4.2.2` | `fix(mecanicas): MECANICA-LOCK schema de 2 huellas — corrige falsos positivos destructivos en bootstrap (M2)` |
