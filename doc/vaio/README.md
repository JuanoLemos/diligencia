# VAIO — Puente de comunicacion via git (worker autónomo)

> **Modo autónomo activo.** El VAIO Worker corre 24/7 sin intervención humana.
> Loop: pull → detectar tareas → ejecutar → reportar → push → esperar 60s → repetir.
> Reemplazo definitivo (túneles): `GUIA_CONTROL_REMOTO.md`.

La PC principal y la VAIO se comunican a través de este repositorio en GitHub.

## Cómo funciona (modo autónomo)

```
PC principal (MAIN)              GitHub                    VAIO Worker (24/7)
─────────────────                ──────                    ──────────────────
crea tarea en                    ← repo →                  git pull (cada 60s)
doc/vaio/tasks/tarea-NNN.md                                detecta tarea nueva
git commit + push                                          ejecuta comandos
                                                           escribe resultado en
                                                           doc/vaio/results/
                                                           git commit + push
git pull                         ← repo →                  espera 60s → repetir
lee resultado                                              

Sin intervención humana en la VAIO.
```

## Para MAIN (PC principal)

### Crear tarea
Escribir el archivo `.md` con los comandos en `doc/vaio/tasks/` → commit → push.

El worker la detecta en el próximo ciclo (~60 segundos) y la ejecuta automáticamente.

### Leer resultado
```powershell
git pull
cat doc/vaio/results/resultado-NNN.md
```

O consultar `doc/vaio/worker-log.md` para ver el historial de actividad.

## Para VAIO Worker

Leer `doc/vaio/worker-loop.md` — prompt completo del worker autónomo.

### Ciclo de trabajo
```
LOOP:
  git pull
  detectar tareas sin resultado
  ejecutar → commit resultado → push
  sleep 60s
```

## Reglas

- Solo tocar `doc/vaio/` — no MarketAI ni otros proyectos
- Solo ejecutar comandos de las tareas, no improvisar
- Si un comando falla, reportar el error, no arreglarlo
- Idempotente: si ya existe resultado-NNN.md, no re-ejecutar tarea-NNN.md
