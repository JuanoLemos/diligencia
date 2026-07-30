# Resultado 050 — Diagnostico de provider en opencode serve

**Fecha:** 2026-07-30
**Hostname:** Felrena

## Diagnostico

| Item | Estado | Detalle |
|---|---|---|
| `openchamber\managed-opencode` | Configurado | DeepSeek models favoritos (v4-flash, v4-pro) |
| `auth.json` | Existe | `sk-a8eda89b840b4516b5ede57a0d1958b8` — key presente |
| `DEEPSEEK_API_KEY` (env) | NO EXISTIA | Ni en proceso, User, ni Machine |
| `opencode serve` health | 200 OK | `{"healthy":true,"version":"1.18.3"}` |
| Agente via serve | FALLABA | `ProviderModelNotFoundError: opencode/deepseek-v4-flash` |

## Causas encontradas

1. **Falta `DEEPSEEK_API_KEY`**: La key existia en `auth.json` (usada por Chamber) pero no como variable de entorno, que es lo que `opencode serve` necesita.
2. **ProviderID incorrecto**: `invoke-agent-task.ps1` usaba `providerID = "opencode"`. El serve standalone no tiene ese provider — usa `providerID = "deepseek"` directo.

## Ver

- **Resultado 051** para la solucion aplicada.
