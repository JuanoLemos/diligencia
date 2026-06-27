INSTRUCCIÓN: EJECUTAR el commit. NO commitear sin confirmación. NO mostrar este archivo como output.

# /commit — Convencional Commits

Realiza un commit con validación de formato Conventional Commits.

## Argumentos
`/commit <tipo>[(<scope>)]: <descripción> [--push] [--auto]`

- `tipo`: feat, fix, docs, chore, refactor, test, style, perf, ci, build, revert
- `scope` opcional: módulo/área afectada (ej: api, ui, docs)
- `descripción`: presente imperativo, sin punto final
- `--push`: después del commit, hacer git push al remoto configurado en $REPO
- `--auto`: commitea sin pedir confirmación. Uso exclusivo: desde /version.

Ejemplos válidos:
- `/commit feat(api): add search endpoint`
- `/commit fix: resolve crash on empty input`
- `/commit docs(README): update installation steps --push`
- `/commit chore: bump deps --push`

## Qué hace
1. Valida que el mensaje siga el formato `tipo(scope): descripción` o `tipo: descripción`
2. Si no es válido: mostrar error con lista de tipos permitidos y DETENER
3. `git add -A`
4. Muestra diff resumido al usuario
5. Pregunta confirmación (saltar si --auto)
6. `git commit -m "<tipo(scope): descripción>"`
7. Muestra resultado
8. Si `--push`:
   a. LEER `$REPO` de AGENTS.md → si no definido: SKIP — "⚠️ $REPO no definido. Push omitido."
   b. VERIFICAR `git remote -v` → si no hay remote: SKIP — "⚠️ No hay remote. Push omitido."
   c. DETECTAR rama actual: `git branch --show-current`
   d. PREGUNTAR confirmación (saltar si --auto)
   e. EJECUTAR: `git push origin <rama>`
   f. MOSTRAR: "✅ Push exitoso a $REPO (rama: <rama>)"

## Validación
- `tipo` debe estar en la lista: feat, fix, docs, chore, refactor, test, style, perf, ci, build, revert
- Formato obligatorio: `tipo: descripción` o `tipo(scope): descripción`
- `BREAKING CHANGE` puede ir en el body del commit para indicar breaking change
- Si `--push`: $REPO debe estar definido en AGENTS.md o push se omite
- Si `--push`: verificar remote y WT limpio antes de push

## Anti-patrones
- NO commitear sin mostrar el diff al usuario primero
- NO commitear sin confirmación explícita del usuario
- NO hacer `git commit --amend` (reescribir historia) sin permiso explícito
- NO forzar push con `--force`
- NO commitear con mensaje sin formato Conventional Commits
- NO usar --auto desde sesión interactiva (solo /version)
- NO usar mayúscula inicial en la descripción
- NO usar punto final en la descripción
- NO omitir confirmación en push (saltar solo si --auto)

## Archivos que modifica
- Todos los cambios sin commitear
- (si --push) `$REPO` — remoto destino del push
