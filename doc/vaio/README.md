# VAIO — Puente de comunicacion via git (temporal)

> Sistema de puente mientras se completa la configuracion de tuneles.
> Reemplazo definitivo: `GUIA_CONTROL_REMOTO.md`.

La PC principal y la VAIO se comunican a traves de este repositorio en GitHub.

## Como funciona

```
1. PC principal (MAIN) escribe tareas en doc/vaio/tasks/
2. git commit + push
3. En la VAIO: git pull
4. VAIO lee la tarea, ejecuta comandos
5. VAIO escribe resultado en doc/vaio/results/
6. git commit + push
7. PC principal: git pull -> lee resultado
```

## Para VAIO

### Al iniciar
```powershell
cd C:\xampp\htdocs\Diligencia
git pull
dir doc\vaio\tasks
```
Si hay archivos nuevos: abrirlos, ejecutar los comandos que piden.

### Al terminar
```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado [tarea]"
git pull --rebase
git push
```

## Reglas

- NO tocar archivos fuera de doc/vaio/
- NO tocar MarketAI ni otros proyectos
- SOLO ejecutar los comandos que pide la tarea
- Si un comando falla, escribir el error en el resultado (no intentar arreglarlo)
