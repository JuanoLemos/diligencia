INSTRUCCIÓN: EJECUTAR las instrucciones de abajo. NO modificar archivos sin confirmación del usuario. NO mostrar este archivo como output.

# /doc — Crear o actualizar guías y mecánicas

Unifica los comandos /+guia, /upguia, /+mec, /upmec. Crea o actualiza documentos desde template según tipo (guía o mecánica) y acción.

## Argumentos

`/doc --tipo guia|mecanica <nombre> [--crear|--actualizar]`

- `--tipo`: `guia` → directorio `doc/guias/`. `mecanica` → directorio `doc/mecanicas/`.
- `<nombre>`: nombre del archivo sin extensión (ej: "MI-GUIA" → `doc/guias/MI-GUIA.md`).
- `--crear` (default): crea desde `~/.config/opencode/templates/doc-base/` si el template existe.
- `--actualizar`: actualiza un documento existente sincronizando encabezados desde el template.

## Qué hace

1. VALIDAR argumentos: `--tipo` es obligatorio
2. SI `--crear` (o default):
   a. DETERMINAR template base: `_template.md` en la carpeta destino (doc/guias/ o doc/mecanicas/)
   b. SI el archivo ya existe: preguntar "¿Sobrescribir?"
   c. SI no: crear desde template con `[nombre]` y fecha reemplazados
3. SI `--actualizar`:
   a. LEER documento existente
   b. COMPARAR header vs formato estándar
   c. Preguntar qué secciones sincronizar
4. REPORTAR SOLO: "✅ doc: <nombre> creado/actualizado en <ruta>"

## Formato de salida

✅ doc: <nombre> creado en <ruta>
📄 Template: <template>

## Validación
- --tipo es obligatorio y debe ser `guia` o `mecanica`
- El nombre no debe contener espacios ni caracteres especiales
- --actualizar solo funciona si el archivo existe

## Anti-patrones
- NO omitir --tipo — el comando no sabe a qué directorio escribir
- NO sobrescribir archivos sin preguntar
- NO mezclar guías y mecánicas en el mismo directorio

## Archivos que modifica
- `doc/guias/<nombre>.md` (si --tipo guia)
- `doc/mecanicas/<nombre>.md` (si --tipo mecanica)
