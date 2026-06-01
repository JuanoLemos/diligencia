# MECANICA-DOCUMENTAL — Motor documental de Diligencia

Define cómo interactúan los archivos de documentación, las variables y los comandos del sistema Diligencia para mantener coherencia entre sesiones, agentes y proyectos.

---

## Variables del motor

| Variable | Archivo | Rol |
|---|---|---|
| $RM | ROADMAP.md | Estrategia: Ahora / Siguiente / Futuro / Completado |
| $CHECKLIST | CHECKLIST.md | Tracking operativo: tareas tildables |
| $CHANGELOG | CHANGELOG.md | Historial versionado por release |
| $BUGS | doc/arch/bugs.md | Bug tracker: P1/P2/P3, severidad, estado |
| $INCIDENTS | doc/arch/incidentes.md | Incidentes runtime: stack, mitigación |
| $QA | doc/qa/ | Situaciones a revisar (archivos sueltos) |
| $HARNESS | .opencode/HARNESS.md | Config test/lint/skills/stack |
| $ADR | doc/arch/ | Decisiones de arquitectura (ADR-NNN.md) |

## Flujo documental

```
Editar docs
    ↓
/updoc (auditoría post-edición)
    ├── Clasifica cambios (CORE/ADR/GUIA/MECANICA/COMMAND)
    ├── Detecta gaps en $RM ↔ $CHECKLIST
    ├── Corrige stale data en $RM (Ahora → Completado)
    └── Reporta inconsistencias (duplicados, rutas viejas)
    ↓
/qa (si se detectó una situación)
    ↓
/version (cierre de sesión)
    ├── Bump de versión
    ├── Entrada en $CHANGELOG
    ├── /updoc final
    └── Commit versionado
```

## Tracking de bugs e incidentes

**/bug**:
1. Lee $BUGS y asigna ID auto (B-NN)
2. Crea entrada con severidad/archivo/descripción
3. Actualiza resumen tabular en bugs.md
4. Agrega entrada en $CHECKLIST

**/incidente**:
1. Lee $INCIDENTS y asigna ID auto (I-NN)
2. Crea entrada con fecha/stack/severidad/mitigación
3. Actualiza resumen tabular en incidentes.md
4. Agrega entrada en $CHECKLIST

Ambos son complementarios: bugs son defectos de código (P1/P2/P3), incidentes son eventos runtime (crash, anomalía).

## Sincronización

- `/updoc` garantiza que $RM y $CHECKLIST no divergen. Si un item aparece en $RM "Siguiente" y ya está tildado en $CHECKLIST, lo mueve a "Completado".
- `/version` ejecuta `/updoc` antes de commit, asegurando que el estado documental refleje los cambios recién hechos.
- `$CHECKLIST` es la fuente de verdad operativa; $RM es la fuente de verdad estratégica. Coinciden por `/updoc`.

## Anti-patrones documentales

- NO editar $RM sin tildar en $CHECKLIST (o viceversa) — rompe la sincronización.
- NO registrar bugs en $CHECKLIST sin crear la entrada en $BUGS — el tracker es la fuente.
- NO saltar `/updoc` antes de `/version` — genera gaps que se acumulan.
- NO tener $RM o $CHECKLIST sin $CHANGELOG — el historial de versiones es requisito.
