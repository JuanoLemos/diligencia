# GUIA_THEMES — Personalización visual de OpenCode v1.0

Guía para cambiar la apariencia de OpenCode y crear themes personalizados.

---

## 1. ¿Qué es un theme?

Un theme cambia los colores de la terminal OpenCode: fondo, textos, botones, paneles, syntax highlighting, diffs, y más. Todo es configurable.

Puede ser:
- **Built-in**: viene con OpenCode (13 temas incluidos)
- **System**: se adapta a los colores de tu terminal
- **Custom**: archivo JSON que vos definís

---

## 2. Cambiar de theme

### Por comando (en la TUI)

```
/theme
```

Abre un selector visual. Elegís con las flechas y Enter.

### Por configuración (tui.json)

```json
{
  "theme": "tokyonight"
}
```

Si no existe `~/.config/opencode/tui.json`, crealo.

---

## 3. Themes built-in

| Nombre | Descripción |
|---|---|
| `system` | Se adapta a tu terminal |
| `tokyonight` | Azul/violeta oscuro |
| `everforest` | Verde/beige suave |
| `ayu` | Naranja/gris moderno |
| `catppuccin` | Rosa/morado claro |
| `catppuccin-macchiato` | Rosa/morado medio |
| `gruvbox` | Amarillo/ocre retro |
| `kanagawa` | Azul/rojo tinta |
| `nord` | Azul/gris escandinavo |
| `matrix` | Verde sobre negro (hacker) |
| `one-dark` | Atom One Dark clásico |

Para verlos todos en acción: `/theme` → navegá con las flechas.

---

## 4. Crear un theme custom

Los themes son JSON con dos secciones:

```json
{
  "$schema": "https://opencode.ai/theme.json",
  "defs": {
    "miColor": "#ff6600"
  },
  "theme": {
    "primary": "miColor"
  }
}
```

### defs (opcional)

Define colores reutilizables. Cada entrada es un nombre y un color hex (`#ff6600`), ANSI (`3`) o `"none"`.

### theme (requerido)

Mapea las variables visuales a tus colores. Soporta:

| Formato | Ejemplo | Efecto |
|---|---|---|
| Color fijo | `"#ff6600"` | Siempre ese color |
| Referencia | `"miColor"` | Usa el color de `defs` |
| Dark/light | `{"dark": "#000", "light": "#fff"}` | Distinto color según modo |
| Terminal default | `"none"` | Hereda el color de tu terminal |

### Variables principales

| Variable | Qué colorea |
|---|---|
| `primary` | Acento principal, enlaces |
| `secondary` | Secundario, íconos |
| `accent` | Highlight, foco |
| `background` | Fondo general |
| `backgroundPanel` | Fondo de paneles |
| `text` | Texto principal |
| `textMuted` | Texto secundario |
| `error` / `warning` / `success` / `info` | Estados |
| `diffAdded` / `diffRemoved` | Colores de diff |
| `syntax*` | Syntax highlighting |

---

## 5. Dónde se guardan

| Prioridad | Ruta | Alcance |
|---|---|---|
| 1 (último) | Built-in | Incorporados en OpenCode |
| 2 | `~/.config/opencode/themes/*.json` | Tu usuario, todos los proyectos |
| 3 | `<proyecto>/.opencode/themes/*.json` | Un proyecto específico |
| 4 (primero) | `.opencode/themes/*.json` | Directorio actual |

Si dos themes tienen el mismo nombre, gana el de mayor prioridad.

---

## 6. Diligencia themes

Diligencia incluye 5 themes en `templates/doc-base/.opencode/themes/`:

| Nombre | Estilo | Fondo | Acento | Ideal para |
|---|---|---|---|---|
| `diligencia` | Oscuro original | Azul profundo (#1a1b26) | Teal + naranja | Uso diario |
| `diligencia-claro` | Claro | Beige cálido (#faf8f5) | Azul + naranja | Lectura prolongada, salas iluminadas |
| `diligencia-pastel` | Pastel | Lavanda suave (#f5f0ff) | Lila + coral | Ambiente relajado, vista cansada |
| `diligencia-neon` | Neón | Casi negro (#0a0a0f) | Cian + rosa | Hackers, cyberpunk, contraste extremo |
| `diligencia-oscuro` | Oscuro v2 | Negro carbón (#0f0f12) | Ámbar + azul | AMOLED, bajo consumo |

Para usar uno en tu proyecto:

```bash
mkdir -p .opencode/themes
cp ~/.config/opencode/templates/doc-base/.opencode/themes/diligencia-claro.json .opencode/themes/
```

O ejecutá `/theme` y seleccioná el nombre (aparecen en la lista si están en `~/.config/opencode/themes/`).

---

## 7. Personalización avanzada

Para personalizar agentes, skills, plugins, MCP servers o permisos de OpenCode:

```
skill("customize-opencode")
```

Este skill da instrucciones detalladas para editar `opencode.json`, `opencode.jsonc`, archivos en `.opencode/` y `~/.config/opencode/`.

---

## Archivos relacionados
- `templates/doc-base/.opencode/themes/diligencia.json` — theme de ejemplo
- `GUIA_ONBOARDING.md §8` — primeros pasos con personalización visual
- `~/.config/opencode/tui.json` — archivo de configuración del TUI
- Skill `customize-opencode` — personalización completa de OpenCode
