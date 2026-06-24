# MECANICA-GRAPHIFY — Visualización de documentación como grafo v1.0

Usa [graphify](https://github.com/safishamsi/graphify) para generar un grafo de conocimiento
de la documentación de Diligencia. Muestra qué documentos se relacionan, qué conceptos son
centrales y qué conexiones existen entre guías, mecánicas y ADRs.

---

## Instalación

```bash
# Requisito: Python 3.10+
uv tool install graphifyy

# Alternativa (requiere pipx):
pipx install graphifyy
```

## Uso

```bash
# Dentro del proyecto Diligencia
graphify install --project --platform opencode
graphify .
```

Esto genera `graphify-out/` con tres archivos:
- `graph.html` — visual interactiva en el navegador
- `GRAPH_REPORT.md` — conceptos clave, conexiones sorprendentes
- `graph.json` — el grafo completo, consultable vía CLI

Para actualizar después de cambios:
```bash
graphify . --update
```

## Ignorar archivos

Crear `.graphifyignore` en la raíz (se hereda vía /adaptar en nuevos proyectos).

## Relación con Diligencia

graphify es una herramienta complementaria — no reemplaza INDEX.md ni /doctor.
Es una vista alternativa que muestra conexiones entre documentos que de otra forma
pasarían desapercibidas.

## Archivos relacionados
- `.graphifyignore` — archivos que graphify debe ignorar
- `INDEX.md` — catálogo central (complementario)
- `MECANICA-CONTEXTO.md` — modelo L0/L1/L2
