# MECANICA-MEMORY — Memoria persistente entre sesiones v1.0

Usa [claude-mem](https://github.com/thedotmack/claude-mem) para capturar, comprimir
y reinyectar el contexto de sesiones anteriores automáticamente.

Complementa el sistema PENDING.md (registro manual) con captura automática.

---

## Instalación

```bash
npx claude-mem install --ide opencode
```

Requisitos: Node.js 20+, Bun (se instala solo si falta).

## Cómo funciona

1. Cada sesión: claude-mem captura observaciones de las herramientas usadas
2. Al cerrar sesión: comprime las observaciones en memoria resumida
3. Nueva sesión: inyecta el contexto relevante automáticamente
4. Web UI: `http://localhost:37777` — visualización en tiempo real

## Relación con PENDING.md

| Aspecto | PENDING.md | claude-mem |
|---|---|---|
| Captura | Manual (registro del desarrollador) | Automática (hooks de sesión) |
| Almacenamiento | Archivo de texto plano | SQLite + vector DB |
| Contexto | Cambios globales sin versionar | Toda la actividad del agente |
| Dependencia | Ninguna | Node.js + Bun |

Ambos pueden coexistir. PENDING.md sigue siendo el mecanismo canónico para
rastrear cambios globales que requieren bump de versión. claude-mem agrega
persistencia de contexto general entre sesiones.

## Archivos relacionados
- `PENDING.md` — registro de cambios globales
- `MECANICA-CONTEXTO.md` — modelo L0/L1/L2
