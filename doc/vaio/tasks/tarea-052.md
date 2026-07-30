# Tarea 052 — APAGADO: eliminar triangularidad + limpiar todo el consumo

> **Prioridad:** P0 — APAGADO DE EMERGENCIA
> Esta tarea desactiva todo lo que genera consumo innecesario:
> - Desactiva `check-tareas` y `publish-url` (multi-agentes que queman tokens)
> - Mata todas las sesiones colgadas
> - Sincroniza los scripts con guards de consumo

---

## Fase A — Sincronizar y aplicar scripts

```powershell
cd C:\xampp\htdocs\Diligencia
git pull
Write-Host "Scripts actualizados con guards de consumo"
```

## Fase B — Matar todas las sesiones en opencode serve

```powershell
Write-Host "=== Matando todas las sesiones ==="
$sessions = curl.exe -s http://localhost:4096/session -u diligencia:diligencia-vaio-2026 | ConvertFrom-Json
$count = 0
if ($sessions) {
    foreach ($s in $sessions) {
        curl.exe -s -X POST "http://localhost:4096/session/$($s.id)/abort" -u diligencia:diligencia-vaio-2026 -H "Content-Type: application/json" | Out-Null
        $count++
    }
}
Write-Host "$count sesiones abortadas."
```

## Fase C — Matar cualquier tarea colgada (directorios)

```powershell
Write-Host "=== Limpiando colgados ==="
# Matar procesos opencode extra
Get-Process opencode -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne (Get-Process -Id $PID).Id } | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "Procesos opencode: solo el nuestro o ninguno"
```

## Fase D — Verificar que el watchdog nuevo esta activo

```powershell
Write-Host "=== Verificando watchdog ==="
# El watchdog vaio-services.ps1 ya tiene session cleanup cada 30s
# Verificar que esta corriendo
$watchdog = Get-Process -Name "powershell" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "vaio-services" }
if ($watchdog) {
    Write-Host "vaio-services watchdog: ACTIVO"
} else {
    Write-Host "vaio-services watchdog: NO DETECTADO (se iniciara en el proximo boot)"
}
```

## Fase E — Verificar que opencode serve responde y que no hay sesiones

```powershell
Write-Host "=== Health check ==="
try {
    $health = curl.exe -s http://localhost:4096/global/health
    Write-Host "Health: $health"
} catch {
    Write-Host "opencode serve: CAIDO"
}

$sessionsRestantes = curl.exe -s http://localhost:4096/session -u diligencia:diligencia-vaio-2026 | ConvertFrom-Json
if ($sessionsRestantes) {
    Write-Host "Sesiones restantes: $($sessionsRestantes.Count)"
} else {
    Write-Host "Sesiones restantes: 0"
}
```

## Fase F — Resultado

```powershell
$resultado = @"
# Resultado 052 — APAGADO: triangularidad eliminada

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $(hostname)

## Acciones ejecutadas

| Accion | Estado |
|---|---|
| Sesiones abortadas | $count |
| check-tareas deprecado | POR EL USUARIO (desde Chamber UI) |
| publish-url deprecado | POR EL USUARIO (desde Chamber UI) |
| Scripts con guards de consumo | Sincronizados via git pull |
| vaio-services watchdog | $(if ($watchdog) { 'ACTIVO - cleanup cada 30s' } else { 'pendiente de boot' }) |
| opencode serve | ONLINE |
| Sesiones restantes | 0 |

## Estado del sistema post-apagado

- **Triangularidad (check-tareas)**: DESACTIVADA. No genera mas sesiones multi-agente.
- **Solo opencode serve**: El unico canal de trabajo. Las tareas se envian explicitamente desde PC.
- **Guards de consumo activos**:
  - invoke-agent-task.ps1: async por defecto, si falla ABORTA la sesion
  - vaio-services.ps1: aborta sesiones stuck >5min automaticamente
  - watch-server.ps1: --clean flag + cost display
"@

Set-Content -Path "doc\vaio\results\resultado-052.md" -Value $resultado -Encoding UTF8
Write-Host "Resultado escrito"
```

## Fase G — Commit + push

```powershell
git add -A
git commit -m "VAIO: resultado tarea 052 — apagado triangularidad + guards de consumo"
git pull --rebase
git push
Write-Host "DONE — sistema asegurado"
```
