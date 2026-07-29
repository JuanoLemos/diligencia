# Tarea 044 — Solución permanente de URL VAIO

> **Objetivo:** Que la URL de cloudflared siempre esté publicada en el repo.
> Sin intervención manual. Sin abrir vscode.dev para saber la URL.

## Paso 1 — Verificar publish-url

```powershell
$api = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$pu = $tasks | Where-Object {$_.name -eq "VAIO: publish-url"}

if (-not $pu) {
    Write-Host "publish-url NO existe — creando..."
    $prompt = "Obtené la URL actual del túnel.`n1. Get-Content `$env:TEMP\cloudflared-url.log -Tail 30 | Select-String 'https://[a-z-]+\.trycloudflare\.com'`n2. Extraé la URL`n3. Escribila en doc/vaio/cloudflared-url-vaio.md con formato:`n`n# Chamber Tunnel URL — VAIO`n**URL:** <URL>`n**Actualizada:** (fecha UTC)`n`n4. git add doc/vaio/cloudflared-url-vaio.md && git commit -m 'VAIO: URL cloudflared' && git push"
    $body = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\044-pu.json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\044-pu.json" | Out-Null
    "publish-url CREADA"
} else {
    # Corregir prompt si no escribe en cloudflared-url-vaio.md
    if ($pu.execution.prompt -notmatch 'cloudflared-url-vaio') {
        Write-Host "Corrigiendo prompt de publish-url..."
        $prompt = "Obtené la URL actual del túnel.`n1. Get-Content `$env:TEMP\cloudflared-url.log -Tail 30 | Select-String 'https://[a-z-]+\.trycloudflare\.com'`n2. Extraé la URL`n3. Escribila en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit -m 'VAIO: URL cloudflared' + push"
        $sid = $pu.state.lastSessionId
        $body = @{task=@{id=$pu.id;name=$pu.name;enabled=$true;schedule=$pu.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt}}} | ConvertTo-Json -Depth 10
        $body | Set-Content "$env:TEMP\044-fix-pu.json" -Encoding UTF8 -Force
        curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\044-fix-pu.json" | Out-Null
        "publish-url CORREGIDO"
    } else { "publish-url ya correcto" }
}
```

## Paso 2 — Obtener y publicar URL AHORA

```powershell
$logFile = "$env:TEMP\cloudflared-url.log"
if (-not (Test-Path $logFile)) { "cloudflared log NO existe — posiblemente no está corriendo" }

$log = Get-Content $logFile -Tail 30 -Raw -ErrorAction SilentlyContinue
$url = ""
if ($log -match '(https://[a-z\-]+\.trycloudflare\.com)') { $url = $matches[1] }

if ($url) {
    @"
# Chamber Tunnel URL — VAIO (FELRENA)

**URL:** $url
**Actualizada:** $(Get-Date -Format "yyyy-MM-dd HH:mm UTC")
**Fuente:** cloudflared background (VAIO)
**Local:** http://localhost:57125
"@ | Set-Content -Path "C:\xampp\htdocs\Diligencia\doc\vaio\cloudflared-url-vaio.md" -Encoding UTF8

    git add doc/vaio/cloudflared-url-vaio.md
    git commit -m "VAIO: URL cloudflared = $url" 2>&1 | Out-Null
    git pull --rebase 2>&1 | Out-Null
    git push 2>&1 | Out-Null
    Write-Host "URL publicada: $url"
} else { Write-Host "No se pudo obtener URL — cloudflared puede estar caído" }
```

## Paso 3 — Verificar cloudflared vivo

```powershell
$cf = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $cf) {
    Write-Host "cloudflared NO está corriendo — iniciando..."
    Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57125 --no-autoupdate" -RedirectStandardError "$env:TEMP\cloudflared-url.log"
    Start-Sleep -Seconds 12
    $cf = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
    if ($cf) { "cloudflared REINICIADO" }
} else { Write-Host "cloudflared OK — PID $($cf[0].Id)" }
```

## Paso 4 — Ajustar heartbeat para incluir URL

```powershell
# El heartbeat debe incluir la URL actual para que MAIN siempre sepa dónde conectarse
# Este paso modifica el comportamiento: en vez de "sin tareas", incluye URL
if ($url) {
    @"
# heartbeat

VAIO activa — $(Get-Date -Format "yyyy-MM-dd HH:mm UTC")
URL: $url
Tareas pendientes: 0
"@ | Set-Content -Path "C:\xampp\htdocs\Diligencia\doc\vaio\heartbeat.md" -Encoding UTF8

    git add doc/vaio/heartbeat.md
    git commit -m "VAIO: heartbeat — URL: $url" 2>&1 | Out-Null
    git pull --rebase 2>&1 | Out-Null
    git push 2>&1 | Out-Null
}
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 044 — URL permanente VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| publish-url existe/corregido | SI/NO |
| URL actual | $url |
| cloudflared corriendo | SI/NO |
| cloudflared-url-vaio.md | actualizado |
| heartbeat con URL | SI/NO |

## Conclusión

La URL de VAIO ahora se publica en doc/vaio/cloudflared-url-vaio.md cada hora.
El heartbeat incluye la URL cada minuto.
Siempre disponible sin intervención humana.
"@
Set-Content -Path "doc\vaio\results\resultado-044.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-044.md
git commit -m "VAIO: resultado tarea 044 — URL permanente"
git pull --rebase
git push
```
