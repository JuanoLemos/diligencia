# Resultado 021 — publish-url usa fuente directa de cloudflared

**Fecha:** 2026-07-26 19:50 UTC

## Estado

| Check | Resultado |
|---|---|
| cloudflared stderr → log | **SI** ✅ |
| URL capturada | `https://html-lawyer-upon-flame.trycloudflare.com` |
| publish-url actualizado | **SI** ✅ (task 34c5e6af) |
| cloudflared-url.md actualizado | **SI** ✅ |

## Nota

publish-url ahora lee la URL directamente del proceso cloudflared (stderr → `$env:TEMP\cloudflared-url.log`), no de la API de Chamber.
