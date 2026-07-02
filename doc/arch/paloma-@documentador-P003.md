# 🕊️ Paloma P003 — @documentador: Manifiesto Diligencia

**Fecha:** 2026-06-28  
**Foco:** Identidad pública + preparación para refactor del MANIFIESTO.md  
**Contexto:** Pluralización del proyecto hacia público general con bajo conocimiento IA. Agentes = compañeros, no caballos.

---

## 📊 Hallazgos

| # | Categoría | Archivo | Hallazgo | Severidad | Acción sugerida |
|---|---|---|---|---|---|
| 1 | IDENTIDAD | `MANIFIESTO.md` | Existe (33 líneas, 8 principios) pero **no explica la etimología** de "Diligencia". El nombre es la pieza más potente de branding y está ausente del manifiesto. | P1 | Agregar sección §0 con etimología (`diligentia`: cuidado, prontitud, constancia escrita; antónimo: negligencia). Ver contenido cocinado abajo. |
| 2 | IDENTIDAD | `MANIFIESTO.md` | El tono es **contractual/formal** ("Quien use, adapte o redistribuya..."), no invita. Contrasta fuertemente con `GUIA_ONBOARDING.md` que abre con "Sin jerga, sin humo, sin suposiciones". | P1 | Reescribir apertura en tono de compañero. El manifiesto debe ser la versión "¿por qué existe esto?" del onboarding. Ver contenido cocinado abajo. |
| 3 | IDENTIDAD | `MANIFIESTO.md` | Principio #6 "Ser plural" menciona adaptabilidad pero **no desarrolla el concepto de pluralización** (llevar la metodología a muchos, no imponer una sola forma). | P2 | Expandir §6 con ejemplos concretos: "Un dev solo con `/adaptar` y un equipo de 10 con agentes SDD usan la misma metodología en niveles distintos." |
| 4 | IDENTIDAD | `MANIFIESTO.md` | **No menciona a los agentes como compañeros.** No hay principio sobre el modelo MAIN↔AGENTE ni sobre las palomas como canal de reporte. | P2 | Agregar principio: "Los agentes son compañeros, no herramientas. Asesoran, auditan, proponen. El director decide." |
| 5 | IDENTIDAD | `README.md:39` | "Diligencia está diseñada para **operadores y orquestadores de agentes IA**" — jerga pesada para el público general. Un novato no se identifica como "operador de agentes IA". | P2 | ```oldString → newString```: `Diligencia está diseñada para **operadores y orquestadores de agentes IA** que trabajan con OpenCode.` → `Diligencia está diseñada para **cualquier persona que quiera ordenar su proyecto con ayuda de IA**. Si usás OpenCode y querés dejar de perder tiempo buscando archivos o adivinando qué se hizo en la sesión anterior, Diligencia es para vos.` |
| 6 | IDENTIDAD | `README.md:8` | "Estructura estándar de documentación para proyectos OpenCode." → definición correcta pero **fría**. No transmite emoción ni propósito. | P2 | Agregar segunda línea con la promesa emocional: `Diligencia es una metodología **plural y gratuita** para mejorar la experiencia de desarrollo con agentes IA.` → `Diligencia existe para que tu proyecto nunca pierda el rumbo. Cada paso deja constancia, cada decisión se registra, cada sesión cierra con orden.` |
| 7 | IDENTIDAD | `README.md` | Falta sección **"Niveles de madurez"** (L0→L3). El lector no sabe si esto es demasiado para él o demasiado poco. | P2 | Agregar tabla L0-L3: `L0 = /adaptar (5 min), L1 = /CBP updoc (cierre de sesión), L2 = agentes SDD + palomas (equipo), L3 = orquesta multi-proyecto` |
| 8 | IDENTIDAD | Proyectos adaptados | Solo `+RM` menciona "Diligencia" en su README. MarketAI, conquisitare, buenobonitobarato, Nemesis, OpenMontage **no tienen ninguna mención** ni badge. | P3 | Agregar badge Diligencia + 1 línea en cada README: `📋 Estructurado con [Diligencia](https://github.com/JuanoLemos/diligencia) v2.2.0`. No es urgente pero suma visibilidad. |
| 9 | IDENTIDAD | Ningún archivo | **No existe explicación etimológica** de "Diligencia" en todo el proyecto. La palabra aparece 200+ veces como nombre propio pero nunca como concepto explicado. | P1 | Incluir en MANIFIESTO.md §0. Es la pieza faltante más importante. |
| 10 | IDENTIDAD | Ningún archivo | **No existe el concepto "compañeros de Diligencia"** para describir a los agentes. En `AGENTS.md` se listan como herramientas, en `MECANICA-CBP.md` como workers. | P2 | Decidir si formalizar el término "compañero" en AGENTS.md y MANIFIESTO.md, o mantener el lenguaje técnico actual. |
| 11 | LEGAL | `MANIFIESTO.md` | `README.md:95` referencia `MANIFIESTO.md` — el archivo existe, el enlace funciona. ✅ | — | OK |
| 12 | LEGAL | Raíz | `LICENSE`, `NOTICE`, `SECURITY.md`, `LICENSING.md` presentes. `LICENSE` es AGPL-3.0. `LICENSING.md` documenta cambio GPL→AGPL. `NOTICE` tiene atribución. ✅ | — | OK |
| 13 | ESTRUCTURA | `GUIA_ONBOARDING.md` | Es el **mejor documento del proyecto** para público nuevo. "Sin jerga, sin humo, sin suposiciones." Define OpenCode y Diligencia en español llano. La tabla "¿Qué hago si...?" es oro puro. | — | Este es el **tono de referencia** para el nuevo MANIFIESTO.md. |
| 14 | ESTRUCTURA | `GUIA_ONBOARDING.md` | La sección 6 referencia `GUIA_DE_USO.md`, `GUIA_DE_BUENAS_PRACTICAS.md`, `GUIA_REFERENCIA_RAPIDA.md` — todas existen. La sección 8 "Personalización visual" está después de la 6 "Siguientes pasos" (falta el 7). Numeración rota. | P3 | Renumerar: 6→7 (Siguientes pasos), 7→8 (Personalización visual). |
| 15 | DOCS INFO | `GUIA_DE_USO.md:9` | "Diligencia es una convención que define cómo se estructura la documentación de un proyecto OpenCode. Resuelve tres problemas..." — definición correcta pero **técnica**. Contrasta con el tono onboarding. | P3 | No es urgente cambiar. La guía de uso ES para quien ya decidió usarlo. |
| 16 | DOCS INFO | `GUIA_REFERENCIA_RAPIDA.md` | Referencia comandos deprecados: `/report`, `/bug`, `/incidente`, `/backupall`, `/apply`, `/checklist`, `/+mec`, `/+guia`. El usuario nuevo podría intentar usarlos. | P2 | Deprecar de la chuleta o marcar con `🚫 (deprecado → usar /reportar)`. |
| 17 | TRACKING | `ROADMAP.md:55` | R55 `@documentador` está como ✅ Completado, pero P001 es la primera paloma efectiva. Fue completado en estructura (el agente existe), no en ejecución (primera auditoría real). | P3 | OK — el item refiere a la creación del agente, no a su uso. |
| 18 | CONSISTENCIA | `MANIFIESTO.md` vs `IDENTIDAD-CIRCUITO.md` | El manifiesto tiene 8 principios abstractos. `IDENTIDAD-CIRCUITO.md` tiene secciones concretas: propósito, repo, ritual, no-tocar. Son complementarios pero no se referencian mutuamente. | P3 | Agregar enlace bidireccional: MANIFIESTO.md → "Ver IDENTIDAD-CIRCUITO.md para la implementación concreta del circuito" y viceversa. |

---

## 📊 Resumen

| Severidad | Cantidad |
|---|---|
| P1 | 3 |
| P2 | 7 |
| P3 | 5 |
| **Total hallazgos** | **15** |
| OK (sin acción) | 3 |

---

## 🧩 Fragmentos para el Manifiesto

Estos fragmentos YA existen en la documentación y comunican bien la identidad. Se pueden reutilizar:

**De `README.md:9`:**
> "Diligencia es una metodología **plural y gratuita** para mejorar la experiencia de desarrollo con agentes IA."

**De `GUIA_ONBOARDING.md:3`:**
> "Sin jerga, sin humo, sin suposiciones."

**De `GUIA_ONBOARDING.md:9-13`:**
> "No es magia: es un programa al que le hablás en español y te contesta cosas útiles. [...] No necesitás saber programar. Solo escribir y leer."

**De `IDENTIDAD-CIRCUITO.md:9`:**
> "Mantener la coherencia del circuito CBP"

**De `MANIFIESTO.md:23` (actual):**
> "Esta metodología acepta adaptaciones de stack, idioma, proveedor de IA y flujo. No impone un solo modelo ni una sola forma de trabajar."

---

## 📝 Contenido cocinado

### Para hallazgo #1 y #9 — Etimología (sección §0 del MANIFIESTO.md)

```markdown
## 0. ¿Por qué "Diligencia"?

Del latín *diligentia*, la palabra encierra tres ideas que definen este proyecto:

- **Cuidado y esmero.** Cada paso del circuito deja constancia escrita. Nada se pierde, nada se improvisa sin registro.
- **Prontitud y agilidad.** CBP acelera el ciclo de trabajo sin sacrificar calidad.
- **Trámite con constancia.** Toda decisión, todo cambio, toda sesión tiene su paper trail.

El antónimo de diligencia es **negligencia**. Este proyecto existe para que ningún proyecto caiga en el "después lo documento".

> *"Diligencia no es burocracia. Es la tranquilidad de saber que tu proyecto tiene memoria."*
```

### Para hallazgo #2 — Nueva apertura del MANIFIESTO.md

```markdown
# MANIFIESTO — Diligencia

**Diligencia existe para que tu proyecto nunca pierda el rumbo.**

No importa si trabajás solo con una idea fresca o si coordinás un equipo con múltiples agentes IA. Diligencia te da estructura, constancia y compañeros expertos que te asesoran en cada paso.

Esto no es un framework rígido. Es una mesa redonda donde vos decidís y la metodología te respalda.

Quien use, adapte o redistribuya este proyecto se compromete con estos principios:
```

### Para hallazgo #4 — Principio sobre agentes compañeros

```markdown
## 9. Respetar a los compañeros

Los agentes (@consejero, @circuito, @sdd-architect, @sdd-implement, @sdd-reviewer, @sdd-verify, @documentador) son compañeros de Diligencia, no herramientas desechables. Su rol es asesorar, auditar y proponer — nunca decidir. El director (usuario) mantiene la última palabra.

Los agentes investigatorios operan en modo read-only y entregan **palomas** (reportes estructurados). Solo el chat MAIN ejecuta cambios y commitea. Ningún agente modifica archivos sin pasar por el director.
```

### Para hallazgo #5 — README.md:39

```markdown
oldString: Diligencia está diseñada para **operadores y orquestadores de agentes IA** que trabajan con OpenCode.
newString: Diligencia está diseñada para **cualquier persona que quiera ordenar su proyecto con ayuda de IA**. Si usás OpenCode y querés dejar de perder tiempo buscando archivos o adivinando qué se hizo en la sesión anterior, Diligencia es para vos.
```

### Para hallazgo #6 — README.md:8-9 (promesa emocional)

```markdown
oldString: Estructura estándar de documentación para proyectos OpenCode.
Diligencia es una metodología **plural y gratuita** para mejorar la experiencia de desarrollo con agentes IA.

newString: Estructura estándar de documentación para proyectos OpenCode.
Diligencia existe para que tu proyecto tenga memoria. Cada paso deja constancia, cada decisión se registra, cada sesión cierra en orden. Sin burocracia, sin herramientas complejas, sin depender de un solo proveedor de IA.
```

### Para hallazgo #7 — Tabla de niveles L0→L3 (agregar en README.md después de "¿Para quién es Diligencia?")

```markdown
## Niveles de madurez

Diligencia escala con tu proyecto. No necesitás usarlo todo desde el día uno.

| Nivel | Cuándo | Qué usás | Tiempo |
|---|---|---|---|
| **L0 — Arranque** | Idea nueva, cero estructura | `/adaptar` | 5 min |
| **L1 — Ritmo** | Ya codeás, querés orden | `/CBP updoc`, `/commit --push` | 2 min por sesión |
| **L2 — Profesional** | Equipo, PRs, funcionalidades | Agentes SDD, palomas, ADRs | Según complejidad |
| **L3 — Orquesta** | Múltiples proyectos activos | Gran Orquestador, `/propagar`, Chamber | Infraestructura propia |
```

---

## 🎯 Lo que el Manifiesto DEBE contener

Basado en los gaps encontrados, el MANIFIESTO.md refactorizado debería cubrir:

1. ✨ **Etimología** — ¿por qué se llama Diligencia?
2. 🎯 **Propósito emocional** — ¿qué problema humano resuelve? (no técnico)
3. 🧭 **Modelo de trabajo** — director + compañeros (agentes) + circuito (CBP)
4. 📐 **Niveles de madurez** — L0 a L3, para que nadie se sienta abrumado
5. 🌍 **Pluralización** — esto es para cualquiera, con cualquier stack, cualquier IA
6. 📋 **Los 8 principios actuales** (mantener, pulir tono)
7. 🤝 **Principio de compañeros** — el modelo MAIN↔AGENTE y las palomas
8. 🔗 **Enlaces** — a `GUIA_ONBOARDING.md` (próximo paso natural), `IDENTIDAD-CIRCUITO.md`

---

## ✅ Recomendación final

**Diligencia está lista para un MANIFIESTO.md refactorizado.** El archivo ya existe con 8 principios sólidos. Lo que falta no es estructura sino **alma**: la etimología, el tono de compañero, la promesa emocional, y los niveles que le digan al novato "tranquilo, esto escala con vos".

**Prioridad de acción:**
1. P1: Reescribir MANIFIESTO.md con etimología + tono de compañero + niveles
2. P1: Actualizar README.md (promesa emocional, tabla L0-L3, audiencia sin jerga)
3. P2: Agregar badge Diligencia a los 5 proyectos adaptados que no lo tienen
4. P2: Limpiar comandos deprecados de GUIA_REFERENCIA_RAPIDA.md
5. P3: Corregir numeración de GUIA_ONBOARDING.md
