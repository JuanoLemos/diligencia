# GUIA_LEGAL — Buenas prácticas legales para proyectos v1.0

Guía para incorporar elementos legales mínimos en proyectos Diligencia.
Esto NO es asesoría legal — consultá con un abogado para decisiones específicas.

---

## 1. Elegir una licencia

| Licencia | Compatible con GPL-3.0 | Cuándo usarla |
|---|---|---|
| GPL-3.0 | ✅ | Proyectos que exigen copyleft fuerte |
| AGPL-3.0 | ✅ | Proyectos de red/servicio (closefront, SaaS) |
| Apache-2.0 | ✅ | Empresas que necesitan patentes explícitas |
| MIT | ✅ | Proyectos permisivos mínimos |
| BSD-2/3 | ✅ | Simplicidad, atribución requerida |
| Creative Commons | N/A | Assets, documentación (CC BY-SA 4.0) |

### Licencia dual

Algunos proyectos usan licencias separadas para código y assets:

```
Código:  GPL-3.0 / AGPL-3.0
Assets:  CC BY-SA 4.0 (/resources) + All Rights Reserved (/proprietary)
```

Ejemplo real: closefront tiene `LICENSE` (AGPL-3.0 + Section 7), `LICENSE-ASSETS` (CC BY-SA 4.0 + propietario), y `LICENSING.md` con historial completo de cambios de licencia.

---

## 2. LICENSE

- El archivo `LICENSE` debe estar en la raíz del proyecto.
- No modificar el texto estándar de la licencia.
- Si usás GPL/AGPL, incluir el texto completo (no solo un link).
- Si el proyecto tiene asset licensing separado, crear `LICENSE-ASSETS` adicional.

### package.json

Declarar la licencia en el campo `"license"`:

```json
{
  "license": "GPL-3.0-or-later"
}
```

Valores comunes: `MIT`, `Apache-2.0`, `GPL-3.0-or-later`, `AGPL-3.0-or-later`, `SEE LICENSE IN LICENSE` (para licencias no estándar).

---

## 3. Headers SPDX en código

Agregar un comentario de copyright al inicio de cada archivo fuente:

```typescript
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) <AÑO> <AUTOR>
```

Patrones por lenguaje:

| Lenguaje | Formato |
|---|---|
| JS/TS | `// SPDX-License-Identifier: ...` |
| Python | `# SPDX-License-Identifier: ...` |
| Go | `// SPDX-License-Identifier: ...` |
| C/C++ | `// SPDX-License-Identifier: ...` o `/* ... */` |
| Rust | `// SPDX-License-Identifier: ...` |
| HTML/CSS | `<!-- SPDX-License-Identifier: ... -->` |
| Markdown | `<!-- SPDX-License-Identifier: ... -->` |

SPDX identifiers permiten herramientas automáticas de compliance.

---

## 4. NOTICE

El archivo `NOTICE` (en la raíz) lista:

- Copyright holders del proyecto
- Dependencias third-party con sus licencias
- Cualquier atribución requerida por licencias de terceros

Formato sugerido (Apache-style):

```
# NOTICE — <PROYECTO>

Copyright (C) <AÑO> <TITULAR>

This product includes software developed by:
  - <dependencia> — <licencia>

Full license text: LICENSE
```

No es obligatorio, pero es buena práctica en proyectos con muchas dependencias.

---

## 5. SECURITY.md

El archivo `SECURITY.md` (en la raíz) define:

- Versiones soportadas (tabla)
- Cómo reportar vulnerabilidades (privadamente)
- Tiempo de respuesta esperado
- Política de divulgación

Es obligatorio para proyectos públicos en GitHub si se quiere habilitar
el Security Advisory feature. GitHub muestra este archivo automáticamente.

---

## 6. LICENSING.md (historial)

Para proyectos que cambiaron de licencia (como closefront), documentar:

1. Fechas y commits de cada cambio
2. Qué licencia aplicaba en cada fase
3. Qué partes del código están bajo cada licencia histórica
4. Copyright holders de cada fase

Formato sugerido: tabla timeline con fases numeradas.

---

## 7. Checklist legal mínimo

- [ ] `LICENSE` en raíz con texto completo
- [ ] `SECURITY.md` en raíz
- [ ] `NOTICE` en raíz (si hay dependencias third-party)
- [ ] `package.json` campo `"license"` declarado
- [ ] Headers SPDX en archivos fuente
- [ ] `LICENSING.md` (si el proyecto cambió de licencia)
- [ ] Assets licenciados separadamente si aplica
- [ ] GitHub Security Advisory configurado (público)

---

## 8. Disclaimer

Esta guía es informativa y no constituye asesoría legal.
Las leyes de copyright, licencias y propiedad intelectual varían según la jurisdicción.
Consultá con un abogado calificado antes de tomar decisiones legales sobre tu proyecto.

---

## Archivos relacionados
- `LICENSE` — texto de licencia GPL-3.0 (ver también `NOTICE`, `SECURITY.md`)
- `templates/doc-base/NOTICE` — template NOTICE
- `templates/doc-base/SECURITY.md` — template SECURITY.md
- `/legal` — comando para verificar cumplimiento legal
