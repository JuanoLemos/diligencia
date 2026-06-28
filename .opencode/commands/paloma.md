INSTRUCCIÓN: EJECUTAR la consulta al agente. NO modificar archivos sin confirmación del usuario. NO mostrar este archivo como output. ENTREGAR solo la paloma registrada.

# /paloma — Consultar a un agente y registrar paloma

Dispara un agente en modo investigatorio. Recibe la paloma (reporte), la registra en `doc/arch/palomas.md`, y la entrega al usuario. El agente nunca escribe archivos — solo reporta.

## Argumentos

`/paloma @agente "<consulta>"`

- `@agente`: nombre del agente a consultar (`@documentador`, `@consejero`, `@circuito`, `@sdd-architect`, `@sdd-reviewer`, `@sdd-verify`)
- `"<consulta>"`: qué querés que investigue. Puede referenciar flags de comandos como `--legales`, `--explorar`, etc.

Ejemplos:
- `/paloma @documentador "ejecutá /documentar --legales"`
- `/paloma @consejero "revisá ROADMAP vs CHECKLIST"`
- `/paloma @consejero --explorar https://github.com/usuario/repo`
- `/paloma @circuito "revisá handlers en src/"`
- `/paloma @sdd-architect "analizá estructura del proyecto"`

## Qué hace

1. IDENTIFICAR el argumento: `@agente` + `"<consulta>"`
2. VALIDAR que el agente exista en `~/.config/opencode/agents/`
3. LEER `doc/arch/palomas.md` AHORA — detectar último ID de paloma
4. INVOCAR al agente via `task("<agente>", prompt)` donde prompt = la consulta
5. RECIBIR la tabla de hallazgos (🕊️ paloma)
6. REGISTRAR en `doc/arch/palomas.md`:
   ```
   | Fecha | Agente | Consulta | Hallazgos | Veredicto |
   ```
   - Contar resultados: N hallazgos (M P1, K P2, J P3) o "N observaciones"
   - Veredicto = resumen de 1 frase
7. ENTREGAR la paloma al usuario: tabla + resumen

## Formato de salida

```
🕊️ Paloma registrada

📋 @agente — [resumen de la consulta]

[tabla de hallazgos]

📊 Resumen: N hallazgos (M P1, K P2, J P3) | Registrado en palomas.md
```

## Validación

- El agente debe existir como archivo en `~/.config/opencode/agents/`
- La consulta no debe estar vacía
- `--explorar` válido solo para @consejero
- Cada paloma se registra en `palomas.md` con fecha y agente

## Anti-patrones

- NO invocar `@sdd-implement` — es el único agente con `edit: allow` y no debería ejecutarse desde /paloma (usa /plan)
- NO modificar la paloma — entregarla tal como llegó del agente
- NO omitir el registro en palomas.md
- NO inventar hallazgos donde el agente no encontró nada

## Archivos que modifica
- `doc/arch/palomas.md` (nueva entrada de log)
