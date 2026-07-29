# Tarea 045 — Auto-diagnóstico y auto-reparación del túnel VAIO

> **Tu responsabilidad es mantener el túnel funcionando. Diagnosticá, repará, y reportá.**
> No esperes a que MAIN te diga qué hacer.

## Paso 1 — Diagnosticar

```powershell
$report = @()
$report += "=== DIAGNÓSTICO $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC') ==="

# 1a. Puertos ocupados
$ports = netstat -ano | Select-String "LISTENING" | Select-String "57123|57124|57125"
$report += "PUERTOS:`n$ports"

# 1b. Procesos cloudflared
$cf = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if ($cf) { $report += "cloudflared: SI — $($cf.Count) proceso(s), PID $($cf[0].Id)" }
else { $report += "cloudflared: NO — CAÍDO" }

# 1c. ¿Chamber responde en cada puerto?
foreach ($p in @(57123, 57124, 57125)) {
    $r = curl.exe -s http://localhost:$p/api/openchamber/tunnel/status 2>$null
    if ($r) { $report += "Chamber :$p — RESPONDE" }
    else { $report += "Chamber :$p — NO RESPONDE" }
}

# 1d. URL del túnel desde el log
$logFile = "$env:TEMP\cloudflared-url.log"
if (Test-Path $logFile) {
    $log = Get-Content $logFile -Tail 30 -Raw
    if ($log -match '(https://[a-z\-]+\.trycloudflare\.com)') {
        $tunnelUrl = $matches[1]
        $report += "URL túnel: $tunnelUrl"
    } else { $report += "URL túnel: no encontrada en log" }
} else { $report += "Log cloudflared: NO EXISTE" }

$report -join "`n"
```

---

## Paso 2 — Reparar

```powershell
# Lógica de reparación basada en el diagnóstico

# 2a. Si cloudflared está caído → reiniciar
$cf = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue
if (-not $cf) {
    Write-Host "REPARANDO: cloudflared caído — iniciando..."
    Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:57123 --no-autoupdate" -RedirectStandardError "$env:TEMP\cloudflared-url.log"
    Start-Sleep -Seconds 15
    Write-Host "cloudflared reiniciado"
}

# 2b. Si Chamber en 57123 no responde → verificar si 57125 sí responde, y redirigir
$r23 = curl.exe -s http://localhost:57123/api/openchamber/tunnel/status 2>$null
$r25 = curl.exe -s http://localhost:57125/api/openchamber/tunnel/status 2>$null
$activePort = if ($r23) { 57123 } elseif ($r25) { 57125 } else { 0 }

if ($activePort -ne 57123 -and $activePort -ne 0) {
    Write-Host "REPARANDO: Chamber en 57125, no en 57123. Redirigiendo cloudflared..."
    Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:$activePort --no-autoupdate" -RedirectStandardError "$env:TEMP\cloudflared-url.log"
    Start-Sleep -Seconds 15
    Write-Host "cloudflared redirigido a :$activePort"
}

# 2c. Capturar URL
$log = Get-Content "$env:TEMP\cloudflared-url.log" -Tail 30 -Raw -ErrorAction SilentlyContinue
$tunnelUrl = ""
if ($log -match '(https://[a-z\-]+\.trycloudflare\.com)') { $tunnelUrl = $matches[1] }
Write-Host "URL activa: $tunnelUrl"
```

---

## Paso 3 — Verificar

```powershell
# Probar la URL desde localhost
if ($tunnelUrl) {
    $r = curl.exe -s -o NUL -w "%{http_code}" $tunnelUrl 2>$null
    if ($r -eq "200") {
        $status = "VERIFICADO — HTTP 200"
    } else {
        $status = "FALLO — HTTP $r"
    }
    Write-Host $status
}
```

---

## Paso 4 — Publicar

```powershell
if ($tunnelUrl) {
    # cloudflared-url-vaio.md
    @"
# Chamber Tunnel URL — VAIO (FELRENA)

**URL:** $tunnelUrl
**Actualizada:** $(Get-Date -Format "yyyy-MM-dd HH:mm UTC")
**Puerto:** $activePort
**Verificación:** $status
"@ | Set-Content -Path "C:\xampp\htdocs\Diligencia\doc\vaio\cloudflared-url-vaio.md" -Encoding UTF8

    # heartbeat con URL
    @"
# heartbeat

VAIO activa — $(Get-Date -Format "yyyy-MM-dd HH:mm UTC")
URL: $tunnelUrl
Puerto: $activePort
"@ | Set-Content -Path "C:\xampp\htdocs\Diligencia\doc\vaio\heartbeat.md" -Encoding UTF8

    git add doc/vaio/cloudflared-url-vaio.md doc/vaio/heartbeat.md
    git commit -m "VAIO: tunnel auto-reparado — $tunnelUrl"
    git pull --rebase
    git push
    "URL publicada: $tunnelUrl"
}
```

---

## Paso 5 — Reportar

```powershell
$ok = @"
# Resultado 045 — Auto-diagnóstico y reparación

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Diagnóstico

| Check | Estado |
|---|---|
| cloudflared | $(if($cf){'OK'}else{'CAÍDO — reparado'}) |
| Chamber 57123 | $(if($r23){'OK'}else{'NO'}) |
| Chamber 57125 | $(if($r25){'OK'}else{'NO'}) |
| URL túnel | $tunnelUrl |
| Verificación HTTP | $status |

## Acciones correctivas

$(if(-not $cf){'- cloudflared reiniciado'}else{'- sin acciones necesarias'})
$(if($activePort -ne 57123){'- cloudflared redirigido a puerto activo'}else{''})

## URL para MAIN

**$tunnelUrl**
"@
Set-Content -Path "doc\vaio\results\resultado-045.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-045.md
git commit -m "VAIO: resultado tarea 045 — auto-diagnostico y reparacion"
git pull --rebase
git push
```
