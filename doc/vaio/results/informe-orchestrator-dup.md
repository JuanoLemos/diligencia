# Informe — Diagnóstico y fix de orchestrator duplicado

**Fecha:** 2026-07-21 16:15 UTC
**Repo:** MarketAI

---

## Problema

Había **3 instancias** del orchestrator `--mode loop` corriendo simultáneamente:

| Hora | PIDs | CPU (min) | RAM (MB) | Origen |
|------|------|-----------|----------|--------|
| 4:09 AM | 43632+43684 | 3127 | 55 | Shell fantasma (huérfano) |
| 10:09 PM | 193208+193436 | 119 | 74 | PID 192556 (muerto) |
| 10:10 PM | 191420+190276 | 118 | 207 | Lanzado por tray_app.py |

**Consumo duplicado total:** ~3200 CPU-min, ~336 MB RAM desperdiciados.

---

## Causa raíz

`tray_app.py` solo monitoreaba su propio `_proc_orch`. Si alguien lanzaba un orchestrator desde terminal/VS Code, tray_app no lo detectaba y spawneaba otro propio.

---

## Fix aplicado

### 1. `orchestrator.py` — Lockfile anti-duplicado
Commit MarketAI: `a6df0fe`

- Antes de iniciar `--mode loop`, crea `.orchestrator.lock` con su PID
- Si el lockfile existe y el PID corresponde a un orchestrator vivo → sale sin arrancar
- Si el PID es huérfano (proceso muerto) → limpia lockfile stale y arranca
- Al salir, borra el lockfile automáticamente

### 2. `tray_app.py` — Orphan scan periódico
- Nueva función `_nuke_foreign_orchestrators()` en `auto_recover()`
- Cada 30s, mata cualquier orchestrator que no sea el propio
- Defensa en profundidad

---

## Estado actual

- ✅ 1 sola instancia del orchestrator (PID 69424→155964)
- ✅ 222 MB, controlada por tray_app
- ✅ Instancias huérfanas eliminadas

## Pendiente

- `.orchestrator.lock` se creará en el próximo reinicio del orchestrator
- Agregar `.orchestrator.lock` al `.gitignore` de MarketAI (opcional)
