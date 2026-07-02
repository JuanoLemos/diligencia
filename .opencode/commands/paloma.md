INSTRUCCIÓN: EJECUTAR la consulta al agente. NO modificar archivos sin confirmación del usuario. NO mostrar este archivo como output. ENTREGAR solo la paloma registrada.

# /paloma — Consultar a un agente y registrar paloma

Dispara un agente en modo investigatorio. Recibe la paloma (reporte), la registra en `doc/arch/palomas.md`, y la entrega al usuario. El agente nunca escribe archivos — solo reporta.

**Se activa de diez formas:**
1. Comando explícito: `/paloma @agente "<consulta>"`
2. Invocación directa: `@agente` (mención en el chat MAIN sin el comando /paloma). El orquestador invoca al agente y registra la paloma igual que en la forma explícita.
3. Flag de novedades: `/paloma --news` (sin @agente) — consulta palomas pendientes y `paloma-main-plan.md` para el orquestador o agente separado.
4. Flag de nueva planificación: `/paloma --new @agente "<consulta>"` — crea una **paloma-plan** (borrador planificado con el usuario). Registra como 📝 Plan. Se convierte en paloma final vía `--publish`.
5. Flag aplicar: `/paloma --aplicar PNNN "resumen"` — cambia estado de 📬 Pendiente o 🟡 En revisión a ✅ Actuado. Registra la acción en columna "Acción MAIN".
6. Flag revisar: `/paloma --revisar PNNN` — cambia estado de 📬 Pendiente a 🟡 En revisión.
7. Flag archivar: `/paloma --archivar PNNN` — cambia estado de 📬 Pendiente o 🟡 En revisión a 🗑️ Ignorado.
8. Flag reabrir: `/paloma --reabrir PNNN` — cambia estado de ✅ Actuado o 🗑️ Ignorado a 📬 Pendiente.
9. Flag descartar: `/paloma --descartar PNNN` — cambia estado de 📝 Plan a 🗑️ Ignorado. Descarta una paloma-plan sin publicar.
10. Flag pendiente: `/paloma --pendiente PNNN` — cambia estado de 🟡 En revisión a 📬 Pendiente. Revierte una revisión.

## Argumentos

### Modo consulta
`/paloma @agente "<consulta>"`

- `@agente`: nombre del agente a consultar (`@documentador`, `@consejero`, `@circuito`, `@sdd-architect`, `@sdd-reviewer`, `@sdd-verify`)
- `"<consulta>"`: qué querés que investigue. Puede referenciar flags de comandos como `--legales`, `--explorar`, etc.

### Modo novedades
`/paloma --news`

Sin @agente. Lee `doc/arch/palomas.md` y `doc/arch/paloma-main-plan.md` y muestra las palomas 📬 Pendientes y las reglas MAIN→AGENTE activas. Tanto el orquestador como los agentes pueden usarlo.

### Modo nueva planificación
`/paloma --new @agente "<consulta>" [--detalle]`

Crea una **paloma-plan** (borrador planificado). El agente investiga, vos revisás, y cuando está OK se convierte en paloma final vía `--publish`.

- `--new`: crea el archivo `doc/arch/paloma-plan-PNNN.md` con la tabla de hallazgos
- `--detalle`: incluye contenido cocinado completo en el plan (vs resumen)
- El estado inicial es `📝 Plan` — no está lista para MAIN hasta que se publique

### Modo publicación
`/paloma --publish PNNN`

Convierte una `paloma-plan-PNNN.md` en paloma final `paloma-@AGENTE-PNNN.md`. Cambia el estado de `📝 Plan` a `📬 Pendiente` en `palomas.md`. La paloma queda lista para que MAIN evalúe y BUILDee.

Ejemplos:
- `/paloma @documentador "ejecutá /documentar --legales"`
- `/paloma @consejero "revisá ROADMAP vs CHECKLIST"`
- `/paloma @consejero --explorar https://github.com/usuario/repo`
- `/paloma @circuito "revisá handlers en src/"`
- `/paloma @sdd-architect "analizá estructura del proyecto"`
- `/paloma --news` — qué palomas están pendientes y qué reglas el MAIN comunicó
- `/paloma --new @documentador "auditá estructura"` — crea paloma-plan-P004.md (📝 Plan)
- `/paloma --new @documentador "auditá estructura y legal" --detalle` — plan con contenido cocinado completo
- `/paloma --publish P004` — convierte el plan P004 en paloma final (📝→📬)
- `/paloma --aplicar P004 "chamber: agregada variable $PALOMAS"` — marca como ✅ Actuado
- `/paloma --revisar P002` — cambia estado a 🟡 En revisión
- `/paloma --archivar P005 @consejero` — descarta paloma como 🗑️ Ignorado
- `/paloma --reabrir P001` — vuelve a poner en 📬 Pendiente
- `/paloma --descartar P005` — descarta una paloma-plan (📝→🗑️)
- `/paloma --pendiente P002` — revierte revisión (🟡→📬)

## Qué hace

### Modo --news
0. Si el argumento es `--news` (sin @agente):
   a. LEER `doc/arch/palomas.md` AHORA
   b. FILTRAR palomas con estado `📬 Pendiente` o `🟡 En revisión`:
      - Usar `Select-String -Path "doc/arch/palomas.md" -Pattern "\| P\d+ \|"` para extraer todas las filas de la tabla
      - Para cada fila, revisar si contiene "📬" o "🟡" en la columna Estado
      - Si no hay matches: "✅ No hay palomas pendientes."
   c. LEER `doc/arch/paloma-main-plan.md` AHORA:
      - Buscar el bloque `<!-- PALOMA-MAIN-PLAN:ACTIVE-RULES -->` hasta `<!-- /PALOMA-MAIN-PLAN:ACTIVE-RULES -->`
      - Extraer las reglas activas. Si el bloque no existe, reportar "📋 Sin reglas activas del MAIN."
   d. MOSTRAR tabla de palomas pendientes + reglas del MAIN
   e. Si no hay pendientes: ✅ "No hay palomas pendientes. Reglas MAIN→AGENTE al día."
   f. DETENER aquí (no invocar ningún agente)

### Modo consulta
1. IDENTIFICAR el argumento: `@agente` + `"<consulta>"`
2. VALIDAR que el agente exista en `~/.config/opencode/agents/`
3. LEER `doc/arch/palomas.md` AHORA — detectar último ID de paloma
4. INVOCAR al agente via `task("<agente>", prompt)` donde prompt = la consulta
5. RECIBIR la tabla de hallazgos (🕊️ paloma)
  6. REGISTRAR en `doc/arch/palomas.md`:
    ```
     | P### | Fecha | Agente | Consulta | Hallazgos | Archivos afectados | Estimación | Urgencia | Veredicto | Estado | Acción MAIN |
    ```
    - ID = `P` + número incremental (siguiente al último ID registrado, paso 3)
    - Estado inicial = `📬 Pendiente` (R6: MAIN decidirá si aplicar o ignorar)
    - Acción MAIN = `—` (pendiente de evaluar)
    - Contar resultados: N hallazgos (M P1, K P2, J P3) o "N observaciones"
    - Veredicto = resumen de 1 frase
    - Archivos afectados = lista de rutas de los archivos que se modificarían
    - Estimación = ⚡ / 🔧 / 🏗️ según tiempo estimado total de aplicar la paloma
    - Urgencia = 🚨 (antes de release) / ⏳ (este sprint) / 📅 (cuando haya tiempo)
  6.5. GUARDAR el contenido completo de la paloma en `doc/arch/paloma-AGENTE-PNNN.md`:
       - Nombre: `paloma-@AGENTE-P###.md` (ej: `paloma-@documentador-P003.md`)
       - Usar `doc/arch/paloma-template.md` como referencia de estructura:
         - Resumen ejecutivo obligatorio (1 párrafo)
         - Prioridad de acción ordenada por dependencia
         - Cocinado OBLIGATORIO para todo hallazgo P1
         - Checklist de aplicación para palomas con 5+ hallazgos
         - Riesgo de no actuar explícito
         - Metadatos: versión del proyecto (desde DILIGENCIA.md línea 1)
       - Contenido: la tabla de hallazgos COMPLETA + el resumen + el veredicto
       - Usar: `Set-Content -Path "doc/arch/paloma-AGENTE-P###.md" -Value $contenido`
       - Esto permite que el MAIN lea la paloma después, incluso si la tarea del agente expiró
 7. ENTREGAR la paloma al usuario: ID + tabla + resumen + estado

### Modo --new (planificación)

0. Si el argumento es `--new @agente "<consulta>"`:
   a. IDENTIFICAR `@agente` y `"<consulta>"` del argumento
   b. LEER `doc/arch/palomas.md` — detectar último ID de paloma
   c. CARGAR skill correspondiente al agente:
      - `@documentador` → `skill("diligencia-docs")`
      - `@consejero` → `skill("diligencia-consejo")`
      - `@circuito` → `skill("diligencia-circuito")`
   d. EJECUTAR los checks correspondientes según la skill
   e. GENERAR tabla de hallazgos con archivo, severidad, y acción sugerida
   f. Si `--detalle`: incluir contenido cocinado completo (archivos propuestos, diffs)
   g. ESCRIBIR `doc/arch/paloma-plan-PNNN.md`:
      - Nombre: `paloma-plan-PNNN.md` (NOTA: no lleva @agente — es un plan, no una paloma final)
      - Contenido: tabla completa + resumen + veredicto + (si --detalle) contenido cocinado
   h. REGISTRAR en `doc/arch/palomas.md`:
      - Estado inicial = `📝 Plan`
      - Acción MAIN = `—`
   i. ENTREGAR el plan al usuario: "🕊️ Paloma-plan PNNN creada. Revisala con `cat doc/arch/paloma-plan-PNNN.md`. Cuando esté OK, ejecutá `/paloma --publish PNNN` para convertirla en paloma final."

### Modo --publish (convertir plan en paloma final)

0. Si el argumento es `--publish PNNN`:
   a. VALIDAR que existe `doc/arch/paloma-plan-PNNN.md`
   b. LEER el archivo — extraer el agente y el contenido
   c. RENOMBRAR: `paloma-plan-PNNN.md` → `paloma-@AGENTE-PNNN.md`
   d. ACTUALIZAR `doc/arch/palomas.md`: cambiar estado de `📝 Plan` a `📬 Pendiente`
   e. ENTREGAR: "✅ Plan PNNN publicado como paloma-@AGENTE-PNNN.md (📬 Pendiente). Lista para MAIN."

### Modo --aplicar (marcar como actuado)

0. Si el argumento es `--aplicar PNNN "resumen"`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LEER `doc/arch/palomas.md` — localizar la línea `| PNNN |`
   c. REEMPLAZAR el estado en la fila: si es `📬 Pendiente` o `🟡 En revisión`, cambiar a `✅ Actuado`
   d. AGREGAR resumen en columna "Acción MAIN" (reemplazar `—` con el texto del argumento)
   e. ENTREGAR: "✅ PNNN marcado como Actuado."

### Modo --revisar (marcar en revisión)

0. Si el argumento es `--revisar PNNN`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LOCALIZAR la línea `| PNNN |`
   c. REEMPLAZAR estado `📬 Pendiente` → `🟡 En revisión`
   d. ENTREGAR: "🟡 PNNN en revisión."

### Modo --archivar (descartar paloma)

0. Si el argumento es `--archivar PNNN`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LOCALIZAR la línea `| PNNN |`
   c. REEMPLAZAR estado: `📬 Pendiente` o `🟡 En revisión` → `🗑️ Ignorado`
   d. ENTREGAR: "🗑️ PNNN archivado."

### Modo --reabrir (restaurar paloma archivada o actuada)

0. Si el argumento es `--reabrir PNNN`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LOCALIZAR la línea `| PNNN |`
   c. REEMPLAZAR estado: `✅ Actuado` o `🗑️ Ignorado` → `📬 Pendiente`
   d. LIMPIAR columna "Acción MAIN" (restaurar a `—`)
   e. ENTREGAR: "📬 PNNN reabierto como Pendiente."

### Modo --descartar (descartar paloma-plan)

0. Si el argumento es `--descartar PNNN`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LOCALIZAR la línea `| PNNN |`
   c. REEMPLAZAR estado `📝 Plan` → `🗑️ Ignorado`
   d. ENTREGAR: "🗑️ PNNN descartado."

### Modo --pendiente (revertir revisión)

0. Si el argumento es `--pendiente PNNN`:
   a. VALIDAR que `PNNN` existe en `doc/arch/palomas.md`
   b. LOCALIZAR la línea `| PNNN |`
   c. REEMPLAZAR estado `🟡 En revisión` → `📬 Pendiente`
   d. ENTREGAR: "📬 PNNN vuelto a Pendiente."

## Formato de salida

### Modo consulta (`@agente`)
```
🕊️ Paloma registrada — P###

📋 @agente — [resumen de la consulta]

[tabla de hallazgos]

📊 Resumen: N hallazgos (M P1, K P2, J P3) | Registrado en palomas.md como P### (📬 Pendiente)
```

### Modo novedades (`--news`)
```
📬 Palomas pendientes:
| ID | Fecha | Agente | Consulta | Hallazgos | Estado |
|---|---|---|---|---|---|
| P001 | ... | @documentador | /documentar | 3 hallazgos | 📬 Pendiente |

📋 Reglas MAIN→AGENTE activas:
[Reglas extraídas de paloma-main-plan.md]

✅ No hay palomas pendientes. (si corresponde)
```

### Modo nueva planificación (`--new`)
```
🕊️ Paloma-plan P004 creada

📋 Plan de @documentador — [resumen de la consulta]

[tabla de hallazgos]

📊 Resumen: N hallazgos (M P1, K P2, J P3) | Estado: 📝 Plan
📄 Archivo: doc/arch/paloma-plan-P004.md

Para publicarla: /paloma --publish P004
```

### Modo publicación (`--publish`)
```
✅ Plan P004 publicado como paloma-@documentador-P004.md (📬 Pendiente)
📄 archivos:
   doc/arch/paloma-plan-P004.md → doc/arch/paloma-@documentador-P004.md

## Validación

- El agente debe existir como archivo en `~/.config/opencode/agents/`
- La consulta no debe estar vacía
- `--explorar` válido solo para @consejero
- `--news` excluyente con `@agente` (no pueden combinarse)
- `--new` requiere `@agente` + `"<consulta>"`
- `--publish` requiere un número PNNN válido (debe existir `paloma-plan-PNNN.md`)
- `--aplicar` requiere PNNN + texto de resumen
- `--revisar`, `--archivar`, `--reabrir`, `--descartar`, `--pendiente` requieren PNNN
- `--new`, `--news`, `--publish`, `--aplicar`, `--revisar`, `--archivar`, `--reabrir`, `--descartar`, `--pendiente` son todos excluyentes entre sí
- Si `--news`: no invocar agentes, solo leer y mostrar
- Cada paloma se registra en `palomas.md` con fecha y agente

## Anti-patrones

- NO invocar `@sdd-implement` — es el único agente con `edit: allow` y no debería ejecutarse desde /paloma (usa /plan)
- NO modificar la paloma — entregarla tal como llegó del agente
- NO omitir el registro en palomas.md
- NO inventar hallazgos donde el agente no encontró nada

## Archivos que modifica
- `doc/arch/palomas.md` — nueva entrada de log o actualización de estado
- `doc/arch/paloma-AGENTE-PNNN.md` — creado en modo consulta (paso 6.5)
- `doc/arch/paloma-plan-PNNN.md` — creado en modo --new; renombrado en --publish
