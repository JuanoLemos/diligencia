# GUIA_PUENTE_VAIO — Comunicacion PC principal <-> VAIO via git v1.0

> ⚠️ DEPRECADO — Reemplazado por `GUIA_CONTROL_REMOTO.md`. Los archivos del puente se movieron a `.old/vaio-puente/`.
> `GUIA_VAIO_DNS.md` también está deprecada (<también reemplazada por GUIA_CONTROL_REMOTO.md>).

> Sistema de puente mientras se configuran los tuneles definitivos.
> La PC principal y la VAIO se comunican a traves de este repositorio en GitHub.

---

## Arquitectura

```
PC principal (MAIN)              GitHub                    VAIO
───────────────                  ──────                    ────
escribe tarea en                 ← repo →                  git pull
doc/vaio/tasks/tarea-NNN.md                                lee tarea
                                                           ejecuta comandos
git commit + push                ← repo →                  escribe resultado en
                                                           doc/vaio/results/
                                                           git commit + push
git pull                         ← repo →                  
lee resultado                                              

Ciclo completo: ~2 minutos (depende de internet)
```

---

## Para MAIN (PC principal)

### Crear tarea
```powershell
# 1. Escribir el archivo .md con los comandos
# 2. Commitear
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/tasks/
git commit -m "VAIO: tarea [descripcion]"
git push
```

### Leer resultado
```powershell
cd C:\xampp\htdocs\Diligencia
git pull
cat doc/vaio/results/resultado-NNN.md
```

---

## Para VAIO

Leer `doc/vaio/README.md` (instrucciones detalladas).

Resumen rapido:
```powershell
# Al iniciar
cd C:\xampp\htdocs\Diligencia
git pull
dir doc\vaio\tasks

# Ejecutar comandos de la tarea

# Al terminar
git add doc/vaio/results/
git commit -m "VAIO: resultado [tarea]"
git pull --rebase
git push
```

---

## Cuando los tuneles funcionen

Este sistema se depreca. Los tuneles definitivos son:

| Tunnel | Proposito |
|---|---|
| VS Code Remote Tunnels | Editar codigo, terminal, git |
| Cloudflare Tunnel | Chamber en el navegador |

---

## Archivos relacionados
- `doc/vaio/README.md` — instrucciones completas para VAIO
- `doc/vaio/tasks/` — tareas pendientes
- `doc/vaio/results/` — resultados completados
- `GUIA_VAIO_DNS.md` — guia rapida de reparacion DNS
- `GUIA_RED_LOCAL.md` — SSH y VS Code Remote en red local
