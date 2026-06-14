# Contribuir a Diligencia

Gracias por tu interés en contribuir. Este documento describe cómo participar.

---

## Reportar bugs o problemas

1. Abre un **Issue** en GitHub describiendo el problema
2. Incluye: versión de Diligencia, comportamiento esperado vs real, pasos para reproducir
3. Etiqueta sugerida: `bug`

## Proponer mejoras

1. Abre un **Issue** con la etiqueta `enhancement`
2. Describe el problema que resuelve y cómo lo abordarías
3. Si es un cambio grande, espera discusión antes de implementar

## Enviar Pull Requests

1. Haz fork del repositorio
2. Crea una rama: `git checkout -b feat/mi-cambio`
3. Aplica tus cambios siguiendo la metodología Diligencia
4. Asegúrate de que los tests de estructura pasen: el CI ejecuta `diligencia-check`
5. Commitea con formato Conventional Commits: `tipo(scope): mensaje`
6. Abre el PR contra `master`

### Convenciones de commit

| Tipo | Uso |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Cambios en documentación |
| `chore` | Mantenimiento, release |
| `refactor` | Cambio sin cambio de comportamiento |

## Estándares de código

- Markdown: `.markdownlint.json` en la raíz define las reglas
- Los archivos .md nuevos deben incluir header con versión de Diligencia
- Sigue la estructura definida en `doc/guias/_template.md` para guías nuevas

## Código de conducta

Este proyecto sigue un [Código de Conducta](CODE_OF_CONDUCT.md). Al participar, aceptas sus términos.

## Archivos relacionados
- `CODE_OF_CONDUCT.md` — código de conducta
- `README.md` — introducción al proyecto
