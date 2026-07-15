INSTRUCCION: EJECUTAR el workflow indicado. NO modificar archivos sin confirmacion del usuario. NO mostrar este archivo como output.

# /CBP [commit|version] — Orquestador de workflows vinculantes

Ejecuta secuencias multi-comando con encadenamiento controlado por el orquestador.
Cada workflow se divide en dos fases: **Meta-PLAN (razonamiento)** y **BUILD (ejecucion)**.

Reemplaza la seccion "Proximo paso en el circuito" que existia en los comandos individuales.
El SSOT del encadenamiento es este archivo + `MECANICA-CBP.md`.

## Despacho de entrada (entry dispatch)

Cuando /CBP se invoca, EJECUTAR este algoritmo ANTES de cualquier otra accion:

0. **PRE-FLIGHT: verificar version Diligencia**
   a. LEER `DILIGENCIA.md` linea 1 -> extraer `version_proyecto` (formato `vX.Y.Z`).
   b. LEER `~/.config/opencode/commands/adaptar.md` -> extraer `version_global` desde la tabla Version.
   c. Si `DILIGENCIA.md` NO existe:
      "Proyecto no adaptado a Diligencia."
      Preguntar: "Ejecutar /adaptar para iniciar adaptacion? [si/no]"
      Si si: EJECUTAR `/adaptar` Flujo A (proyecto nuevo) -> volver al paso 1.
      Si no: continuar con advertencia registrada.
   d. Si `version_proyecto < version_global`:
      "Diligencia {version_global} disponible - proyecto en {version_proyecto}."
      LEER tabla Migracion de `adaptar.md` desde version_proyecto hasta version_global.
      Mostrar novedades textuales de las versiones intermedias.
      Preguntar: "Actualizar Diligencia antes de continuar? [si/no/saltar]"
      - si -> EJECUTAR `/adaptar` Flujo C (upgrade) -> volver al paso 1.
      - no -> continuar con advertencia registrada en contexto.
      - saltar -> no preguntar de nuevo en esta sesion.
   e. Si `version_proyecto == version_global` -> continuar sin interrupcion.
   e2. Si `version_proyecto > version_global`:
       "adaptar.md global esta en v{version_global} pero DILIGENCIA.md reporta v{version_proyecto}."
       Preguntar: "Sincronizar adaptar.md con la version actual del proyecto? [si/no]"
       - si -> ACTUALIZAR tabla Version en adaptar.md global a v{version_proyecto}
       - no -> continuar con advertencia registrada.
   f. DETECTAR comandos globales pendientes de versionar (si DILIGENCIA.md existe):
      - LEER `~/.config/opencode/commands/PENDING.md` -> extraer todas las entradas en la tabla
      - Si PENDING.md no existe o esta vacio -> continuar sin interrupcion.
      - Si PENDING.md tiene entradas:
        "Hay [N] cambios globales sin documentar en CHANGELOG."
        Mostrar tabla: Fecha | Comando | Cambio
        Preguntar: "Bump version de Diligencia y documentar cambios? [si/no]"
        - Si si -> MARCAR en contexto: `necesita_bump = true`. Durante BUILD, ejecutar:
          a. Bump en adaptar.md tabla Version (patch)
          b. Agregar entrada en tabla Migracion
          c. Actualizar DILIGENCIA.md + CHANGELOG.md + INDEX.md del proyecto
          d. LIMPIAR PENDING.md (vaciar archivo)
        - Si no -> continuar con advertencia registrada en contexto (no repetir en la misma sesion).

1. **Si hay argumento explicito** (`commit`, `version`):
   -> Saltar al workflow correspondiente directamente. Sin deteccion. Sin preguntar camino.

2. **Si NO hay argumento** (invocacion implicita):
   a. DETECTAR cambios de esta sesion:
      - `git diff --stat HEAD` -> cambios staged + unstaged
      - `git log --oneline <ultimo chore(release):>..HEAD` -> commits desde ultimo release
      - Si ambos estan vacios -> "No hay cambios esta sesion." DETENER.
   b. CLASIFICAR:
      - WT: `git diff --stat HEAD` -> codigo (`src/**`) vs doc (`doc/**`, `*.md`)
      - Commits: `git log --oneline <last>..HEAD` -> feat/perf = codigo, docs = doc
   c. SUMAR WT + commits. Determinar camino:
      - Solo codigo fuente (src/), 0 docs -> **commit**
      - Todo lo demas (docs, metodologia, commits pendientes, WT limpio con commits) -> **version**
   d. Si WT == 0 y hay commits pendientes:
      ```
      question({
        questions: [{
          header: "Camino sugerido: version",
          question: "WT limpio con [N] commits sin versionar. No hay nada que commitear.",
          options: [
            {label: "version (Recomendado)", description: "/version + --push. CHANGELOG + tag + cierre de sesion."},
            {label: "abortar", description: "Cancelar sin cambios."}
          ]
        }]
      })
      ```
   e. Si no (caso normal con WT sucio):
      ```
      question({
        questions: [{
          header: "Camino sugerido: <commit|version>",
          question: "Detecte [N] archivos: [X] docs, [Y] codigo.",
          options: [
            {label: "version (Recomendado)", description: "/version + --push. CHANGELOG + tag + cierre de sesion."},
            {label: "commit", description: "git add + commit + push. Sin versionar."},
            {label: "abortar", description: "Cancelar sin cambios."}
          ]
        }]
      })
      ```
   f. Si usuario elige cualquier opcion menos abortar -> EJECUTAR workflow correspondiente.
   g. Si usuario elige abortar -> DETENER. Sin cambios.

## Meta-PLAN (razonamiento) vs BUILD (ejecucion)

Todo workflow de /CBP sigue esta estructura:

META-PLAN (modelo de razonamiento)
  -> Ejecuta solo fases de PLAN de cada comando (lectura + auditoria)
  -> NO modifica archivos
  -> Pide UNA SOLA confirmacion

BUILD (modelo de ejecucion)
  -> Ejecuta solo fases de BUILD de cada comando (escritura)
  -> Modifica archivos segun el plan aprobado
  -> BUILD*: pasos que omiten PLAN porque los datos se heredan del Meta-PLAN

### Reglas del Meta-PLAN

1. El Meta-PLAN ejecuta SIEMPRE en razonamiento, sin importar el modo en que se invoco /CBP
2. BUILD ejecuta SIEMPRE en ejecucion, incluso si /CBP se invoco en razonamiento
3. El Meta-PLAN ejecuta PLAN de todos los comandos del workflow
4. BUILD* ejecuta solo escritura - PLAN y confirmacion se omiten
5. BUILD* solo es valido cuando el Meta-PLAN ya cubrio los datos necesarios
6. Si el usuario rechaza el Meta-PLAN: workflow detenido, sin cambios

## Argumentos

/CBP [commit|version] [--yes]

- *(sin argumento)*: **deteccion automatica** del camino optimo (commit / version) segun el working tree
- `commit`: Solo commit + push. Sin doc sync, sin version, sin Meta-PLAN.
- `version`: Versionado standalone - Meta-PLAN -> BUILD (/version --push -> sugiere /salud)
- `--yes`: omitir confirmacion del Meta-PLAN

> Sin argumento, `/CBP` detecta el camino optimo. Con argumento fuerza el camino indicado.
> Los comandos `/updoc`, `/salud`, `/documentar` existen como standalone para auditoria manual.

## Workflows

---

### `version` — Versionado standalone

1. **META-PLAN (razonamiento)**
   - LEER `version.md` del disco
   - EJECUTAR /version Steps 1->5 (PLAN: detectar version, calcular bump, confirmacion)
   - ARMAR tabla (solo /version)
   - MOSTRAR CHANGELOG auto-generado + resultado pre-flight
   - PREGUNTAR UNA SOLA VEZ: "Versionar con estos cambios? [si/no]"
   - SI no confirma: DETENER workflow

2. **BUILD (ejecucion)**
   - /version BUILD* Steps 6->12 (CHANGELOG + commit + tag + --push. No preguntar - ya confirmado en Meta-PLAN)

3. **SUGERIR /salud**
   - Preguntar: "Ejecutar diagnostico post-versionado?"
   - SI si: EJECUTAR `/salud` (diagnostico + status-salud.md)
   - SI no: workflow terminado

---

### `commit` — Commit rapido (sin doc sync, sin version)

Para sesiones de codigo puro donde ningun documento cambio.

1. **EJECUCION DIRECTA** (sin Meta-PLAN)
   - EJECUTAR `/commit` (valida Conventional Commits y muestra diff)
   - Si `/commit` falla: DETENER y mostrar error. NO continuar.
   - Si no hay cambios: "No hay cambios para commitear" - DETENER

2. **PUSH**
   - Si $REPO definido: `git push origin $(git branch --show-current)` (push directo post-commit)
   - Si no: "Commiteado localmente. Ejecuta `git push <remote> <branch>` manualmente."

---

## Reglas del orquestador

1. Cada paso ejecuta el comando indicado leyendo su archivo .md desde `~/.config/opencode/commands/`
2. Los pasos marcados **BUILD\*** ejecutan solo escritura - PLAN y confirmacion se omiten
3. BUILD\* solo es valido cuando el Meta-PLAN ya cubrio los datos necesarios
4. El orquestador siempre muestra la tabla Meta-PLAN con divisiones por comando
5. `--yes` confirma automaticamente el Meta-PLAN (sin tabla ni pregunta)
6. Si un paso falla (commit no ejecutado, git status sucio): DETENER y reportar error
7. El Meta-PLAN ejecuta SIEMPRE en razonamiento; BUILD en ejecucion
8. Solo `/commit`, `/CBP` y `/version` pueden ejecutar git commit. Ningun otro comando debe commitear.
9. Si un comando en BUILD encuentra un estado ambiguo, DEBE pausar, presentar opciones, y esperar confirmacion.
10. En cualquier proyecto que NO sea Diligencia, el agente DEBE pausar antes de modificar estado del repositorio. Diligencia es la unica excepcion.
11. Si se edita un comando global (CBP.md, adaptar.md, etc.) que introduce cambios metodologicos, se DEBE inmediatamente bump version en adaptar.md + migracion + DILIGENCIA.md + CHANGELOG.md + commit.

## Validacion

- Los comandos individuales NO contienen su propio "Proximo paso en el circuito"
- /CBP es el unico punto de entrada para ejecucion multi-comando
- Cada comando puede ejecutarse standalone (sin /CBP) - pero no habra handoff automatico
- `/CBP` sin argumentos aplica deteccion adaptativa (commit/version)
- `/CBP` con argumento fuerza el camino indicado

## Anti-patrones

- NO modificar comandos individuales para que hagan handoff - el orquestador maneja el flujo
- NO ejecutar BUILD\* sin Meta-PLAN previo en el mismo workflow
- NO saltar pasos del workflow
- NO ejecutar Meta-PLAN en ejecucion (requiere razonamiento)
- NO ejecutar BUILD en razonamiento (desperdicio de tokens)
- NO leer "Proximo paso en el circuito" en comandos individuales - esa informacion esta obsoleta

## Archivos relacionados
- `~/.config/opencode/commands/version.md`
- `~/.config/opencode/commands/commit.md`
- `doc/mecanicas/MECANICA-CBP.md`
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9
