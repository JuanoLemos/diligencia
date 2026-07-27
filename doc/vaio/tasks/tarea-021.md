# Tarea 021 — publish-url lee URL directamente de cloudflared

> **Problema:** publish-url usa `GET /api/openchamber/tunnel/status` pero Chamber no gestiona el túnel (cloudflared es manual). El status reporta `null`.
> **Solución:** publish-url lee la URL desde el proceso cloudflared o sus métricas.

## Paso 1 — Redirigir cloudflared stderr a archivo conocido

```powershell
# Detener cloudflared actual
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Iniciar cloudflared redirigiendo stderr a un archivo
$logFile = "$env:TEMP\cloudflared-url.log"
Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57124 --no-autoupdate" -RedirectStandardError $logFile
Start-Sleep -Seconds 15

# Leer URL del log
$log = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
if ($log -match 'https://([a-z\-]+\.trycloudflare\.com)') {
    $url = $matches[0]
    Write-Host "URL: $url"
} else {
    Write-Host "URL no encontrada aún — el túnel puede tardar unos segundos"
}

# Escribir en cloudflared-url.md
@"
# Cloudflared Tunnel URL

**URL:** $url
**Actualizada:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Fuente:** cloudflared stderr
**Local:** http://localhost:57124
"@ | Set-Content -Path "C:\xampp\htdocs\Diligencia\doc\vaio\cloudflared-url.md" -Encoding UTF8

git add doc/vaio/cloudflared-url.md
git commit -m "VAIO: URL cloudflared (fuente directa)" 2>&1 | Out-Null
git pull --rebase 2>&1 | Out-Null
git push 2>&1 | Out-Null

"URL publicada: $url"
```

---

## Paso 2 — Actualizar prompt de publish-url

```powershell
# Obtener la task publish-url actual
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json
$puTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: publish-url" }

# Nuevo prompt que lee la URL del archivo de log de cloudflared
$newPrompt = "Leé la URL del túnel desde el archivo de log de cloudflared.`n1. Get-Content -Raw `$env:TEMP\cloudflared-url.log`n2. Extraé la URL con regex: 'https://[a-z-]+\\.trycloudflare\\.com'`n3. Escribí la URL en doc/vaio/cloudflared-url.md`n4. git add + commit + push`n5. DONE"

$body = @{task=@{id=$puTask.id;name=$puTask.name;enabled=$true;schedule=$puTask.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$newPrompt;sessionId=$puTask.state.lastSessionId}}} | ConvertTo-Json -Depth 10
$body | Set-Content "$env:TEMP\pu-fix.json" -Encoding UTF8
curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\pu-fix.json" | Out-Null
"publish-url actualizado"
```

---

## Paso 3 — Verificar

```powershell
# Esperar que cloudflared ya tenga URL (si no la tenía)
Start-Sleep -Seconds 15

$log = Get-Content "$env:TEMP\cloudflared-url.log" -Raw -ErrorAction SilentlyContinue
if ($log -match 'https://([a-z\-]+\.trycloudflare\.com)') {
    $url = $matches[0]
    Write-Host "URL activa: $url"
    Write-Host "Probá: $url"
} else {
    Write-Host "cloudflared aún conectando. Revisar en unos segundos."
}

# Verificar tasks
curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks | Select-Object name, enabled, @{n="sessionId";e={$_.execution.sessionId}}
```

---

## Escribir resultado

```powershell
$url = ""
$log = Get-Content "$env:TEMP\cloudflared-url.log" -Raw -ErrorAction SilentlyContinue
if ($log -match 'https://([a-z\-]+\.trycloudflare\.com)') { $url = $matches[0] }

$ok = @"
# Resultado 021 — publish-url usa fuente directa de cloudflared

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| cloudflared stderr → log | SI/NO |
| URL capturada | $url |
| publish-url actualizado | SI/NO |
| cloudflared-url.md actualizado | SI/NO |

## Nota

publish-url ahora lee la URL directamente del proceso cloudflared (stderr), no de la API de Chamber.
"@
Set-Content -Path "doc\vaio\results\resultado-021.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-021.md
git commit -m "VAIO: resultado tarea 021 — publish-url usa fuente directa cloudflared"
git pull --rebase
git push
```
