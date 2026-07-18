# GUIA_CHAMBER_INSTALABLE — Chamber como app nativa Windows v1.0

> Para dejar de usar Chamber en modo dev y tenerla como app instalada con auto-update.

---

## Build del instalador

```powershell
cd C:\Users\jlemo\OneDrive\Desktop\openchamber
bun install
bun run electron:build
```

Esto ejecuta 4 pasos:
1. `build:web-assets` — compila la UI con Vite
2. `bundle:main` — empaqueta el main process con Bun
3. `rebuild:native` — recompila node-pty y better-sqlite3
4. `package` — electron-builder crea el .exe

**Output**: `packages/electron/dist/OpenChamber-X.Y.Z-win-x64.exe`

**Prerrequisitos**: Bun, Node >= 22, NSIS (`winget install NSIS.NSIS`).

---

## Instalacion

Ejecutar el .exe -> instalador one-click -> se instala en `%LOCALAPPDATA%\Programs\OpenChamber\`.

Crea acceso directo en el menu inicio. Sin wizard.

---

## Auto-update

La app empaquetada busca nuevas versiones en GitHub Releases.

- **Proveedor**: GitHub (`openchamber/openchamber`)
- **Comportamiento**: pregunta antes de descargar, instala al cerrar la app
- **Changelog**: `https://raw.githubusercontent.com/openchamber/openchamber/main/CHANGELOG.md`

Si no hay releases en ese repo, regenerar manualmente el .exe con `bun run electron:build`.

---

## Merge de upstream sin perder customizaciones

Chamber es un fork de `btriapitsyn/openchamber`. Para recibir updates del repo oficial sin perder los cambios custom de Diligencia:

```powershell
cd C:\Users\jlemo\OneDrive\Desktop\openchamber
git fetch upstream
git stash                    # guarda cambios locales
git merge upstream/main      # mergea lo nuevo
git stash pop                # restaura tus cambios
# resolver conflictos si los hay
bun run electron:build       # regenerar .exe con todo mergeado
```

---

## Archivos relacionados

- `openchamber/packages/electron/package.json` — config de electron-builder
- `openchamber/packages/electron/main.mjs` — logica de auto-update
