# Walkthrough — Adopción de 3 patrones de nsSkeleton

**Fecha:** 2026-08-14 13:12 · **Comando:** `/CBP` (full) · **Modelo:** claude-opus-5

---

## Qué se hizo

Se estudió **nsSkeleton** (`nubixcomar/nsskeleton`, framework agéntico de nubixstore) como
referencia externa y se adoptaron 3 de sus patrones a Diligencia, traducidos a nuestra
arquitectura en vez de copiados: un manifiesto de sincronización con huellas digitales, un
walkthrough por sesión, y una Definición de Hecho explícita.

El primero resuelve un problema real que apareció en esta misma sesión: al sincronizar
mecánicas hacia Nemesis, no había forma de saber si un archivo local estaba customizado a
propósito o simplemente viejo.

## Cambios aplicados

| Archivo | Cambio |
|---|---|
| `doc/mecanicas/MECANICA-LOCK.md` | **Nuevo** — manifiesto `diligencia-lock.json`, comparación de 3 vías, ciclo de vida |
| `doc/arch/walkthrough/_template.md` | **Nuevo** — plantilla de detalle por sesión |
| `doc/arch/bitacora.md` | **Nuevo** — índice append-only, 1 línea por sesión |
| `doc/mecanicas/MECANICA-CALIDAD.md` | §6 Definición de Hecho (base + extendido); estado `🧪 En verificación` en §1; v1.0 → v1.1 |
| `CLAUDE.md` | Variables `$BITACORA`, `$WALKTHROUGH`, `$LOCK` |
| `~/.claude/commands/adaptar.md` | Fase 2.5 reescrita (3 vías vía lock); Flujo A pasos 9b/9c; `git add` incluye el lock; validación ampliada; v4.1.3 → v4.2.0 |
| `~/.claude/commands/CBP.md` | Secciones §Cierre de sesión y §Verificación DoD; reglas 21 y 22 |
| Template `diligencia-doc-base/` | +`MECANICA-LOCK.md`, +`bitacora.md`, +`doc/arch/walkthrough/_template.md`, −`sesion.md` |
| `CHANGELOG.md`, `DILIGENCIA.md`, `INDEX.md` | Entrada v4.2.0 |

## Decisiones

| Decisión | Fundamento |
|---|---|
| Traducir los patrones, no copiarlos | Skeleton es multi-IA con actualizador programático (`core-lock.json` + PHP); Diligencia es nativa Claude Code con `/adaptar` conversacional. Copiar su `core-manifest.json` (core_paths/app_paths/exclude) habría traído complejidad sin uso: acá alcanza con listar los archivos trackeados — lo que no está en el lock es del proyecto por definición |
| Usar `sha256sum` en vez de un script propio | Ya está disponible en Git Bash (verificado). Un script en `scripts/` habría metido runtime a una metodología que es Markdown puro |
| Que el DoD informe y no bloquee | Un checklist que frena el trabajo se saltea; uno que informa se usa. Además R79.2: la decisión final es del usuario |
| Bootstrap silencioso del lock en proyectos viejos | Los 6 proyectos adaptados no tienen lock. Alternativa descartada: pedirles re-adaptación completa. Se asume el estado actual como correcto y se empieza a trackear desde ahí — sin pérdidas ni preguntas |
| Eliminar `sesion.md` del template | Existía pero estaba dormido: nadie lo generaba ni lo indexaba. `walkthrough/_template.md` lo reemplaza con un sistema real detrás. Mantener los dos habría sido exactamente el drift que Diligencia intenta evitar |
| Adoptar solo 3 de las 6 ideas detectadas | Las otras 3 (log incremental por agente, `features-resume.md`, override `app-agentic/`) se descartaron por ahora: las dos primeras se solapan con CHANGELOG + bitácora, y la tercera requiere rediseñar cómo se heredan las reglas R1-R81 — cambio mayor, no incremental |

## Evidencia (R16)

- `sha256sum` disponible: `/usr/bin/sha256sum` (verificado con `which` + hash de prueba)
- `sesion.md` existía dormido: `templates/diligencia-doc-base/sesion.md` — plantilla de sesión sin ningún comando que la generara (grep sin resultados en `~/.claude/commands/`)
- Estados de ROADMAP previos: `MECANICA-CALIDAD.md:22` listaba 4 estados, pero `ROADMAP.md:38` ya usaba `🗑️ Deprecado` sin documentar
- Diligencia se movió de `C:\xampp\htdocs\Diligencia` a `C:\Proyectos\activos\Diligencia` (detectado al fallar las lecturas por ruta vieja)

## Pendientes

- [ ] Propagar v4.2.0 a los 6 proyectos adaptados vía `/adaptar` — cada uno generará su `diligencia-lock.json` en la primera pasada (bootstrap). Nemesis es el candidato natural para probar primero: ya tiene `MECANICA-AUDIO.md` copiada a mano en esta sesión, así que sirve para verificar que el bootstrap la registre como "en sync" y no como conflicto
- [ ] Evaluar las 3 ideas de nsSkeleton descartadas si el uso lo pide (log incremental por agente, `features-resume.md`, override tipo `app-agentic/`)
- [ ] `.opencode/` tiene 48 archivos borrados sin commitear en el working tree (arrastre de la deprecación previa, ajeno a esta sesión) — decidir si se commitea aparte

## Commits

| Ref | Mensaje |
|---|---|
| `v4.2.0` | `feat(mecanicas): adoptar 3 patrones de nsSkeleton — lock, walkthrough, DoD` |

> Se referencia el tag y no el hash: este walkthrough viaja **dentro** del commit que describe,
> así que su hash no es conocible desde adentro. El tag resuelve al hash igual.
