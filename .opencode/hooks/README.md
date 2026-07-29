# Hooks de git — Diligencia

## Instalación

```powershell
# Desde la raíz del proyecto Diligencia
New-Item -ItemType Directory -Path ".git\hooks" -Force
Copy-Item -Path ".opencode\hooks\commit-msg" -Destination ".git\hooks\commit-msg"
```

## Hooks disponibles

| Hook | Disparador | Función |
|---|---|---|
| `commit-msg` | `git commit` | Valida mensaje contra R6 (versionado real) y R16 (evidencia) |

## Nota

Los hooks son advisory (WARNING, no bloquean). La disciplina final es del agente.
