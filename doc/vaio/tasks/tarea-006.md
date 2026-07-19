# Tarea 006 — Activar Worker Loop autónomo (tarea final del puente)

> Ejecutar en la VAIO. Esta es la ÚLTIMA tarea manual. Al completarla, el worker toma el control.
>
> No tocar MarketAI ni otros proyectos.

## Objetivo

Transformar esta sesión de VAIO en un worker autónomo que monitorea tareas nuevas y las ejecuta sin intervención humana.

---

## Paso 1 — Leer el prompt del worker

```powershell
Get-Content doc\vaio\worker-loop.md
```

Leerlo completo. Este es tu nuevo "sistema operativo".

---

## Paso 2 — Activar el worker loop

A partir de este momento, esta sesión de OpenCode en la VAIO entra en modo **worker-loop**:

1. `git pull`
2. Detectar tareas pendientes (las que NO tienen resultado-NNN.md)
3. Ejecutar la tarea pendiente más antigua primero
4. Escribir resultado
5. Commit + push
6. Esperar 60 segundos
7. Repetir

---

## Paso 3 — Si la tarea 005 está pendiente

Si `doc/vaio/results/resultado-005.md` NO existe, ejecutar tarea 005 PRIMERO (error 1033 + servicio cloudflared). Luego seguir con el loop.

---

## Paso 4 — Escribir confirmación de activación

Crear `doc/vaio/results/worker-activado.md`:

```
# Worker Loop Activado

**Fecha:** [fecha/hora UTC]

El VAIO Worker está corriendo en modo autónomo.
- Ciclo: cada 60 segundos
- Scope: solo doc/vaio/
- Modo: ejecutar → reportar → esperar → repetir
- Log: doc/vaio/worker-log.md

Tareas pendientes detectadas al iniciar:
[tarea-005 pendiente / ninguna]
```

---

## Paso 5 — Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: worker loop activado"
git pull --rebase
git push
```

---

## A partir de ahora

Esta sesión NO termina. Cada 60 segundos:
1. `git pull`
2. Si hay tarea nueva en `doc/vaio/tasks/` sin resultado → ejecutarla
3. Escribir resultado → commit → push
4. Esperar 60s → repetir

El MAIN de Diligencia (PC Principal) se encarga de crear tareas y leer resultados.
