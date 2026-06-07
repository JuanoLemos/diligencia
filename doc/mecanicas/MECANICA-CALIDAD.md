# MECANICA-CALIDAD — Estándares de calidad documental v1.0

Define el formato, estilo y reglas de calidad para todos los documentos y templates Diligencia.

---

## 1. Estándar ROADMAP

### Formato de tabla

| ID | Item | Prioridad | Estado | Depende de |
|----|------|-----------|--------|------------|
| R01 | Título del item | P2 | 🔴 Pendiente | — |

### Reglas

- **IDs**: secuencia `R01`, `R02`, `R03`... Nunca reusar IDs de items completados.
- **Prioridad**: `P1` (crítico/milestone), `P2` (feature), `P3` (nice to have).
- **Secciones fijas**: `## Ahora (Now)`, `## Siguiente (Next)`, `## Futuro (Later)`, `## Completado`.
- **Máximo**: 3 items en Ahora. Sin límite en las demás secciones.
- **Dependencia**: opcional — ID de otro item que bloquea al actual.
- **Estados**: 🟡 En progreso / 🔴 Pendiente / ❌ Bloqueado / ✅ Completado.
- **Migración**: al completar, mover a Completado con `| Item | vX.Y.Z |`.

### Secciones

| Sección | Contenido |
|---|---|
| Ahora | Hasta 3 items activos. Solo lo que se está haciendo AHORA. |
| Siguiente | Items priorizados para después de Ahora. |
| Futuro | Ideas sin fecha estimada. |
| Completado | Items terminados. Cada versión tiene su bloque. |

## 2. Estándar de documentos

### Header

```
# NOMBRE — Descripción vX.Y.Z
```

- Primera línea: `# ` + nombre documento + ` — ` + descripción breve + ` vX.Y.Z`
- Fecha de última actualización en metadata (debajo del header si aplica)

### Catálogo (INDEX)

- Todos los documentos listados en INDEX.md con versión y fecha.
- INDEX se organiza por tipo: Docs críticos, Guías, Mecánicas, ADRs.

### Cross-references

- Al final de cada documento: `## Archivos relacionados` con lista de referencias.
- Links relativos entre docs (ej: `MECANICA-CBP.md`, no `doc/mecanicas/MECANICA-CBP.md` a menos que esté en otra sección).

### Fechas

- Formato ISO 8601: `YYYY-MM-DD`.
- Toda edición de un documento actualiza su fecha en INDEX.md.

## 3. Template conventions

### Placeholders

| Placeholder | Uso |
|---|---|
| `<NOMBRE_DEL_PROYECTO>` | Nombre del proyecto |
| `<FECHA>` | Fecha de creación/adaptación |
| `<AUTOR>` | Autor o mantenedor |
| `<AÑO>` | Año actual |
| `<TITULAR>` | Copyright holder |

- Los placeholders se reemplazan durante `/adaptar` Flujo A.
- NO hardcodear versiones de metodología en templates (solo en archivos reales).

### ADAPTAR comments

```markdown
<!-- ADAPTAR: instrucción para el agente al adaptar el template -->
```

Estos comentarios guían al agente `/adaptar` sobre qué reemplazar o personalizar en cada template.

## 4. Estilo markdown

- Tablas con columnas alineadas (`|---|---|---|`).
- Code blocks con triple backtick + lenguaje (````powershell`, ````json`, ````bash`).
- Links relativos entre archivos del proyecto.
- NO usar rutas absolutas (`C:\...`, `/home/...`) — usar variables de ruta (`$GUIAS`, `$MECANICAS`).
- Separadores `---` entre secciones principales.
- Versiones en headers de archivo, no en el cuerpo.

## 5. Autocheck de calidad

Cada documento debería cumplir:

- [ ] Header con nombre + descripción + versión (`# NOMBRE — Descripción vX.Y.Z`)
- [ ] INDEX: documento catalogado con versión y fecha
- [ ] Fecha en ISO 8601 (`YYYY-MM-DD`)
- [ ] Cross-references al final (`## Archivos relacionados`)
- [ ] Tablas con alineación de columnas
- [ ] Sin rutas absolutas (usar variables `$`)
- [ ] Sin hardcodeo de versiones de metodología (solo versión del documento)
- [ ] ADAPTAR comments si aplica (templates)

## Archivos relacionados
- `templates/doc-base/ROADMAP.md` — template estándar de ROADMAP
- `GUIA_DE_BUENAS_PRACTICAS.md §11` — referencia a calidad documental
- `MECANICA-DOCUMENTAL.md` — motor documental del sistema
