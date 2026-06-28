# ADR_SUMMARY.md — Resumen de Decisiones Arquitectónicas v2.2.3

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
| ADR-004 | M6 — Chamber pertenece a Diligencia. Chamber no es un proyecto externo, es parte del dominio de Diligencia | ✅ Aceptado | 2026-06-27 | AGENTS.md, MANDATO.md, $CHAMBER variable |
| ADR-005 | Fusión de comandos 39→28: /bug+/incidente→/reportar, /checklist→/rm+/next, /salud→/doctor, /pushgh→/commit --push, /report→/estado, /backupall→/backup, /legal→/doctor, +guia/upguia/+mec/upmec→/doc | ✅ Aceptado | 2026-06-27 | AGENTS.md, COMANDOS.md, CBP.md |
| ADR-006 | /doctor renombrado a /salud por conflicto con comando nativo /doctor de OpenCode | ✅ Aceptado | 2026-06-28 | salud.md, CBP.md, AGENTS.md, COMANDOS.md |

---

## Estadísticas

| Métrica | Valor |
|---|---|
| **Total ADRs** | 6 |
| **Aceptados** | 6 |
| **Propuestos** | 0 |
| **Obsoletos** | 0 |

---

## Template

Usar [adr-template.md](adr-template.md) para nuevas decisiones.

## Referencias

- `doc/arch/adr-template.md` — template para nuevas ADRs
- `DILIGENCIA.md` — convención de estructura del proyecto

## Archivos relacionados
- `doc/arch/ADR-001.md` — decisión fundacional
- `doc/arch/ADR-002.md` — decisiones de estructura
- `doc/arch/ADR-003.md` — estructura estándar de documentación
- `doc/arch/ADR-004.md` — Chamber pertenece a Diligencia (M6)
- `doc/arch/ADR-005.md` — fusión de comandos 39→28
- `doc/arch/ADR-006.md` — /doctor→/salud por conflicto OpenCode
