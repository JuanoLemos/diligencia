# Tarea 007 — Auto-publicación de URL cloudflared + watchdog

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.

## Objetivo

Crear un sistema que publique automáticamente la URL de cloudflared en el repo, para que el MAIN la lea sin necesidad de conexión manual a la VAIO.

---

## Paso 1 — Crear el script de arranque

Crear `doc/vaio/startup-tunnel.ps1` con este contenido:

```powershell
# startup-tunnel.ps1 — Inicia cloudflared, captura URL, publica en el repo
# Ejecutar al iniciar la VAIO (scheduled task o startup)

$projectRoot = "C:\xampp\htdocs\Diligencia"
$urlFile = "$projectRoot\doc\vaio\cloudflared-url.md"
$logFile = "$projectRoot\doc\vaio\tunnel-startup.log"
$date = Get-Date -Format "yyyy-MM-dd HH:mm UTC"

Set-Location $projectRoot

# 1. Git pull para tener el repo al día
git pull --rebase 2>&1 | Out-Null

# 2. Verificar que cloudflared está disponible
$cloudflared = "cloudflared"
try { $null = Get-Command $cloudflared -ErrorAction Stop }
catch {
    "NO: cloudflared no encontrado" | Set-Content -Path $logFile
    exit 1
}

# 3. Matar instancias previas de cloudflared (por si quedaron colgadas)
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force

# 4. Iniciar cloudflared y capturar salida
$tempFile = "$env:TEMP\cloudflared-output.txt"
$process = Start-Process -FilePath $cloudflared -ArgumentList "tunnel --url http://localhost:57123" -WindowStyle Hidden -PassThru -RedirectStandardOutput $tempFile

# 5. Esperar hasta que aparezca la URL (timeout 30 segundos)
$url = $null
$timeout = 30
$elapsed = 0
while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 1
    $elapsed++
    if (Test-Path $tempFile) {
        $content = Get-Content -Path $tempFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'https://([a-z-]+\.trycloudflare\.com)') {
            $url = $matches[0]
            break
        }
    }
}

# 6. Escribir resultado
if ($url) {
    @"
# cloudflared-url (actualizada automáticamente)

| Campo | Valor |
|---|---|
| URL | $url |
| Última actualización | $date |
| Puerto | 57123 |
| Proceso PID | $($process.Id) |
"@ | Set-Content -Path $urlFile

    "URL capturada: $url" | Set-Content -Path $logFile

    # Commit + push
    git add doc/vaio/cloudflared-url.md
    git commit -m "VAIO: URL cloudflared actualizada — $url" 2>&1 | Out-Null
    git pull --rebase 2>&1 | Out-Null
    git push 2>&1 | Out-Null
} else {
    "ERROR: No se pudo capturar URL de cloudflared en $timeout segundos" | Set-Content -Path $logFile
    exit 1
}

exit 0
```

---

## Paso 2 — Ejecutar el script por primera vez

```powershell
cd C:\xampp\htdocs\Diligencia
powershell -File doc\vaio\startup-tunnel.ps1
```

Verificar que se creó `doc/vaio/cloudflared-url.md`:
```powershell
cat doc\vaio\cloudflared-url.md
```

Y que git lo commiteó:
```powershell
git log --oneline -1
```

---

## Paso 3 — Instalar como Scheduled Task (arranque automático)

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"C:\xampp\htdocs\Diligencia\doc\vaio\startup-tunnel.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "VAIO-CloudflareTunnel" -Action $action -Trigger $trigger -Principal $principal -Force
```

Verificar que se creó:
```powershell
Get-ScheduledTask -TaskName "VAIO-CloudflareTunnel" | Format-List TaskName, State, Triggers
```

---

## Paso 4 — Extender worker loop para watchdog de cloudflared

Agregar al inicio de cada ciclo del worker loop esta verificación:

```powershell
# Watchdog cloudflared
$proc = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $proc) {
    # cloudflared caído — reiniciar
    powershell -File "C:\xampp\htdocs\Diligencia\doc\vaio\startup-tunnel.ps1"
}
```

---

## Escribir resultado

Crear `doc/vaio/results/resultado-007.md`:

```
# Resultado 007

**Fecha:** [fecha/hora UTC]

## Resumen

| Campo | Valor |
|---|---|
| startup-tunnel.ps1 creado | SI/NO |
| Primera URL capturada | SI/NO — [URL] |
| cloudflared-url.md | SI/NO |
| Scheduled Task creada | SI/NO |
| Worker loop extendido | SI/NO |

## URL actual
[pegar URL de cloudflared-url.md]

## Errores
[errores si los hubo]
```

---

## Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 007 — auto-publicacion URL cloudflared"
git pull --rebase
git push
```
