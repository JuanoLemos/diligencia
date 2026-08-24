# Bitácora — Índice de sesiones v1.0

Una línea por sesión de trabajo. **Append-only**: nunca se edita ni se borra una línea previa.
El detalle de cada sesión vive en `doc/arch/walkthrough/`.

Formato: `| Fecha | Comando | Tema | Walkthrough | Versión |`

---

| Fecha | Comando | Tema | Walkthrough | Versión |
|---|---|---|---|---|
| 2026-08-14 | `/CBP` | Adopción de 3 patrones de nsSkeleton: lock de sincronización, walkthrough por sesión, Definición de Hecho | [adopcion-patrones-skeleton](walkthrough/2026-08-14_1312_CBP_adopcion-patrones-skeleton.md) | v4.2.0 |
| 2026-08-14 | `/CBP` | Fix: `MECANICA-CALIDAD.md` era referencia colgada en los proyectos — pasa a canónica | [fix-calidad-referencia-colgada](walkthrough/2026-08-14_1406_CBP_fix-calidad-referencia-colgada.md) | v4.2.1 |
| 2026-08-23 | `/CBP` | Fix: bootstrap de `diligencia-lock.json` producía falsos positivos destructivos (mutación M2 de Nemesis) — schema de 2 huellas + `origen` | [fix-lock-bootstrap-M2](walkthrough/2026-08-23_2040_CBP_fix-lock-bootstrap-M2.md) | v4.2.2 |
| 2026-08-24 | `/CBP` | Documentar chequeos 4b/4c de `circuito` ya aplicados (mutación M1 de Nemesis) — cierra deuda de `PENDING.md` | [documentar-circuito-4b-4c-M1](walkthrough/2026-08-24_1233_CBP_documentar-circuito-4b-4c-M1.md) | v4.2.3 |
| 2026-08-24 | `/CBP` | Fix 3 bugs en `check-docs.js` — anclas, columna por nombre, formatos de CHANGELOG (M6/M7/M8 de Nemesis) | [fix-checkdocs-M6-M7-M8](walkthrough/2026-08-24_1251_CBP_fix-checkdocs-M6-M7-M8.md) | v4.2.4 |

---

## Cómo se usa

- La escribe `/CBP` durante BUILD, al cerrar una sesión (ver `MECANICA-CBP.md`).
- Es un **índice**, no un registro: 1 línea, sin detalle. El detalle va al walkthrough.
- Sesiones triviales (typo, formato, sin decisión de diseño) no generan entrada.

## Archivos relacionados
- `walkthrough/_template.md` — plantilla del detalle por sesión
- `MECANICA-CBP.md` — orquestador que genera las entradas
- `MECANICA-CALIDAD.md` — Definición de Hecho (el walkthrough es parte del DoD)
