# Mutaciones — Némesis Detective → Diligencia

**Proyecto:** Némesis Detective
**Versión Diligencia heredada:** v4.2.2 (upgrade corrido el 2026-08-24)
**Fecha de la revisión:** 2026-08-24
**Origen:** Fase 2.6 del `/adaptar` de upgrade. Los tres hallazgos salieron de correr
`scripts/check-docs.js` y verificar cada aviso contra el disco: **los tres son fallos del
validador**, no problemas del proyecto. Son 3 causas distintas que producen 5 avisos (M6
solo ya genera 3). Un validador que avisa de cosas que
están bien entrena a ignorarlo, y entonces también se ignoran los avisos verdaderos.

| ID | Mutación | Tipo | Dónde | Estado |
|---|---|---|---|---|
| M6 | **`check-docs.js` no soporta anclas en las rutas de variables.** Hace `existsSync()` sobre el valor crudo, así que `ROADMAP.md#tecnico` se reporta como inexistente aunque `ROADMAP.md` esté ahí y la sección también. Cualquier proyecto que apunte una variable a una sección interna recibe el aviso. | Script del template | `scripts/check-docs.js` | Pendiente |
| M7 | **`extractTableValue()` asume un layout de tabla que ni el propio template cumple.** Devuelve `cols[2]` como si fuera la versión; en una tabla `\| archivo \| fecha \| versión \|` eso es la **fecha**, y el validador compara una fecha contra una versión. El `INDEX.md` del template tiene otro layout distinto todavía (`\| archivo \| \| \| descripción \|`). | Script del template | `scripts/check-docs.js` | Pendiente |
| M8 | **El parser de CHANGELOG asume Keep-a-Changelog y falla en silencio útil.** Busca `## [X.Y.Z]`; un proyecto con otro formato recibe *"Could not determine latest version"* en cada corrida, para siempre, sin decirle qué formato espera. | Script del template | `scripts/check-docs.js` | Pendiente |

---

## M6 — Anclas tratadas como parte del nombre de archivo

**Código** (`scripts/check-docs.js`, bloque de validación de variables):

```js
const path = m[2].trim().replace(/^`|`$/g, '');
// …filtros de URLs, números, placeholders…
const full = path.startsWith('~/') ? resolve(homedir(), path.slice(2)) : resolve(ROOT, path);
if (!existsSync(full)) warn(`$${m[1]} → ${path} does not exist`);
```

**Caso real en Némesis.** `CLAUDE.md` mapea tres variables a secciones del roadmap
consolidado:

```
| $RM_TX | `ROADMAP.md#tecnico` | Roadmap técnico |
| $RM_UI | `ROADMAP.md#ui`      | Roadmap UI |
| $RM_UX | `ROADMAP.md#ux`      | Roadmap UX |
```

Las tres secciones existen (`## Técnico` línea 108, `## UI` línea 676, `## UX` línea 1200) y
`ROADMAP.md` obviamente existe. El validador igual tira tres avisos.

**Fix sugerido:** separar el ancla antes de resolver, y —si se quiere ir más lejos— validar
que el heading exista:

```js
const [filePart, anchor] = path.split('#');
const full = resolve(ROOT, filePart);
if (!existsSync(full)) { warn(`$${m[1]} → ${filePart} does not exist`); continue; }
if (anchor) {
  const slugs = readFileSync(full, 'utf-8')
    .split('\n').filter(l => l.startsWith('#'))
    .map(l => l.replace(/^#+\s*/, '').toLowerCase()
               .normalize('NFD').replace(/[̀-ͯ]/g, '')   // tildes fuera
               .replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-'));
  if (!slugs.includes(anchor.toLowerCase())) warn(`$${m[1]} → ancla #${anchor} no existe en ${filePart}`);
}
```

La normalización de tildes importa: `## Técnico` produce el slug `tecnico`, que es
exactamente lo que Némesis escribió en `CLAUDE.md`. Sin ese paso, el fix cambiaría un falso
positivo por otro.

---

## M7 — La columna equivocada

**Código:**

```js
function extractTableValue(table, name) {
  const row = table.find(r => r.startsWith('|') && r.includes(name));
  if (!row) return null;
  const cols = row.split('|').map(c => c.trim());
  return cols[2] || null;
}
```

`split('|')` sobre `| A | B | C |` devuelve `['', 'A', 'B', 'C', '']`, así que `cols[2]` es
la **segunda** celda de datos.

| Layout | `cols[2]` cae en | Resultado |
|---|---|---|
| `\| archivo \| fecha \| versión \|` (Némesis) | fecha | compara `2026-08-24` contra `v4.2.2` → aviso eterno |
| `\| archivo \| \| \| descripción \|` (template) | celda vacía | `null` → el chequeo se saltea entero |

O sea: **con el layout del propio template el validador no valida nada**, y con un layout
razonable produce un falso positivo permanente. El aviso resultante además desorienta:

```
⚠️  INDEX.md reports DILIGENCIA.md 2026-08-24, but DILIGENCIA.md header says v4.2.2
```

Un aviso que confronta una fecha con una versión y suena a error de versión.

**Fix sugerido:** buscar la celda por encabezado de columna en vez de por posición fija —
localizar en la fila de títulos cuál se llama "Versión" y usar ese índice. Si el proyecto no
tiene columna de versión, no avisar: no hay nada que comparar. Alternativa mínima: fijar el
layout esperado en `MECANICA-CALIDAD.md` y hacer que el template lo cumpla, porque hoy no
lo cumple.

---

## M8 — Formato de CHANGELOG impuesto sin decirlo

```js
const match = changelog.match(/##\s*\[(\d+\.\d+\.\d+)\]/);
if (!latestTag) warn('Could not determine latest version from CHANGELOG.md');
```

Némesis usa un formato propio, declarado en la cabecera del archivo (`Formato: .mak`):

```
🔹 v3.17.0 — 2026-08-24 — Memoria de NÉMESIS
```

El validador no lo reconoce y avisa en cada corrida. El aviso no dice qué formato espera, así
que no es accionable: el usuario no puede saber si es un bug del script, un formato mal
escrito, o un archivo corrupto.

**Fix sugerido, en orden de preferencia:**

1. Aceptar varios patrones (`## [X.Y.Z]`, `## vX.Y.Z`, `🔹 vX.Y.Z`) — un semver al inicio de
   una línea de encabezado ya alcanza como señal.
2. Si no se reconoce ninguno, decir qué se buscaba:
   *"formato de CHANGELOG no reconocido — se esperaba `## [X.Y.Z]` al inicio de línea"*.
3. Si Diligencia quiere **imponer** Keep-a-Changelog, decirlo en `MECANICA-CALIDAD.md` y que
   `/adaptar` ofrezca migrar el archivo. Hoy no está escrito en ningún lado, pero el
   validador lo exige igual.

---

## Nota sobre el estado de las mutaciones anteriores

De la tanda del 2026-08-23, **M2 llegó a v4.2.2** (schema de 2 huellas en el lock) y este
proyecto ya corrió el upgrade: comparación de 4 vías sin conflictos, 1 archivo sincronizado
(`MECANICA-LOCK.md`, que era el único que seguía describiendo el esquema viejo), 4
conservados como override.

**M1 sigue pendiente y bloquea**: los dos chequeos nuevos del agente `circuito` (4b y 4c)
están aplicados en `~/.claude/agents/circuito.md` y anotados en `PENDING.md`, pero ninguna
versión de Diligencia los documenta. Vale la pena cerrarlo: en la sesión del 2026-08-24
apareció la **cuarta** instancia del patrón que 4c persigue — el escritorio del juego leía
`gs.npc_globales.nemesis.nombre`, un campo que no existe en ningún lado del backend, y
mostraba el literal de fallback desde siempre sin que nadie lo notara.

M3, M4 y M5 siguen pendientes.
