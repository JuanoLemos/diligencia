# Walkthrough — Fix 3 bugs en check-docs.js (M6, M7, M8)

**Fecha:** 2026-08-24 12:51 · **Comando:** `/CBP` (vía `/mutacion`) · **Modelo:** claude-sonnet-5

---

## Qué se hizo

Nemesis reportó 3 fallos del validador `scripts/check-docs.js` durante un upgrade real
(Fase 2.6 de `/adaptar`), con código exacto, caso real y fix sugerido para cada uno. Se
verificaron los 3 contra el código real del template (no se aceptó el reporte a ciegas), se
implementaron los fixes, y se probaron con escenarios de comportamiento real antes de darlos
por resueltos — no solo lectura de código.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| Template `scripts/check-docs.js` | 3 fixes: separación de ancla (M6), columna por nombre de encabezado (M7), múltiples patrones de CHANGELOG (M8) |
| Diligencia `scripts/check-docs.js` | Sincronizado — estaba desactualizado, tenía la versión con los 3 bugs |
| `~/.claude/commands/adaptar.md` | v4.2.3 → v4.2.4; fila de migración |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.2.4 |
| `doc/arch/mutaciones-consolidadas.md` | M6/M7/M8: Pendiente → Aplicado |

## Decisiones

| Decisión | Fundamento |
|---|---|
| Adoptar los 3 fixes propuestos por Nemesis, con ajustes menores | El diseño ya estaba probado contra los casos reales que lo motivaron. Único cambio: usar `̀-ͯ` explícito en vez de los caracteres combinantes crudos que traía la propuesta — verificado que ambos son idénticos byte a byte (test en Node), el cambio fue solo por legibilidad de código, no funcional |
| Verificar con pruebas de comportamiento, no solo lectura | El propio bug M7 nació de código que "parecía razonable" leído rápido (`cols[2]` es una forma común de leer tablas). Confiar solo en la lectura para dar por buena la corrección habría sido el mismo error de origen. Se armaron 3 escenarios: layout de fábrica del template, escenario Némesis completo (columnas invertidas + ancla + CHANGELOG no estándar), y un caso de versión genuinamente distinta (para confirmar que el fix no volvió el chequeo permisivo de más) |
| No corregir el bug cosmético `vv9.9.9` (doble v) encontrado de paso | Preexistente en el código original, no reportado por Nemesis, no relacionado a M6/M7/M8. Corregirlo ahora sería scope creep sobre una sesión ya extensa — queda anotado para una futura auditoría de `check-docs.js` |
| Sincronizar la copia de `scripts/check-docs.js` de Diligencia además del template | Diligencia tenía su propia copia desactualizada (con los 3 bugs). Se corrió el script contra el propio repo tras el fix — 2 avisos preexistentes sin relación (versión de guías/mecánicas vs versión de proyecto, que no aplica a Diligencia como fuente) |

## Evidencia (R16)

- M6 confirmado: `check-docs.js` línea 92 (antes del fix) — `existsSync(full)` sobre ruta sin separar `#ancla`
- M7 confirmado: línea 25 (antes del fix) — `return cols[2] \|\| null`; probado que en el layout real del template `cols[2]` cae en `—` o `''` según la fila
- M8 confirmado: línea 47 (antes del fix) — regex único `/##\s*\[(\d+\.\d+\.\d+)\]/`
- Test 1 (layout de fábrica, ROADMAP.md presente): `✅ No warnings`
- Test 2 (escenario Némesis: columnas invertidas + CHANGELOG `.mak` + `$RM_TX` con ancla real + `$RM_FALSO` con ancla inexistente): solo avisó del ancla genuinamente inexistente — 0 falsos positivos
- Test 3 (INDEX.md con versión deliberadamente incorrecta): el aviso de mismatch se sigue disparando — confirma que el fix no volvió el chequeo permisivo de más
- `node scripts/check-docs.js` corrido contra el propio repo de Diligencia post-fix: 2 avisos preexistentes sin relación a M6/M7/M8

## Pendientes

- [ ] M3, M4, M5 de la tanda del 2026-08-23 siguen `Pendiente`, sin tocar
- [ ] Bug cosmético `vv9.9.9` en el mensaje de mismatch de versión — no reportado, no bloqueante, anotado para el futuro
- [ ] Proyectos con `scripts/check-docs.js` ya copiado (posiblemente los 6 adaptados) necesitan correr `/adaptar` para recibir el fix — Fase 1 punto 3b lo ofrece

## Commits

| Ref | Mensaje |
|---|---|
| `v4.2.4` | `fix(scripts): check-docs.js — anclas, columna por nombre, formatos de CHANGELOG (M6/M7/M8)` |
