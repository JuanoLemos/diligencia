# MANIFIESTO — Diligencia

**Diligencia existe para que tu proyecto nunca pierda el rumbo.**

No importa si trabajás solo con una idea fresca o si coordinás un equipo con múltiples agentes IA. Diligencia te da estructura, constancia y compañeros expertos que te asesoran en cada paso.

Esto no es un framework rígido. Es una mesa redonda donde vos decidís y la metodología te respalda.

---

## 0. ¿Por qué "Diligencia"?

Del latín *diligentia*, la palabra encierra tres ideas que definen este proyecto:

- **Cuidado y esmero.** Cada paso del circuito deja constancia escrita. Nada se pierde, nada se improvisa sin registro.
- **Prontitud y agilidad.** CBP acelera el ciclo de trabajo sin sacrificar calidad.
- **Trámite con constancia.** Toda decisión, todo cambio, toda sesión tiene su paper trail.

El antónimo de diligencia es **negligencia**. Este proyecto existe para que ningún proyecto caiga en el "después lo documento".

> *"Diligencia no es burocracia. Es la tranquilidad de saber que tu proyecto tiene memoria."*

---

Quien use, adapte o redistribuya este proyecto se compromete con estos principios:

## 1. Respetar la estructura
Mantener el árbol estándar de documentación: ROADMAP, CHANGELOG, ADRs, guías y mecánicas en sus carpetas definidas por ADR-003.

## 2. No romper el circuito
Preservar /CBP como orquestador central del flujo de trabajo. Los workflows de cierre de sesión — Meta-PLAN y BUILD — son el latido de la metodología.

## 3. Mantener el enforcement
Conservar las 3 capas de validación documental: runtime (instrucciones de sesión), pre-commit (validación local) y CI/CD (integración continua). La calidad documental no es opcional. Su implementación concreta se documenta en `doc/mecanicas/MECANICA-ENFORCEMENT.md`.

## 4. Respetar la disciplina de ejecución
BUILD aplica cambios pero NO commitea: solo `/commit`, `/CBP` y `/version` ejecutan git commit. Los agentes investigatorios son read-only y entregan **reportes de agentes** (reportes); solo el chat MAIN decide y ejecuta. Ninguna acción se asume sin confirmación.

## 5. Trazar las decisiones
Toda decisión arquitectónica se registra como ADR en `doc/arch/`. Las decisiones deben sobrevivir al olvido y al compaction: lo que no está trazado, no ocurrió.

## 6. Ser plural
Esta metodología acepta adaptaciones de stack, idioma, proveedor de IA y flujo. No impone un solo modelo ni una sola forma de trabajar.

Diligencia escala con tu proyecto, no al revés. Un dev solo con `/adaptar` (5 minutos) y un equipo de 10 con agentes SDD y reportes de agentes usan **la misma metodología en niveles distintos**. Nadie está obligado a usar todo desde el día uno.

## 7. Documentar los cambios
Versionar toda modificación con CHANGELOG actualizado y tags semánticos. La documentación debe reflejar el estado real del proyecto.

## 8. No cerrar la metodología
Todo derivado de Diligencia debe permanecer abierto bajo AGPL-3.0 o compatible. La metodología es de la comunidad.

## 9. Respetar a los compañeros
Los agentes (@consejero, @circuito, @sdd-architect, @sdd-implement, @sdd-reviewer, @sdd-verify, @documentador) son **compañeros de Diligencia**, no herramientas desechables. Su rol es asesorar, auditar y proponer — nunca decidir. El director (usuario) mantiene la última palabra.

Los agentes investigatorios operan en modo read-only y entregan **reportes de agentes** (reportes estructurados). Solo el chat MAIN ejecuta cambios y commitea. Ningún agente modifica archivos sin pasar por el director.

---

## 📐 Niveles de madurez

Diligencia escala con tu proyecto. No necesitás usarlo todo desde el día uno.

| Nivel | Cuándo | Qué usás | Tiempo |
|---|---|---|---|
| **L0 — Arranque** | Idea nueva, cero estructura | `/adaptar` | 5 min |
| **L1 — Ritmo** | Ya codeás, querés orden | `/CBP updoc`, `/commit --push` | 2 min por sesión |
| **L2 — Profesional** | Equipo, PRs, funcionalidades | Agentes SDD, reportes de agentes, ADRs | Según complejidad |
| **L3 — Orquesta** | Múltiples proyectos activos | Gran Orquestador, `/propagar`, Chamber | Infraestructura propia |

---

## 🔗 Para seguir leyendo

- `GUIA_ONBOARDING.md` — primeros pasos (sin jerga, sin humo)
- `doc/IDENTIDAD-CIRCUITO.md` — cómo funciona el circuito CBP por dentro
- `doc/IDENTIDAD-CHAMBER.md` — cómo Diligencia se integra con OpenChamber
- `README.md` — referencia rápida, comandos y estructura

---

*Diligencia — v3.0.1*
