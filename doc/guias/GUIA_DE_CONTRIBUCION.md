# GUIA DE CONTRIBUCION — Diligencia v1.16.2

Cómo extender la metodología Diligencia: crear nuevas guías, mecánicas, comandos, ADRs y modificar templates.

---

## 1. Crear una nueva guía

Las guías documentan procedimientos, estándares y buenas prácticas para el usuario.

| Paso | Acción | Detalle |
|---|---|---|
| 1 | Elegir nombre | `KEBAB-CASE.md` — ej: `GUIA_DE_DEPLOY.md` |
| 2 | Usar template | Copiar `doc/guias/_template.md` |
| 3 | Header | `# TITULO — Diligencia vX.Y.Z` |
| 4 | Secciones | Numeradas: `## 1.`, `## 2.`, etc. |
| 5 | Separadores | `---` entre secciones |
| 6 | Cierre | `## Archivos relacionados` con referencias a `$VARIABLES` |
| 7 | Registrar | Añadir entrada en `INDEX.md` bajo Guías |
| 8 | Stale bump | Versión del header alineada con la versión actual de Diligencia |

Si la guía debe ser copiada a proyectos adaptados via `/adaptar`, agregarla a `~/.config/opencode/templates/doc-base/doc/guias/` y documentar en la mecánica de `/adaptar`.

---

## 2. Crear una nueva mecánica

Las mecánicas documentan reglas de negocio, flujos internos y comportamiento del sistema.

| Paso | Acción | Detalle |
|---|---|---|
| 1 | Elegir nombre | `KEBAB-CASE.md` en `doc/mecanicas/` |
| 2 | Header | `# TITULO — Diligencia vX.Y.Z` |
| 3 | Estructura | Índice opcional con tabla de links → secciones numeradas |
| 4 | Diagramas | ASCII bienvenidos para flujos |
| 5 | Separadores | `---` entre secciones |
| 6 | Registrar | Añadir entrada en `INDEX.md` bajo Mecánicas |
| 7 | Stale bump | Versión del header alineada |

No existe `_template.md` para mecánicas (a diferencia de guías). Usar `MECANICA-DOCUMENTAL.md` como referencia estructural.

---

## 3. Crear o modificar un comando

Los comandos viven en dos capas:

| Capa | Ubicación | Cuándo usar |
|---|---|---|
| Global | `~/.config/opencode/commands/` | Comando útil para cualquier proyecto adaptado |
| Local | `.opencode/commands/` | Comando específico del proyecto |

### Estructura de un comando

| Sección | Obligatoria | Descripción |
|---|---|---|
| Guarda de ejecución | ✅ | `INSTRUCCIÓN: EJECUTAR... NO mostrar este archivo como output.` |
| Descripción | ✅ | Qué hace el comando y cómo se usa |
| Formato | Para declarativos | Template de uso con argumentos |
| Validación | Para declarativos | Precondiciones y postcondiciones |
| Anti-patrones | ✅ | Qué evitar al usar el comando |

Después de crear/modificar un comando global: ejecutar `/adaptar` sobre los proyectos adaptados o copiar manualmente a cada `.opencode/commands/`.

---

## 4. Crear un ADR

Los ADRs documentan decisiones de arquitectura.

| Paso | Acción | Detalle |
|---|---|---|
| 1 | ID | Siguiente número correlativo: `ADR-{N+1}.md` |
| 2 | Template | Usar `doc/arch/adr-template.md` |
| 3 | Estado | `Proposed` inicialmente |
| 4 | Ciclo | `Proposed → Accepted → Deprecated → Superseded` |
| 5 | Categoría | Según ADR-003: A (estructura), B (herramientas), C (comandos), D (procesos) |
| 6 | Registrar | Añadir entrada en `ADR_SUMMARY.md` y `INDEX.md` |

---

## 5. Modificar templates

Templates en `~/.config/opencode/templates/doc-base/` definen la estructura inicial de proyectos adaptados via `/adaptar`.

| Template | Propósito |
|---|---|
| `DILIGENCIA.md` | Sello de metodología — debe reflejar la versión actual |
| `AGENTS.md` | Variables de ruta + comandos + sección Idioma |
| `HARNESS.md` | Config test/lint/skills |
| `CHECKLIST.md` | Checklist inicial |
| `CHANGELOG.md` | Historial versionado |
| `ROADMAP.md` | Roadmap inicial |
| `status-salud.md` | Reporte de salud (generado por /salud) |
| `scripts/check-docs.js` | Validación documental (enforcement capa 2) |
| `.github/workflows/diligencia-check.yml` | CI workflow |

### Reglas para modificar templates

1. **Compatibilidad**: el cambio no debe romper proyectos existentes adaptados con versiones anteriores
2. **Versionado**: si el cambio es rompiente, documentar en `adaptar.md` como migration entry
3. **Sincronización**: tras modificar un template, ejecutar `/CBP updoc` y verificar que el proyecto Diligencia refleje el cambio
4. **Placeholders**: los templates deben usar `$PLACEHOLDERS` (ej: `<NOMBRE_DEL_PROYECTO>`) que `/adaptar` reemplaza

---

## 6. Ciclo de vida de un cambio metodológico

```
Detectar necesidad
    ↓
Crear ADR (si el cambio es arquitectónico)
    ↓
Implementar cambio (guía, mecánica, comando, template)
    ↓
Actualizar INDEX.md, CHANGELOG.md
    ↓
Sync templates (si aplica a proyectos adaptados)
    ↓
/CBP updoc (sync documental + stale bump)
    ↓
/CBP version (bump + commit)
    ↓
/CBP doctor (post-verificación)
```

Para cambios grandes o arquitectónicos: usar flujo SDD completo (`@sdd-architect` → `@sdd-implement` → `@sdd-verify` → `@sdd-reviewer`).

---

## Archivos relacionados

- `doc/guias/_template.md` — plantilla para nuevas guías
- `doc/mecanicas/MECANICA-DOCUMENTAL.md` — referencia estructural de mecánicas
- `doc/arch/adr-template.md` — plantilla para ADRs
- `INDEX.md` — catálogo a actualizar tras cada nuevo documento
- `~/.config/opencode/templates/doc-base/` — templates que `/adaptar` copia a proyectos nuevos
