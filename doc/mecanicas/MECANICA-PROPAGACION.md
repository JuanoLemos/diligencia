# MECANICA-PROPAGACION — Propagación de Diligencia a proyectos adaptados v1.0.0

Mecanismo semiautomático para propagar actualizaciones de la metodología Diligencia a los proyectos adaptados registrados en `$PROYECTOS`. Combina detección post-bump, reporte de versiones, notificación vía `UPDATE-AVAILABLE.md`, y actualización vía `/adaptar` Flujo C.

---

## Índice

| # | Sección | Contenido |
|---|---------|-----------|
| [§1](#1-arquitectura-del-flujo) | Arquitectura del flujo | Diagrama end-to-end |
| [§2](#2-version-post-bump) | /version post-bump | Paso 9 — detección automática |
| [§3](#3-propagar) | /propagar | Comando PLAN→BUILD |
| [§4](#4-update-availablemd) | UPDATE-AVAILABLE.md | Archivo de notificación |
| [§5](#5-propagacionesmd) | propagaciones.md | Log de auditoría |
| [§6](#6-proyectos-congelados) | Proyectos congelados | Exclusión automática |
| [§7](#7-integración-futura) | Integración futura | Con OpenChamber |

---

## 1. Arquitectura del flujo

```
┌─────────────────────────────────────────────────────────┐
│                 /version (Diligencia)                     │
│  Bump v2.0.0 → v2.1.0                                    │
│         │                                                 │
│         ▼                                                 │
│  Paso 9 — POST-BUMP                                       │
│  ┌──────────────────────────────────────────┐            │
│  │ Leer $PROYECTOS                           │            │
│  │ Comparar DILIGENCIA.md de cada proyecto   │            │
│  │ Mostrar minitabla de atrasados            │            │
│  │ Sugerir /propagar                         │            │
│  └──────────────┬───────────────────────────┘            │
│                 │ (si el usuario acepta)                  │
│                 ▼                                         │
│  ╔══════════════════════════════════════════╗            │
│  ║           /propagar                       ║            │
│  ║                                           ║            │
│  ║  PLAN                                     ║            │
│  ║  ┌──────────────────────────────────┐    ║            │
│  ║  │ Escanear $PROYECTOS              │    ║            │
│  ║  │ Comparar versiones               │    ║            │
│  ║  │ Excluir congelados (🧊)          │    ║            │
│  ║  │ Mostrar tabla                     │    ║            │
│  ║  └──────────────┬───────────────────┘    ║            │
│  ║                 │                         ║            │
│  ║  BUILD (por proyecto)                    ║            │
│  ║  ┌──────────────────────────────────┐    ║            │
│  ║  │ 1. Verificar WT clean             │    ║            │
│  ║  │ 2. Escribir UPDATE-AVAILABLE.md   │    ║            │
│  ║  │ 3. Preguntar /adaptar Flujo C     │    ║            │
│  ║  │ 4. Registrar en propagaciones.md  │    ║            │
│  ║  └──────────────────────────────────┘    ║            │
│  ╚══════════════════════════════════════════╝            │
│                                                           │
│  Resultado:                                               │
│  ┌──────────────────────────────────────────┐            │
│  │ UPDATE-AVAILABLE.md en cada proyecto     │            │
│  │ /adaptar Flujo C ejecutado               │            │
│  │ propagaciones.md actualizado              │            │
│  └──────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────┘
```

### Capas del mecanismo

| Capa | Componente | Rol |
|---|---|---|
| **Detección** | `/version` paso 9 | Dispara la alerta al versionar Diligencia |
| **Propagación** | `/propagar` | Ejecuta el escaneo y la propagación |
| **Notificación** | `UPDATE-AVAILABLE.md` | Archivo pasivo en cada proyecto |
| **Auditoría** | `propagaciones.md` | Log centralizado de operaciones |
| **Exclusión** | `catalogo-proyectos.md` | Bloquea proyectos congelados |

---

## 2. /version post-bump (paso 9)

### Cuándo se ejecuta

Solo cuando el proyecto que se versiona **es Diligencia** (detectado por el header de `DILIGENCIA.md`).

### Qué hace

1. Lee `$PROYECTOS` de `AGENTS.md`
2. Si no está configurado → "Saltando verificación de proyectos adaptados."
3. Por cada proyecto:
   - Lee su `DILIGENCIA.md` → extrae versión
   - Compara con la nueva versión de Diligencia
4. Si hay N proyectos atrasados:
   - Muestra minitabla: Proyecto | Versión | Atraso
   - Pregunta: "¿Ejecutar /propagar ahora?"

### Ejemplo de minitabla

```
⚠️ 3 proyectos adaptados usan versión anterior de Diligencia.

| Proyecto | Versión local | Diligencia | Atraso |
|---|---|---|---|
| +RM | v1.18.1 | v2.1.0 | 🟡 3 versiones |
| MarketAI | v1.18.1 | v2.1.0 | 🟡 3 versiones |
| conquisitare | v1.18.1 | v2.1.0 | 🟡 3 versiones |
```

### Estados posibles

| Comparación | Resultado |
|---|---|
| `proyecto < diligencia` | 🟡 Atrasado — necesita /propagar |
| `proyecto == diligencia` | 🟢 Al día |
| `proyecto > diligencia` | ⚠️ Proyecto adelantado (posible fork) |
| Sin `DILIGENCIA.md` | ❌ No adaptado |

---

## 3. /propagar (PLAN→BUILD)

Comando completo documentado en `.opencode/commands/propagar.md`.

### Argumentos

| Argumento | Efecto |
|---|---|
| *(sin args)* | Modo interactivo: tabla + confirmación por proyecto |
| `--dry-run` | Solo reporte, sin modificar archivos |
| `--notify` | Solo escribir `UPDATE-AVAILABLE.md`, sin `/adaptar` |

### PLAN — Escaneo

1. Leer versión actual de Diligencia (`DILIGENCIA.md`)
2. Leer `$PROYECTOS` de `AGENTS.md`
3. Por cada proyecto:
   - Verificar ruta existe
   - Leer `DILIGENCIA.md` → extraer versión
   - Comparar versiones
   - Verificar `git status --porcelain`
   - Consultar `catalogo-proyectos.md` para detectar 🧊
4. Mostrar tabla consolidada
5. Si `--dry-run` → detener

### BUILD — Propagación (por proyecto)

1. Si WT dirty → advertir y saltar
2. Escribir `UPDATE-AVAILABLE.md` en raíz
3. Si `--notify` → siguiente proyecto
4. Preguntar: "¿Ejecutar /adaptar Flujo C?"
5. Delegar a agentes SDD
6. Registrar en `propagaciones.md`

### Validaciones pre-propagación

| Check | Acción si falla |
|---|---|
| Ruta no existe | Marcar "❌ Ruta rota" |
| Sin `DILIGENCIA.md` | Marcar "❌ No adaptado" |
| WT dirty | ⚠️ Advertir, saltar |
| Proyecto congelado | 🧊 Excluir |
| Sin git | ⚠️ "Sin git", saltar |

---

## 4. UPDATE-AVAILABLE.md

### Propósito

Archivo pasivo escrito en la raíz de cada proyecto atrasado. Sirve como notificación persistente incluso si el usuario de ese proyecto no ejecutó `/version` o `/propagar` directamente.

### Formato

```markdown
# UPDATE AVAILABLE — Diligencia vX.Y.Z

Tu proyecto usa Diligencia vA.B.C.
Hay una nueva versión disponible: **vX.Y.Z**.

Ejecutá `/adaptar` para actualizar tu proyecto a la última versión de la metodología.

Fecha de detección: YYYY-MM-DD

## Archivos relacionados
- `DILIGENCIA.md` — versión actual del proyecto
- `doc/arch/status-salud.md` — salud del proyecto
```

### Comportamiento

- Se **sobrescribe** si ya existe (nueva versión disponible)
- Se **crea** si no existe
- **Nunca se borra** automáticamente — el proyecto lo elimina al actualizarse
- Puede ser usado por OpenChamber para mostrar badges de "Update Available"

---

## 5. propagaciones.md

### Propósito

Log centralizado en Diligencia que registra cada operación de propagación. Permite auditar qué proyectos fueron actualizados, cuándo, y con qué resultado.

### Formato

```markdown
# Propagaciones — Diligencia vX.Y.Z

| Fecha | Proyecto | Desde | Hasta | Resultado |
|-------|----------|-------|-------|-----------|
| 2026-06-26 | +RM | v1.18.1 | v2.1.0 | ✅ /adaptar Flujo C completado |
| 2026-06-26 | MarketAI | v1.18.1 | v2.1.0 | ⏭️ Saltado (WT dirty) |
```

### Estados de resultado

| Resultado | Significado |
|---|---|
| ✅ Completado | /adaptar Flujo C ejecutado sin errores |
| 📝 Notificado | Solo UPDATE-AVAILABLE.md escrito |
| ⏭️ Saltado | WT dirty / sin git / congelado |
| ❌ Error | Falló /adaptar o verificación |
| 🧊 Congelado | Excluido por catalogo-proyectos.md |

---

## 6. Proyectos congelados

### Detección

Los proyectos marcados como 🧊 **Congelado** o **Suspendido** en `doc/arch/catalogo-proyectos.md` se excluyen automáticamente de la propagación.

### Ejemplo en catalogo-proyectos.md

```markdown
| 7 | **closefront-io** | `C:\xampp\htdocs\closefront-io` | v1.17.4 | 🧊 Suspendido |
```

### Comportamiento

- `/propagar` los lista en la tabla pero no ofrece propagarlos
- Aparecen en el reporte como "🧊 Congelado"
- No reciben `UPDATE-AVAILABLE.md`
- No se les ejecuta `/adaptar`

### Descongelar

Para reactivar un proyecto, cambiar su estado en `catalogo-proyectos.md` de 🧊 a un estado activo. La próxima ejecución de `/propagar` lo incluirá.

---

## 7. Integración futura con OpenChamber

### Estado actual

La propagación es **manual** (vía `/propagar`) con detección **semiautomática** (vía `/version` paso 9). No hay integración con OpenChamber aún.

### Roadmap relacionado

| ID | Item | Estado |
|----|------|--------|
| R25 | openchamber hub: adaptación liviana | 🔴 Pendiente |
| R26 | integración con $PROYECTOS multi-proyecto visual | 🔴 Pendiente |
| R27 | dashboard visual de salud de proyectos | 🔴 Pendiente |
| R36 | dashboard Diligencia en Chamber React (cards por proyecto: versión, WT, salud, RM %) | 🔴 Pendiente |
| R41 | /news multi-proyecto — distribuir novedades a $PROYECTOS | 🔴 Pendiente |
| R44 | scheduled health checks automáticos cada N horas | 🔴 Pendiente |

### Visión

Cuando OpenChamber esté integrado:
- **Dashboard** mostrará badges de "v2.1.0 available" en proyectos atrasados
- **Scheduled tasks** ejecutarán `/propagar --dry-run` periódicamente
- **Notifications** alertarán al usuario cuando Diligencia versione
- **One-click update** desde la UI de Chamber ejecutará `/adaptar` Flujo C

---

## Anti-patrones

- NO propagar sin verificar `git status` — riesgo de sobrescribir trabajo no commiteado
- NO modificar proyectos congelados — pueden tener razones para estar en ese estado
- NO ejecutar /adaptar sin confirmación explícita por proyecto
- NO asumir que `$PROYECTOS` está configurado — verificar siempre
- NO hardcodear rutas de proyectos — usar `$PROYECTOS`

## Archivos relacionados
- `.opencode/commands/propagar.md` — comando `/propagar`
- `.opencode/commands/version.md` — paso 9 post-bump
- `.opencode/commands/adaptar.md` — Flujo C de actualización
- `doc/arch/propagaciones.md` — log de propagaciones ($PROPAGAR_LOG)
- `doc/arch/catalogo-proyectos.md` — catálogo con estados
- `AGENTS.md` — variables `$PROYECTOS`, `$PROPAGAR_LOG`
- `ROADMAP.md` — R48, R25-R30, R36, R41, R44
