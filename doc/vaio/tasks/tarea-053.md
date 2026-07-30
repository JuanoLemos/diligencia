# Tarea 053 — APAGAR check-tareas desde Windows Task Scheduler (sin usar IA)

> **Prioridad:** P0 — CRITICO
> No usar IA para procesar esta tarea. Solo comandos PowerShell.
> DeepSeek tiene $0 de credito. No se pueden ejecutar agentes.

## Instrucciones

Ejecutar en orden, SOLO comandos PowerShell. NO usar agentes de IA.

```powershell
Write-Host "=== DESACTIVANDO SCHEDULED TASKS QUE QUEMAN TOKENS ==="

# 1. Deshabilitar check-tareas
$task1 = Get-ScheduledTask -TaskName "VAIO: check-tareas" -ErrorAction SilentlyContinue
if ($task1) {
    Disable-ScheduledTask -TaskName "VAIO: check-tareas"
    Write-Host "check-tareas: DESACTIVADA"
} else {
    Write-Host "check-tareas: no encontrada (ya desactivada?)"
}

# 2. Deshabilitar publish-url
$task2 = Get-ScheduledTask -TaskName "VAIO: publish-url" -ErrorAction SilentlyContinue
if ($task2) {
    Disable-ScheduledTask -TaskName "VAIO: publish-url"
    Write-Host "publish-url: DESACTIVADA"
} else {
    Write-Host "publish-url: no encontrada (ya desactivada?)"
}

# 3. Habilitar server-health si existe
$task3 = Get-ScheduledTask -TaskName "VAIO: server-health" -ErrorAction SilentlyContinue
if ($task3) {
    Enable-ScheduledTask -TaskName "VAIO: server-health"
    Write-Host "server-health: ACTIVADA"
} else {
    Write-Host "server-health: no encontrada (crearla manualmente si se necesita)"
}

# 4. Verificar estado final
Write-Host ""
Write-Host "=== ESTADO FINAL ==="
Get-ScheduledTask -TaskName "VAIO:*" | Format-Table TaskName, State, Enabled -AutoSize

# 5. Matar sesiones colgadas en opencode serve (si responde)
try {
    $sessions = curl.exe -s http://localhost:4096/session -u diligencia:diligencia-vaio-2026 2>$null | ConvertFrom-Json
    if ($sessions) {
        foreach ($s in $sessions) {
            curl.exe -s -X POST "http://localhost:4096/session/$($s.id)/abort" -u diligencia:diligencia-vaio-2026 -H "Content-Type: application/json" 2>$null | Out-Null
        }
        Write-Host "Sesiones abortadas: $($sessions.Count)"
    }
} catch {
    Write-Host "opencode serve no responde (no hay sesiones que matar)"
}

# 6. Escribir resultado
$resultado = @"
# Resultado 053 — Scheduled Tasks desactivadas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

## Acciones

| Scheduled Task | Accion |
|---|---|
| VAIO: check-tareas | DESACTIVADA |
| VAIO: publish-url | DESACTIVADA |
| VAIO: server-health | ACTIVADA (si existe) |

## Estado opencode serve

$(try { $h = curl.exe -s http://localhost:4096/global/health -u diligencia:diligencia-vaio-2026 2>$null; $h } catch { "no responde (sin credito DeepSeek)" })

## Notas

- DeepSeek quedo en $0. No se pueden ejecutar agentes hasta recargar.
- Las tareas de VAIO ya no generan sesiones multi-agente automaticamente.
- La unica forma de ejecutar tareas ahora es via API directa (cuando haya credito).
"@

Set-Content -Path "doc\vaio\results\resultado-053.md" -Value $resultado -Encoding UTF8

# 7. Commit y push
git add -A
git commit -m "VAIO: resultado tarea 053 — scheduled tasks desactivadas, consumo detenido"
git pull --rebase
git push
Write-Host "DONE"
```
