# PENDING — Registro de cambios globales pendientes v1.0

Mecánica del archivo `PENDING.md` en `~/.config/opencode/commands/`.
Sirve como registro de ediciones en comandos globales que aún no fueron documentadas en un bump de versión.

---

## Funcionamiento

Cada vez que se edita un comando global (CBP.md, adaptar.md, etc.) y no se hace un bump inmediato, se registra en PENDING.md:

| Fecha | Comando | Cambio |
|---|---|---|

El `/CBP` Paso 0f lee este archivo al inicio de cada invocación. Si hay entradas, avisa al usuario y ofrece hacer un bump para documentar los cambios.

Al ejecutar un bump (Paso 0f → BUILD), se limpia PENDING.md automáticamente.

## Archivos relacionados
- `CBP.md` — Paso 0f: lectura de PENDING.md
- `adaptar.md` — bump automático (limpia PENDING.md)

## Archivos relacionados
- $VARIABLE — descripción
