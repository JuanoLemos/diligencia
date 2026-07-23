# Resultado 016 — Chamber source clonado y runtime.js editable

**Fecha:** 2026-07-23 19:30:00 UTC

## Estado

| Acción | Resultado |
|---|---|
| Bun instalado | SI (v1.3.14) — pero crash: CPU sin AVX2 |
| OpenChamber clonado | SI — en `$HOME\openchamber` (commit b2f56950) |
| Dependencias instaladas | NO — Bun crash impide `bun install` |
| runtime.js fix aplicado | NO — Bun crash impide ejecución del script |
| Chamber corriendo desde source | NO — bloqueado por Bun crash |

## Notas

**Problema crítico:** Bun v1.3.14 hace panic con "Illegal instruction" en esta CPU (features: no_avx2). Es un bug conocido de Bun en CPUs antiguas sin soporte AVX2.

**Repositorio clonado correctamente** en `C:\Users\jlemo\openchamber` — commit b2f56950 "fix: include active root sessions in Recent sidebar".

**Posibles soluciones:**
1. Instalar Node.js como fallback y usar `npm install` / `npm run dev` en lugar de Bun
2. Usar versión anterior de Bun que soporte CPUs sin AVX2
3. Usar WSL con Node.js para correr Chamber

**Archivo runtime.js existe** en `packages\web\server\lib\scheduled-tasks\runtime.js` — pendiente de fix manual cuando Bun funcione.

## Siguiente paso recomendado

Instalar Node.js (LTS) como fallback, ejecutar `npm install` en el repo clonado, aplicar fix de runtime.js manualmente, y probar `npm run dev --port 57123`.
