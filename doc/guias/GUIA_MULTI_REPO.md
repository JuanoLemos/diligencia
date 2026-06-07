# GUIA_MULTI_REPO — Patrones multi-repo y sincronización v1.0

Guía de patrones para proyectos que manejan múltiples repositorios.
No todos los proyectos necesitan multi-repo — elegir según la necesidad.

---

## Patrón 1: Worktree testing (dual local)

Un repo local de desarrollo + un worktree de testing.

```
dev/ (ediciones, commits) ─── sync vía git fetch ───→ test/ (detached HEAD, estable)
```

**Cuándo:** Sesión persistente (game), staging local, testing simultáneo.

**Referencia:** closefront → `MECANICA-WORKTREE.md`

---

## Patrón 2: Fork + upstream sync

Fork de un repo upstream. Sincronizar cambios del original.

```bash
git remote add upstream https://github.com/original/proyecto.git
git fetch upstream
git merge upstream/main
```

**Cuándo:** Proyecto basado en un fork (closefront es fork de OpenFront.io, WarFront.io).
**Mitigación:** Rebasar vs mergear según política del equipo.

---

## Patrón 3: Monorepo con submódulos

Un repo principal que incluye submódulos como dependencias.

```
proyecto/
  .gitmodules → submodulo1 = https://github.com/org/repo1.git
  src/submodulo1/
```

**Cuándo:** Dependencia desarrollada en paralelo con el proyecto principal.
**Ejemplo:** closefront usa submódulo `gatekeeper` (servidor web).
**Cuidado:** Los submódulos quedan en detached HEAD — hacer commit y push desde adentro.

```bash
git submodule update --init --recursive
git submodule foreach git pull origin main
```

---

## Patrón 4: CI/CD entre repos

Deploy desde un repo GitHub a un servidor remoto (no es multi-repo local, pero
el servidor remoto tiene otro repo).

**Flujo closefront:** GitHub → Hetzner via `deploy.sh` + `update.sh` via SSH.

```yaml
# .github/workflows/deploy.yml
- name: Deploy to Hetzner
  run: |
    scp update.sh user@host:~/app/
    ssh user@host "cd ~/app && bash update.sh"
```

**Cuándo:** Proyectos con servidores de staging/producción separados.

---

## Árbol de decisión

| Si tu proyecto... | Usá este patrón |
|---|---|
| Tiene sesión persisted y necesitás test sin parar (game, stream) | **Worktree testing** (Patrón 1) |
| Está basado en un fork de otro proyecto | **Fork + upstream** (Patrón 2) |
| Tiene dependencias propias que se desarrollan en paralelo | **Submódulos** (Patrón 3) |
| Necesitás deploy automático a servidores | **CI/CD deploy** (Patrón 4) |
| No encaja en ninguno | Usá un solo repo sin worktree |

---

## Archivos relacionados
- `MECANICA-WORKTREE.md` — setup y sync del worktree testing
- `.gitmodules` — configuración de submódulos (si aplica)
- `.github/workflows/deploy.yml` — CI/CD entre repos (si aplica)
- `templates/doc-base/HARNESS.md` — configuración de worktree en harness
