INSTRUCCIÓN: EJECUTAR las instrucciones de abajo. NO mostrar este archivo como output. NO modificar archivos sin confirmación del usuario.

# /reportar — Reportar bug o incidente

Registra un bug o incidente en el tracker correspondiente ($BUGS o $INCIDENTS) según el tipo. Crea el tracker desde template si no existe.

## Argumentos

`/reportar "<descripcion>" --tipo bug|incidente [--severidad P1|P2|P3] [--archivo "<ruta>"] [--stack "<stack>"]`

| Argumento | Requerido | Descripción |
|---|---|---|
| `<descripcion>` | Sí | Qué ocurre, en qué condiciones |
| `--tipo` | Sí | `bug` → tracker $BUGS (ID B-NN). `incidente` → tracker $INCIDENTS (ID I-NN) |
| `--archivo` | No | Archivo o módulo afectado (bugs) |
| `--stack` | No | Stack trace o log relevante (incidentes) |
| `--severidad` | No | P1 (crítico), P2 (importante), P3 (menor). Default: P2 |

## Qué hace

1. LEER `AGENTS.md` AHORA — buscar `$BUGS` y `$INCIDENTS`
2. Si `--tipo bug`:
   a. Si `$BUGS` no existe en AGENTS.md: PREGUNTAR si desea definirla como `doc/arch/bugs.md`
   b. Si el archivo no existe: CREARLO desde `~/.config/opencode/templates/doc-base/bugs.md`
   c. LEER tracker → detectar último ID (B-NN)
   d. CREAR entrada: ID B-NN+1, archivo, severidad, descripción, causa (pendiente), impacto (pendiente), fix (—), estado Abierto
   e. ACTUALIZAR tabla Resumen en `$BUGS`
3. Si `--tipo incidente`:
   a. Si `$INCIDENTS` no existe en AGENTS.md: PREGUNTAR si desea definirla como `doc/arch/incidentes.md`
   b. Si el archivo no existe: CREARLO desde `~/.config/opencode/templates/doc-base/incidentes.md`
   c. LEER tracker → detectar último ID (I-NN)
   d. CREAR entrada: ID I-NN+1, fecha, severidad, descripción, stack trace, causa (pendiente), mitigación (pendiente), estado Abierto
   e. ACTUALIZAR tabla Resumen en `$INCIDENTS`
4. AGREGAR entrada en `$CHECKLIST` AHORA
5. Entregar SOLO confirmación breve

## Formato de salida

**Reporte registrado**: B-NN / I-NN — <descripción>
**Tipo**: bug / incidente | **Severidad**: P1/P2/P3 | **Estado**: Abierto
**Tracker actualizado**: ✅ | **CHECKLIST actualizado**: ✅

## Validación

- Cada reporte tiene ID único auto-incremental (prefijo B- o I- según tipo)
- `--tipo` es obligatorio — sin él, preguntar
- El tracker se crea desde template si no existe
- Resumen y CHECKLIST se actualizan automáticamente

## Anti-patrones

- NO omitir `--tipo` — define a qué tracker va
- NO reusar IDs existentes
- NO modificar reportes existentes sin argumento explícito
- NO crear trackers sin preguntar si la variable no está definida
- NO registrar reportes sin descripción

## Archivos que lee

- `AGENTS.md` ($BUGS, $INCIDENTS)
- `$BUGS` o `$INCIDENTS` (tracker existente)
- `~/.config/opencode/templates/doc-base/bugs.md` o `incidentes.md` (template)

## Archivos que modifica

- `$BUGS` o `$INCIDENTS` (nueva entrada + resumen)
- `$CHECKLIST` (nueva entrada)
