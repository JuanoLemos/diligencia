# MECANICA-CONTEXTO — Carga de documentación por niveles v1.0

Define el modelo de contexto de Diligencia en tres niveles (L0/L1/L2).
Adaptado del paradigma de OpenViking: carga lo mínimo primero, profundiza solo cuando es necesario.

---

## Los tres niveles

| Nivel | Qué contiene | ~Tokens | Cuándo se carga |
|---|---|---|---|
| **L0** | Abstract — 1 línea que resume el documento. Permite decidir si leerlo sin abrirlo. | ~100 | Al listar documentos |
| **L1** | Overview — estructura, secciones, puntos clave. Permite entender de qué trata sin leerlo completo. | ~2K | Al navegar por un área |
| **L2** | Contenido completo — el archivo .md original. Lectura detallada. | Variable | Bajo demanda |

## Cómo se aplica en Diligencia

| Nivel | Dónde vive | Ejemplo |
|---|---|---|
| L0 | Columna "Resumen" en INDEX.md | "Guía de comandos — referencia de 40+ comandos globales" |
| L1 | Tabla de contenido de cada doc | `## Índice / ## 1 / ## 2 / ...` |
| L2 | El archivo .md completo | `GUIA_DE_COMANDOS.md` (500 líneas) |

## Beneficio

El agente (o el humano) puede navegar la documentación sin leer todo.
INDEX.md actúa como L1. La columna "Resumen" es L0. Los archivos .md completos son L2.

## Archivos relacionados
- `INDEX.md` — catálogo central con niveles L0 (columna Resumen) y L1 (secciones)
- `MECANICA-DOCUMENTAL.md` — motor documental del sistema
- `MANDATO.md` — mandatos MVP de Diligencia
