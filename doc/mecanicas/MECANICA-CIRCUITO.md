# MECANICA-CIRCUITO — Circuito de trabajo cíclico v1.0

Define el flujo vinculante entre comandos del ecosistema. Cada comando, al completar su fase BUILD, debe sugerir el siguiente paso según las transiciones aquí definidas.
Referencia de hábitos de usuario: `GUIA_DE_BUENAS_PRACTICAS.md §9`.

---

## Diagrama del circuito

```
   SESSIONWORK
       │
       ▼
   /updoc PLAN → BUILD
       │ (vinculante: /version)
       ▼
   /version PLAN → BUILD
       │ (vinculante: /doctor)
       ▼
   /doctor PLAN → BUILD
       │
       ├── correcciones → /version patch PLAN → BUILD → SESSIONWORK
       └── sin correcciones ──────────────────────→ SESSIONWORK
```

## Estados y transiciones

| N° | Estado | Entry | Acción | Exit | Próximo vinculante |
|---|---|---|---|---|---|
| 1 | SESSIONWORK | Circuito inicia o reinicia tras BUILD completo | Usuario edita archivos, agrega RM items, modifica código | Working tree dirty o usuario solicita cierre | `/updoc` |
| 2 | `/updoc` | SESSIONWORK completo | Fases A→E→F: audita y sincroniza docs informativos | BUILD completo | `/version` (minor si no D5 stale, patch si D5 stale) |
| 3 | `/version` | `/updoc` BUILD completo | Detecta bump, CHANGELOG, INDEX, adaptar + template Diligencia, commit | BUILD + commit + git status limpio | `/doctor` |
| 4 | `/doctor` | `/version` BUILD completo | Fases 1→2→3: diagnóstico estructura, código, tracking, limpieza, deprecación | BUILD completo | `/version patch` si correcciones, SESSIONWORK si no |
| 5 | `/version` (patch) | `/doctor` con correcciones | Bump patch forzado, CHANGELOG, INDEX, commit | BUILD + commit + git status limpio | SESSIONWORK (circuito completo) |

## Contrato PLAN → BUILD

Cada paso del circuito cumple:

1. **PLAN**: leer, auditar, diagnosticar, calcular. NO modificar archivos.
2. **Mostrar plan al usuario**: tabla de hallazgos, cambios propuestos, impacto.
3. **Usuario confirma explícitamente** (sí).
4. **BUILD**: aplicar cambios. Modificar archivos solo aquí.
5. **Output**: resumen de lo aplicado + **próximo paso vinculante**.

## Vinculante

- "Vinculante" significa que el comando DEBE sugerir el siguiente paso al completar BUILD.
- El usuario puede rechazar la sugerencia (rompiendo el circuito), pero el agente no puede omitirla.
- Cada paso se ejecuta con su propio PLAN → BUILD — el agente nunca salta PLAN.

## Variantes del ciclo

| Escenario | Circuito |
|---|---|
| Sesión con muchas ediciones | sessionwork → /updoc → /version → /doctor → /version → sessionwork |
| Múltiples RM items en sessionwork | sessionwork (con RM items) → /updoc → /version → /doctor → /version → sessionwork |
| Ciclos doctor→version repetidos | sessionwork → /updoc → /version → /doctor → /version → /doctor → /version → sessionwork |
| /updoc tras varios ciclos | sessionwork → /doctor → /version → /doctor → /version → /updoc → /version → sessionwork |
| Sin cambios en working tree | No inicia circuito — salta directo a sessionwork o fin |

## Archivos que referencian esta mecánica

- `~/.config/opencode/commands/updoc.md` — sección "Próximo paso en el circuito"
- `~/.config/opencode/commands/version.md` — sección "Próximo paso en el circuito"
- `~/.config/opencode/commands/doctor.md` — sección "Próximo paso en el circuito"
- `doc/guias/GUIA_DE_BUENAS_PRACTICAS.md` §9 — diagrama de referencia
