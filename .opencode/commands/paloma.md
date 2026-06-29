INSTRUCCIÓN: EJECUTAR la consulta al agente. NO modificar archivos sin confirmación del usuario. NO mostrar este archivo como output. ENTREGAR solo la paloma registrada.

# /paloma — Consultar a un agente y registrar paloma

Dispara un agente en modo investigatorio. Recibe la paloma (reporte), la registra en `doc/arch/palomas.md`, y la entrega al usuario. El agente nunca escribe archivos — solo reporta.

**Se activa de tres formas:**
1. Comando explícito: `/paloma @agente "<consulta>"`
2. Invocación directa: `@agente` (mención en el chat MAIN sin el comando /paloma). El orquestador invoca al agente y registra la paloma igual que en la forma explícita.
3. Flag de novedades: `/paloma --news` (sin @agente) — consulta palomas pendientes y `paloma-main-plan.md` para el orquestador o agentecho separado.

## Argumentos

### Modo consulta
`/paloma @agente "<consulta>"`

- `@agente`: nombre del agente a consultar (`@documentador`, `@consejero`, `@circuito`, `@sdd-architect`, `@sdd-reviewer`, `@sdd-verify`)
- `"<consulta>"`: qué querés que investigue. Puede referenciar flags de comandos como `--legales`, `--explorar`, etc.

### Modo novedades
`/paloma --news`

Sin @agente. Lee `doc/arch/palomas.md` y `doc/arch/paloma-main-plan.md` y muestra las palomas 📬 Pendientes y las reglas MAIN→AGENTE activas. Tanto el orquestador como los agentes pueden usarlo.

Ejemplos:
- `/paloma @documentador "ejecutá /documentar --legales"`
- `/paloma @consejero "revisá ROADMAP vs CHECKLIST"`
- `/paloma @consejero --explorar https://github.com/usuario/repo`
- `/paloma @circuito "revisá handlers en src/"`
- `/paloma @sdd-architect "analizá estructura del proyecto"`
- `/paloma --news` — qué palomas están pendientes y qué reglas el MAIN comunicó

## Qué hace

### Modo --news
0. Si el argumento es `--news` (sin @agente):
   a. LEER `doc/arch/palomas.md` AHORA
   b. FILTRAR palomas con estado `📬 Pendiente` o `🟡 En revisión`
   c. LEER `doc/arch/paloma-main-plan.md` AHORA — extraer reglas o directivas activas del MAIN hacia los agentes
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
    | P### | Fecha | Agente | Consulta | Hallazgos | Veredicto | Estado | Acción MAIN |
    ```
    - ID = `P` + número incremental (siguiente al último ID registrado, paso 3)
    - Estado inicial = `📬 Pendiente` (R6: MAIN decidirá si aplicar o ignorar)
    - Acción MAIN = `—` (pendiente de evaluar)
    - Contar resultados: N hallazgos (M P1, K P2, J P3) o "N observaciones"
    - Veredicto = resumen de 1 frase
 7. ENTREGAR la paloma al usuario: ID + tabla + resumen + estado

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

## Validación

- El agente debe existir como archivo en `~/.config/opencode/agents/`
- La consulta no debe estar vacía
- `--explorar` válido solo para @consejero
- `--news` excluyente con `@agente` (no pueden combinarse)
- Si `--news`: no invocar agentes, solo leer y mostrar
- Cada paloma se registra en `palomas.md` con fecha y agente

## Anti-patrones

- NO invocar `@sdd-implement` — es el único agente con `edit: allow` y no debería ejecutarse desde /paloma (usa /plan)
- NO modificar la paloma — entregarla tal como llegó del agente
- NO omitir el registro en palomas.md
- NO inventar hallazgos donde el agente no encontró nada

## Archivos que modifica
- `doc/arch/palomas.md` (nueva entrada de log)
