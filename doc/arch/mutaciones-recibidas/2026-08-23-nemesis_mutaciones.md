# Mutaciones — Némesis Detective → Diligencia

**Proyecto:** Némesis Detective
**Versión Diligencia heredada:** v4.2.1
**Fecha de la revisión:** 2026-08-23
**Origen:** sesión de trabajo real (no auditoría teórica) — todos los hallazgos salieron de
bugs que costaron tiempo en el proyecto, no de leer la metodología.

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M1 | **Agente `circuito`: 2 puntos ciegos.** Detecta "función sin consumidor" pero no "función CON consumidor que igual falla siempre por permiso", ni "el prompt promete opciones que la UI no tiene". Ya aplicados como chequeos 4b y 4c en `~/.claude/agents/circuito.md` — falta versionar. | Agente global | `agents/circuito.md` | Pendiente |
| M2 | **El lock en modo bootstrap produce falsos positivos destructivos.** Un proyecto que genera su `diligencia-lock.json` por primera vez lo siembra con su estado ACTUAL, no con el del template. En la pasada siguiente `lock === actual` es trivialmente cierto, la Fase 2.5 lo lee como "nadie tocó el local" y propone **pisar overrides legítimos**. | Mecánica | `MECANICA-LOCK.md`, `adaptar.md` Fase 2.5 | Pendiente |
| M3 | **`PENDING.md` se leía pero nunca existió.** El pre-flight de `/CBP` (paso 0.f) lee `~/.claude/commands/PENDING.md` para detectar cambios globales sin versionar. El archivo no existía en la instalación, así que el mecanismo estaba inerte: se podían editar comandos globales sin que nada lo señalara. Creado en esta sesión. | Comando | `CBP.md` paso 0.f | Pendiente |
| M4 | **No hay chequeo de colisión de IDs.** En Némesis aparecieron dos features distintas bajo `D-08` y dos bajo `T-40`, más IDs `TER.XX` que no resolvían a nada. Nadie lo detecta hasta que alguien lee el roadmap con atención. Sugerido: chequeo en `/salud` que valide unicidad de IDs y que cada ID citado en el resumen tenga fila de detalle. | Comando | `salud.md` | Pendiente |
| M5 | **No hay chequeo de "pendiente ya resuelto por otro camino".** Dos ítems marcados 🔴 PENDIENTE ya estaban hechos bajo otro nombre. El roadmap arrastra ítems viejos y nadie los cierra cuando el trabajo se hace por otra vía. Sugerido: `/salud` compara los pendientes contra el código y marca los sospechosos. | Comando | `salud.md` | Pendiente |

---

## M1 — Detalle (el que motivó este envío)

El agente `circuito` encontró 8 problemas reales en Némesis, así que **funciona**. Pero dos
bugs que costaron tiempo se le escaparon, y comparten causa: **el agente lee código, y estos
problemas viven en la frontera** — entre el código y los permisos, y entre el código y el
texto que guía a la IA.

**4b — Permiso incompatible con el llamador.** Caso real: la ruta `POST /admin/bots/:id/error`
exigía rol `admin`, pero quien la llama es el bot (rol `bot`). Cada reporte recibía 403. El
llamador hacía `.catch(() => {})`, así que el rechazo se descartaba en silencio. La columna
en la base existía, la función que la escribe existía, el panel ya mostraba el badge — y
nunca se llenó. El chequeo 3 ("ruta sin consumidor") no lo ve porque **sí tiene consumidor**.

Señal a buscar: ruta con middleware de rol + llamador que se autentica con otro rol, y
`.catch()` vacío o falta de chequeo de `res.ok` que oculte el rechazo.

**4c — Promesas del prompt sin respaldo en la UI.** Caso real: el system prompt decía *"El
frontend ya muestra las opciones disponibles (NUEVO CASO · RECONFIGURAR · EXPORTAR DETECTIVE
· AGENDA · DOSSIER). No emitas menú textual en DESCANSO."* — y el frontend nunca las mostró.
Lo grave es la combinación: **el prompt suprime su propia alternativa**, así que el usuario
queda sin el menú del narrador *y* sin los botones. Callejón sin salida.

Este chequeo solo aplica a proyectos con prompts de IA, pero ahí es de alto valor: el prompt
es código ejecutable que nadie compila ni testea.

## M2 — Detalle (afecta a todo proyecto que adapte v4.2.0)

La tabla de decisión de Fase 2.5 dice:

> `lock = actual` y `lock ≠ template` ⟹ nadie tocó el local ⟹ **copiar del template**

Esa inferencia **asume que el lock se sembró desde el template**. En bootstrap se siembra
desde el proyecto, así que `lock = actual` es cierto por construcción y no prueba nada.

En Némesis eso propuso pisar `identidad.md` y `MANDATO.md` — que habrían vuelto a tener
`[Nombre del Sistema]` sin reemplazar — y `MECANICA-AUDIO.md`, que era **más nuevo** que el
del template. Se frenó a tiempo mirando el contenido, pero un `[sí/template]` distraído
revertía la adaptación entera.

**Fix aplicado localmente (esquema 2 del lock):** cada archivo guarda `sha256` (proyecto) **y
`template_sha256`** (el del template al momento de registrar), más `origen: template|override`
y el motivo del override. Con eso la pasada siguiente pregunta lo correcto — *¿cambió el
template desde que registré esto?* — en vez de *¿el proyecto difiere del template?*, que en
bootstrap siempre da que sí. Es retrocompatible: agrega campos, no saca ninguno.

Ver `diligencia-lock.json` de Némesis como referencia de formato.
