# MECANICA-WORKTREE — Worktree de testing dual-local v1.0

Mecánica del patrón dev-repo + testing-worktree usado por proyectos que necesitan
testing simultáneo sin interferencia. Basado en la implementación de closefront.

---

## 1. Patrón: dev repo → testing worktree

```
/dev-repo/ (principal)          /testing-worktree/ (worktree detached HEAD)
    │                                   │
    ├── git commit (cambios)            ├── npm run dev (servicio estable)
    ├── ediciones directas              ├── node_modules propios
    └── BUILD del agente               └── NUNCA se modifica manualmente

Sync: git fetch ../dev-repo main → git checkout <hash>
```

## 2. Setup inicial

Crear un worktree separado con un commit/tag fijo:

```powershell
# Desde el repo principal
cd C:\xampp\htdocs\closefront-io
git worktree add C:\xampp\htdocs\closefront-test v0.4.0

# En el worktree: node_modules independiente
cd C:\xampp\htdocs\closefront-test
npm install          # instala deps propias del tag
```

## 3. Sync del worktree

Para actualizar el worktree a una versión más nueva:

```powershell
cd C:\xampp\htdocs\closefront-test
git fetch ../closefront-io main
git checkout <nuevo-hash>
npm install          # solo si cambiaron deps
```

También puede hacerse via `git reset --hard FETCH_HEAD` (como en el tray de closefront).

## 4. Disciplina

- El worktree de testing **NUNCA** se modifica manualmente.
- Ediciones, commits y BUILD solo ocurren en el repo principal.
- Violar esta regla causa reinicio de partida/servicio (HMR/Vite detecta cambios).
- `node_modules`, `auth/*.db`, `package-lock.json` son independientes.

## 5. Automatización vía tray/script

closefront automatiza el sync con un botón "Update" en su tray manager:

```
scripts/tray/CloseFrontSrv.ps1 → git fetch → git reset --hard FETCH_HEAD
```

Para proyectos sin tray manager, se puede crear un script `sync-test.ps1`:

```powershell
cd C:\xampp\htdocs\testing-worktree
git fetch ../dev-repo main
git reset --hard FETCH_HEAD
npm install
Write-Output "Worktree actualizado a $(git log -1 --oneline HEAD)"
```

## 6. Cuándo usar este patrón

| Escenario | Recomendado |
|---|---|
| Game dev con sesión persistente (closefront) | ✅ |
| Proyecto con staging y producción locales | ✅ |
| Testing simultáneo de features en equipo | ✅ |
| Proyecto pequeño sin testing separado | ❌ (basta con git branch) |
| CI/CD externo disponible | ❌ (usar pipeline) |

## Archivos relacionados
- `GUIA_MULTI_REPO.md` — otros patrones multi-repo (fork, submódulos, CI/CD)
- `templates/doc-base/HARNESS.md` — configuración de worktree en harness
- `AGENTS.md §Worktree discipline` — reglas para el agente
