# Walkthrough — Fix en la resolución de `<último-release>`

**Fecha:** 2026-08-24 13:30 · **Comando:** `/CBP` (sin argumento) · **Modelo:** claude-opus-5

---

## Qué se hizo

Se corrió `/CBP` para cerrar la sesión y el pre-flight reportó **12 commits "sin liberar"** que
en realidad estaban todos publicados y tagueados. El comando que se estuvo arreglando todo el
día terminó delatando un bug propio.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| `~/.claude/commands/CBP.md` | §Resolución de "último release" reescrita: algoritmo de dos señales |
| `~/.claude/commands/version.md` | Pasos 1 y Validación: referencian el algoritmo unificado en vez de duplicar el grep |
| `~/.claude/commands/adaptar.md` | v4.3.0 → v4.3.1 + fila de migración; campo Fecha corregido (decía 2026-08-23) |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.3.1; fecha global de INDEX corregida |

## La causa

`<último-release>` se resolvía buscando un commit cuyo mensaje empezara con `chore(release):` o
`release:`. Eso funcionaba mientras el proceso documentado (`version.md` paso 10) se siguiera
al pie de la letra: commit de release aparte, después tag.

Pero los releases v4.2.0 → v4.3.0 de esta sesión se hicieron distinto: el CHANGELOG y el bump
viajaron **dentro del commit de trabajo**, y el tag se puso sobre ese mismo commit. Ningún
commit dice `chore(release):` desde v3.9.2. Así que la resolución retrocedía hasta `v4.1.0` —el
último con commit propio— y arrastraba 12 commits de más.

Además del ruido, eso ensanchaba el rango del pre-check de bump (R6) unas 6 versiones.

## Decisiones

| Decisión | Fundamento |
|---|---|
| Unir las dos señales en vez de reemplazar una por otra | La regla 20 prohíbe `git describe --tags` porque Némesis tenía releases **sin** tag. Acá pasa lo inverso: tags **sin** commit de release. Ninguna señal es completa sola; elegir una y descartar la otra solo mueve el punto ciego. El fix toma la **más reciente de las dos** |
| No cambiar el proceso de release para que siempre haya commit `chore(release):` | Era la alternativa obvia: mandar el proceso documentado y listo. Se descartó porque hace la detección dependiente de disciplina humana — exactamente lo que falló en M1 y en M3. Un mecanismo robusto ante las dos formas de marcar un release es mejor que uno que exige recordar una |
| Usar `git merge-base --is-ancestor` para decidir cuál gana | Comparar por fecha de tag falla si alguien taguea retroactivamente un commit viejo. La posición real en la historia es el criterio correcto |

## Evidencia (R16)

- Discrepancia confirmada antes de tocar nada: `git log --grep=...` → `b5d8fd5 release: v4.1.0`, mientras `v4.2.0`…`v4.3.0` apuntan a `8c0948c`…`943b142`
- `git log --oneline --all --grep='^chore(release):'` → el más reciente es `eef67e5 chore(release): v3.9.2`
- Los 4 escenarios posibles probados en un repo temporal: sin releases → primer commit; release sin tag (Némesis) → el commit de release; tag sin release (Diligencia) → el commit tagueado; release posterior al tag → el commit de release
- Efecto medido del fix: commits "sin liberar" pasan de **12 a 0**

## Pendientes

- [ ] `version.md` paso 10 sigue documentando `git commit -m "chore(release): vX.Y.Z"` como proceso. Con el fix ya no importa cuál de las dos formas se use, pero convendría decidir cuál es la recomendada y dejarlo escrito — hoy el documento dice una cosa y la práctica hace otra
- [ ] Némesis necesita correr `/adaptar` para recibir `check-docs.js` (v4.2.4) y las mecánicas actualizadas

## Commits

| Ref | Mensaje |
|---|---|
| `v4.3.1` | `fix(CBP): resolver último-release por dos señales — commit de release o tag` |
