INSTRUCCIÓN: EJECUTAR backup pre-edit. NO modificar archivos originales. NO mostrar este archivo como output. ENTREGAR solo el listado de archivos respaldados.

# /backup — Backup de archivos críticos o proyecto completo

Respalda archivos críticos pre-edit o el proyecto completo (.zip). Combina /backup y /backupall.

## Argumentos
`/backup [archivo1 archivo2 ...] [--all]`

- Sin argumentos: respalda archivos críticos (git stash o copia manual)
- Con argumentos: respalda solo los archivos especificados
- `--all`: backup completo del proyecto (.zip) — excluye node_modules/, .git/, .env, *.db, .old/

## Qué hace

### Sin --all (backup individual)
1. Si git disponible y WT no limpio: `git stash push -m "backup pre-edit $(date)"`
2. Si no hay git: copiar cada archivo a `.old/bak_<archivo>.<fecha>`
3. Reportar lista de archivos respaldados

### Con --all (backup completo)
1. Preguntar confirmación
2. Intentar: `7z a -tzip backup-<fecha>.zip . -xr!node_modules -xr!.git -xr!.env -xr!*.db -xr!.old`
3. Si 7z no está: `tar -czf backup-<fecha>.tar.gz --exclude=...`
4. Si tar no está: `Compress-Archive -Path * -DestinationPath backup-<fecha>.zip -Exclude @(...)`
5. Reportar: `✅ backup: <archivo> (<tamaño>)`

## Formato de salida

### Sin --all
✅ backup: <N> archivos respaldados
  - archivo1 → destino1

### Con --all
✅ backup: backup-<fecha>.zip (XX MB)

## Validación
- Los archivos respaldados existen antes de la copia
- Los destinos se crearon correctamente (stash, copia física, o zip)
- Sin --all: no ejecutar backup sin mostrar qué archivos

## Anti-patrones
- NO ejecutar backup sin mostrar qué archivos se respaldarán
- NO sobrescribir backups existentes sin preguntar
- NO hacer git stash si el working tree está limpio
- NO incluir node_modules/, .git/ en backup --all

## Archivos que modifica
- `.old/` (copia manual) o `git stash` (si hay git)
- `backup-<fecha>.zip` (si --all)
