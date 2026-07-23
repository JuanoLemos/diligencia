# Tarea 010 — Diagnosticar loop del worker + corregir bugs + nueva prueba

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.

## Diagnóstico — ¿Por qué el worker no hizo pull automático?

Ejecutar en orden:

### D1 — Último pull real

```powershell
cd C:\xampp\htdocs\Diligencia
git log --oneline -3
```

Anotar el último commit visible.

### D2 — Estado del worker (logs)

```powershell
cat doc\vaio\worker-log.md
```

Si está vacío o con 1 línea → el worker no actualiza el log. Eso es un síntoma de que el loop no se ejecuta correctamente.

### D3 — ¿Cloudflared causando restart loop?

```powershell
# Ver procesos cloudflared recientes
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
# Si hay más de 1, el watchdog está reiniciando sin control

# Ver cuándo arrancó cloudflared
(Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Sort-Object StartTime).StartTime
```

Si cloudflared arrancó hace segundos/minutos, el watchdog está haciendo restart loop.

---

## Fix — Corregir worker-loop.md

Abrir `doc/vaio/worker-loop.md` y aplicar estos cambios:

### Fix 1 — Watchdog no bloqueante

**Reemplazar:**
```
### Watchdog cloudflared

Antes de procesar tareas, cada ciclo verifica que cloudflared esté vivo:

$proc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $proc) {
    powershell -ExecutionPolicy Bypass -File "C:\xampp\htdocs\Diligencia\doc\vaio\startup-tunnel.ps1"
}
```

**Por:**
```
### Watchdog cloudflared (no bloqueante)

Cada ciclo verifica que cloudflared esté vivo. Si no, lo marca para reinicio
pero NO bloquea el ciclo — el reinicio se delega a startup-tunnel.ps1:

$proc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $proc) {
    # Anotar en el log, no ejecutar startup-tunnel.ps1 ahora
    # (el script tarda 30s y congela el loop)
    Write-Host "WARN: cloudflared caido — se reiniciara al final del ciclo"
}
```

Y al final del ciclo (después del push), agregar el reinicio:
```
# Fin del ciclo: si cloudflared esta caido, reiniciar
$proc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $proc) {
    powershell -ExecutionPolicy Bypass -File "C:\xampp\htdocs\Diligencia\doc\vaio\startup-tunnel.ps1"
}
```

### Fix 2 — Paso 1 robusto

**Reemplazar:**
```
  1. git fetch + git pull (solo si hay cambios remotos nuevos)
```

**Por:**
```
  1. git fetch
     Si fetch falla: esperar 5s y reintentar (máximo 3 intentos)
     Si hay cambios remotos: git pull --rebase
     Si no hay cambios: continuar
```

### Fix 3 — Eliminar pull redundante del paso 6

**Reemplazar:**
```
  6. git add + commit + pull --rebase + push
```

**Por:**
```
  6. git add + commit + push
     (pull ya se hizo en paso 1)
```

### Fix 4 — Agregar log automático

Agregar al inicio del ciclo:
```
# Registrar ciclo en worker-log.md
$logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm UTC')] Ciclo — fetch OK"
Add-Content -Path "doc/vaio/worker-log.md" -Value $logEntry
```

Y al final del ciclo (antes del sleep):
```
# Final del ciclo
$logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm UTC')] Ciclo completo"
Add-Content -Path "doc/vaio/worker-log.md" -Value $logEntry
```

---

## Prueba — Round-trip ping-pong

Después de aplicar los fixes, crear una tarea de prueba y procesarla:

### Crear el resultado de la tarea-010

```powershell
$test = @"
# Resultado 010 — Diagnóstico + Fixes + Ping

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Diagnóstico

| Check | Resultado |
|---|---|
| Último commit en repo | [commit] |
| worker-log.md líneas | [N] |
| Procesos cloudflared | [N] |

## Fixes aplicados

| Fix | Archivo | Estado |
|---|---|---|
| 1 — Watchdog no bloqueante | worker-loop.md | OK |
| 2 — Paso 1 robusto | worker-loop.md | OK |
| 3 — Pull redundante eliminado | worker-loop.md | OK |
| 4 — Log automático | worker-loop.md | OK |

## Ping

Este es un **PING** desde VAIO.

Esperando PONG del MAIN en tarea-010-bis.md
"@
Set-Content -Path "doc\vaio\results\resultado-010.md" -Value $test -Encoding UTF8
```

### Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/resultado-010.md
git add doc/vaio/worker-loop.md
git add doc/vaio/worker-log.md
git commit -m "VAIO: resultado tarea 010 — loop fixes + ping"
git pull --rebase
git push
```

---

## Nota importante

Después de este commit, el worker debe entrar al LOOP con los fixes aplicados.
Si el loop funciona correctamente:
- Debe hacer fetch cada 60s
- Debe actualizar worker-log.md cada ciclo
- Debe detectar tareas nuevas automáticamente
- El watchdog NO debe congelar el ciclo
