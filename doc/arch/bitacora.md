# Bitácora — Índice de sesiones v1.0

Una línea por sesión de trabajo. **Append-only**: nunca se edita ni se borra una línea previa.
El detalle de cada sesión vive en `doc/arch/walkthrough/`.

Formato: `| Fecha | Comando | Tema | Walkthrough | Versión |`

---

| Fecha | Comando | Tema | Walkthrough | Versión |
|---|---|---|---|---|
| 2026-08-14 | `/CBP` | Adopción de 3 patrones de nsSkeleton: lock de sincronización, walkthrough por sesión, Definición de Hecho | [adopcion-patrones-skeleton](walkthrough/2026-08-14_1312_CBP_adopcion-patrones-skeleton.md) | v4.2.0 |

---

## Cómo se usa

- La escribe `/CBP` durante BUILD, al cerrar una sesión (ver `MECANICA-CBP.md`).
- Es un **índice**, no un registro: 1 línea, sin detalle. El detalle va al walkthrough.
- Sesiones triviales (typo, formato, sin decisión de diseño) no generan entrada.

## Archivos relacionados
- `walkthrough/_template.md` — plantilla del detalle por sesión
- `MECANICA-CBP.md` — orquestador que genera las entradas
- `MECANICA-CALIDAD.md` — Definición de Hecho (el walkthrough es parte del DoD)
