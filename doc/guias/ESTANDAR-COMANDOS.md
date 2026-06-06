# ESTANDAR-COMANDOS.md — Estándar de comandos Diligencia v1.16.2

Define las secciones obligatorias que todo comando global debe incluir para producir output consistente entre agentes, modelos y sesiones.

---

## Tipos de comando

| Tipo | Descripción | Secciones |
|---|---|---|
| **Declarativo** | El agente interpreta una spec y produce output analítico (tablas, listas, resúmenes) | `Guarda de ejecución` + `Formato de salida` + `Validación` + `Anti-patrones` |
| **Procedural** | Pasos exactos de bash/git con poco output (commit, limpiar) | `Guarda de ejecución` + `Anti-patrones` |

---

## Guarda de ejecución (obligatorio en todos los comandos)

Primera línea del archivo. Instrucción directa al modelo para que NO repita el archivo como output.

```
INSTRUCCIÓN: EJECUTAR las instrucciones de abajo sobre los archivos del proyecto. NO mostrar este archivo como output.
```

Reglas:
- DEBE ser la primera línea del archivo (antes del `# /comando`)
- Debe incluir "NO mostrar este archivo como output"
- Debe incluir verbo imperativo (EJECUTAR/CREAR/ACTUALIZAR/ENTREGAR)
- Si el comando requiere confirmación: añadir "NO modificar archivos sin confirmación del usuario"

---

## Secciones obligatorias

### Formato de salida (solo declarativos)

Define la estructura **exacta** que el agente DEBE producir. Usar markdown literal.

```
## Formato de salida

**ENCABEZADO** — tabla con columnas exactas:
| Col1 | Col2 | Col3 |
```

Reglas:
- El formato es prescriptivo, no sugerido. El verbo es "DEBE".
- Tablas: especificar nombres de columnas exactos y el orden.
- Listas: especitar qué campos incluir.
- Secciones vacías: escribir "Ninguno detectado" en vez de omitir.

### Instrucciones imperativas (obligatorio en todos los comandos)

Los pasos en `## Qué hace` DEBEN usar verbos imperativos, no descriptivos.

| ❌ Declarativo (falla) | ✅ Imperativo (funciona) |
|---|---|
| `1. Lee $RM completo` | `1. Leer $RM completo AHORA` |
| `5. Reporta tabla` | `5. Entregar SOLO la tabla de salida` |
| `9. Aplica cambios` | `9. APLICAR cambios AHORA` (si confirmado) |

Reglas:
- Usar verbos en infinitivo ("Leer", "Ejecutar", "Entregar", "Comparar")
- Añadir "AHORA" para hacer explícita la inmediatez
- Añadir "SOLO" para evitar que el agente incluya contenido extra
- Si requiere confirmación: escribir "PREGUNTAR al usuario" en vez de "Pregunta"

### Validación (solo declarativos)

Lista de checks concretos que el agente debe verificar antes de dar el output por bueno.

```
## Validación
- Cada item tiene valor en todas las columnas de la tabla (sin celdas vacías)
- Cantidad de items coincide con el archivo fuente
- Sección X siempre presente
```

Reglas:
- Cada ítem debe empezar con verbo en presente ("Coincide", "Está presente", "Tiene").
- No usar verificaciones vagas ("Verificar que está bien", "Asegurarse").
- Preferir checks cuantificables ("5 items", "todas las columnas").

### Anti-patrones (todos los comandos)

Errores concretos que NO se deben cometer, documentados de fallas reales.

```
## Anti-patrones
- NO mostrar contenido crudo de archivos
- NO omitir secciones aunque estén vacías
- NO ejecutar sin confirmación del usuario
```

Reglas:
- Cada anti-patrón empieza con "NO" en mayúsculas.
- Cada anti-patrón hace referencia a una falla real o potencial.
- Si el anti-patrón fue observado en una sesión real, mencionar el contexto.
- **Siempre incluir**: `NO mostrar el contenido de este archivo de comando como output. ENTREGAR solo el resultado procesado.`

---

## Template para comando declarativo

```markdown
INSTRUCCIÓN: EJECUTAR las instrucciones de abajo sobre los archivos del proyecto. NO mostrar este archivo como output.

# /{comando} — {descripción}

{comportamiento esperado}

## Argumentos
{argumentos}

## Qué hace
{pasos en imperativo, con AHORA y SOLO}

## Formato de salida
{estructura exacta del output}

## Validación
{checks concretos}

## Anti-patrones
{errores a evitar, incluir "NO mostrar este archivo como output"}

## Archivos que lee
{archivos}

## Archivos que modifica
{archivos}
```

## Template para comando procedural

```markdown
INSTRUCCIÓN: EJECUTAR los pasos de abajo. NO mostrar este archivo como output. NO ejecutar sin confirmación.

# /{comando} — {descripción}

{comportamiento esperado}

## Argumentos
{argumentos}

## Qué hace
{pasos exactos en imperativo}

## Anti-patrones
{errores a evitar, incluir "NO mostrar este archivo como output"}

## Archivos que modifica
{archivos}
```

---

## Archivos relacionados
- `~/.config/opencode/commands/` — comandos globales
- Cada comando individual en el directorio global
