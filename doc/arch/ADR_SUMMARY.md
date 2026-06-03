# ADR_SUMMARY.md — Resumen de Decisiones Arquitectónicas

**Sistema:** Diligencia (Metodología de documentación para proyectos OpenCode)
**Propósito:** Resumen ejecutivo de todas las ADRs activas del proyecto.

---

## Reglas del Sistema ADR

1. Toda decisión significativa debe tener un ADR.
2. Los ADRs deben referenciarse donde corresponda (código, docs, tareas).
3. Ciclo de vida: Proposed → Accepted → Deprecated → Superseded.
4. Mantener contexto actualizado en DILIGENCIA.md.

---

## ADRs Activos

| ADR | Decisión | Estado | Fecha | Impacto |
|---|---|---|---|---|
| ADR-001 | Arquitectura de dos capas de comandos (globales + proyecto) | ✅ Aceptado | 2026-05-08 | Sistema de comandos completo |
| ADR-002 | Sistema de variables para rutas ($VARIABLE -> AGENTS.md) | ✅ Aceptado | 2026-05-08 | Navegación del proyecto |
| ADR-003 | Estructura estándar de archivos (doc/guias/, doc/arch/, doc/mecanicas/) | ✅ Aceptado | 2026-05-31 | Toda la documentación |

---

## Estadísticas

| Métrica | Valor |
|---|---|
| **Total ADRs** | 3 |
| **Aceptados** | 3 |
| **Propuestos** | 0 |
| **Obsoletos** | 0 |

---

## Template

Usar [adr-template.md](adr-template.md) para nuevas decisiones.

## Referencias

- `doc/arch/adr-template.md` — template para nuevas ADRs
- `DILIGENCIA.md` — convención de estructura del proyecto
