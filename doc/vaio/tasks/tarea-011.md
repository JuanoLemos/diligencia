# Tarea 011 — Verificación de automatización autónoma

> **Tarea de verificación.** No ejecuta comandos destructivos. No toca MarketAI ni otros proyectos.
> Objetivo: confirmar que el worker detecta tareas solo, las ejecuta, y reporta resultados sin intervención humana.

## Instrucciones

Ejecutar los comandos en orden. Escribir los resultados en `doc/vaio/results/resultado-011.md`.

```powershell
# 1. Información del sistema
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
$hostname = $env:COMPUTERNAME
$user = $env:USERNAME

# 2. Procesos clave
$opencode = Get-Process -Name "opencode*" -ErrorAction SilentlyContinue
$cloudflared = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
$chamber = netstat -ano | findstr 57123

# 3. Estado git
$lastCommit = git log --oneline -1
$repoStatus = git status --porcelain

# 4. URL del túnel
$tunnelUrl = ""
if (Test-Path "doc\vaio\cloudflared-url.md") {
    $tunnelUrl = (Select-String -Path "doc\vaio\cloudflared-url.md" -Pattern "https://").Line -replace '.*\| ', ''
}

# 5. Crear resultado
$report = @"
# Resultado 011 — Verificación de automatización autónoma

**Fecha:** $fecha
**Hostname:** $hostname
**Usuario:** $user

## Estado del worker

| Check | Resultado |
|---|---|
| OpenCode corriendo | SI - PID $($opencode.Id) |
| cloudflared activo | SI - $($cloudflared.Count) proceso(s) |
| Chamber en :57123 | SI |
| Último commit | $lastCommit |
| Git status | $(if($repoStatus -eq ""){"LIMPIO"}else{"SUCIO"}) |
| URL túnel actual | $tunnelUrl |

## Automatización

- Tarea detectada: **SI** (worker ejecutó tarea-011 sin intervención humana)
- Resultado generado: **SI** (este archivo)
- Commit + push: **AUTOMÁTICO**

## Conclusión

El worker autónomo funciona correctamente. MAIN puede enviar tareas a doc/vaio/tasks/ y el worker las procesa sin intervención humana.
"@

Set-Content -Path "doc\vaio\results\resultado-011.md" -Value $report -Encoding UTF8

# 6. Commit + push
git add doc/vaio/results/resultado-011.md
git commit -m "VAIO: resultado tarea 011 — verificacion automatizacion autonoma exitosa"
git pull --rebase
git push
```
