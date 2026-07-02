# MECANICA-MEMORY — Memoria persistente entre sesiones v2.0

Tres subsistemas complementarios para persistencia de estado y contexto:

- **A — claude-mem**: persistencia de contexto de conversación del agente
- **B — MemoryManager**: persistencia de estado del sistema (hot/cold storage)
- **C — Delta**: comparación de snapshots entre ejecuciones

---

## §A — claude-mem (contexto de agente)

Usa [claude-mem](https://github.com/thedotmack/claude-mem) para capturar, comprimir
y reinyectar el contexto de sesiones anteriores automáticamente.

### Instalación

```bash
npx claude-mem install --ide opencode
```

### Flujo

1. Cada sesión: captura observaciones de las herramientas usadas
2. Al cerrar sesión: comprime las observaciones en memoria resumida
3. Nueva sesión: inyecta el contexto relevante automáticamente
4. Web UI: `http://localhost:37777` — visualización en tiempo real

---

## §B — MemoryManager (estado del sistema)

Patrón extraído de Crucix-master (`lib/delta/memory.mjs`). Persiste el estado
del sistema entre ejecuciones usando hot/cold storage con escritura atómica.

### Arquitectura

```
runsDir/
  memory/
    hot.json          ← hasta N runs recientes (MAX_HOT_RUNS, default 3)
    hot.json.bak      ← backup de la versión anterior
    cold/
      2026-07-01.json ← runs archivados por fecha
      2026-07-02.json
```

### Escritura atómica

```
1. writeFileSync(tmpPath)        → escribe a .tmp (si crashea, original intacto)
2. renameSync(hotPath → bakPath) → backup del archivo actual
3. renameSync(tmpPath → hotPath) → reemplazo atómico
4. Cleanup: unlinkSync(tmpPath)  si falla
```

### Carga con fallback

```
1. try hot.json → ok? usar
2. try hot.json.bak → ok? usar
3. ambos fallan → fresh start { runs: [], alertedSignals: {} }
```

### Alert cooldowns decay-based

```js
ALERT_DECAY_TIERS = [0, 6, 12, 24]  // horas

// 1er alert: sin cooldown
// 2do en 24h: 6h cooldown
// 3ro: 12h cooldown
// 4to+: 24h cooldown
```

- `isSignalSuppressed(signalKey)`: verifica si señal está en cooldown
- `markAsAlerted(signalKey)`: incrementa contador, actualiza timestamp

### Pruning automático

- Señales con 1 ocurrencia: purged after 24h
- Señales con 2+ ocurrencias: purged after 48h from last alert
- Previene acumulación infinita manteniendo awareness de señales recurrentes

### Compaction

Reduce datos pesados (arrays de logs, eventos, posts) a campos esenciales
antes de almacenar. Mantiene estructura suficiente para dedup y delta.

---

## §C — Delta (comparación de snapshots)

Patrón extraído de Crucix-master (`lib/delta/engine.mjs`). Compara dos
snapshots de estado y produce un reporte estructurado de cambios.

### Tipos de métrica

| Tipo | Descripción | Ejemplo |
|---|---|---|
| **Numérica** | Cambio porcentual con umbral configurable | VIX ±5%, Gold ±2% |
| **Conteo** | Cambio absoluto con umbral mínimo | posts ±2, eventos ±5 |

### Umbrales configurables

```js
DEFAULT_NUMERIC_THRESHOLDS = { vix: 5, gold: 2, wti: 3, ... }
DEFAULT_COUNT_THRESHOLDS  = { urgent_posts: 2, eventos: 5, ... }
```

### Jerarquía de severidad

| Multiplicador | Severidad |
|---|---|
| ×1 (umbral base) | moderate |
| ×2 | high |
| ×3+ | critical |

### Producto estructurado

```js
{
  timestamp,
  previous,
  signals: {
    new: [],          // señales que aparecieron
    escalated: [],    // señales existentes que empeoraron
    deescalated: [],  // señales existentes que mejoraron
    unchanged: []     // señales sin cambio significativo
  },
  summary: {
    totalChanges,
    criticalChanges,  // severidad critical
    direction,        // "mejorando" / "empeorando" / "mixto"
    signalBreakdown: { moderate: N, high: N, critical: N }
  }
}
```

### Null-safety

```js
if (!previous) return null; // primer run no produce delta
if (!current)  return null;
```

---

## Subsistemas A, B, C — tabla comparativa

| Dimensión | A — claude-mem | B — MemoryManager | C — Delta |
|---|---|---|---|
| **Qué persiste** | Contexto de conversación | Estado del sistema (snapshots) | Cambios entre snapshots |
| **Almacenamiento** | SQLite + vector DB | JSON (hot + cold) | En línea con cada snapshot |
| **Cuándo** | Por sesión | Por ejecución planificada | Post-ejecución |
| **Dependencias** | Node.js + Bun | Ninguna | Ninguna |
| **Gestión de vida** | Automática | Pruning por antigüedad + cooldown | Recalculado cada vez |
| **Caso de uso típico** | Agente recuerda sesiones pasadas | Dashboard guarda histórico de ejecuciones | Alerta cuando algo cambia significativamente |

Los tres son independientes y pueden coexistir. Un proyecto puede usar solo A
(contexto de agente), solo B+C (estado del sistema), o los tres.

## Archivos relacionados
- `PENDING.md` — registro de cambios globales
- `MECANICA-CONTEXTO.md` — modelo L0/L1/L2
- `MECANICA-LLM.md` — patrón multi-proveedor LLM
- `Crucix-master/lib/delta/memory.mjs` — implementación de referencia de B
- `Crucix-master/lib/delta/engine.mjs` — implementación de referencia de C
