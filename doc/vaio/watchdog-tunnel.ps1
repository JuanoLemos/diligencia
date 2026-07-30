# watchdog-tunnel.ps1 - Monitoreo y auto-reparacion del tunel v2.0 (R79.1)
# Reemplaza la task 'VAIO: publish-url' (cron '0 * * * *' + deepseek-v4-pro)
# Toda la logica de publicacion de URL/heartbeat es PowerShell puro.
# 0 tokens consumidos. Solucion burn rate USD 10/dia.
# Repo: C:\xampp\htdocs\Diligencia\doc\vaio\watchdog-tunnel.ps1
#
# Lanzado automaticamente por start-chamber.ps1 en background.
# Tarea historica 'VAIO: publish-url' queda DEPRECATED: usar este watchdog.

param(
    [int]$Port = 57125,
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia",
    [int]$CheckIntervalSeconds = 60
)

$logFile = "$env:TEMP\cf-watchdog-57125.log"
$heartbeatFile = "$DiligenciaDir\doc\vaio\heartbeat.md"
$urlVaioFile = "$DiligenciaDir\doc\vaio\cloudflared-url-vaio.md"

function Get-CurrentUrl {
    if (Test-Path $logFile) {
        $log = Get-Content $logFile -Tail 20 -ErrorAction SilentlyContinue | Out-String
        if ($log -match '(https://[a-z\-]+\.trycloudflare\.com)') {
            return $matches[1]
        }
    }
    return $null
}

function Write-Heartbeat($url) {
    $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm UTC")
    $c = "# heartbeat"
    $c = $c + "`n`nVAIO activa - " + $ts
    if ($url) { $c = $c + "`nURL: " + $url }
    $c = $c + "`nPuerto: " + $Port
    Set-Content -LiteralPath $heartbeatFile -Value $c -Encoding UTF8 -Force
}

function Write-UrlFile($url) {
    $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm UTC")
    $c = "# Chamber Tunnel URL - VAIO (FELRENA)"
    $c = $c + "`n`n**URL:** " + $url
    $c = $c + "`n**Actualizada:** " + $ts
    $c = $c + "`n**Puerto:** " + $Port
    Set-Content -LiteralPath $urlVaioFile -Value $c -Encoding UTF8 -Force
}

function Start-Tunnel {
    $proc = Start-Process -WindowStyle Hidden -FilePath "C:\Program Files (x86)\cloudflared\cloudflared.exe" -ArgumentList "tunnel --url http://localhost:$Port" -RedirectStandardError $logFile -PassThru
    Start-Sleep -Seconds 15
    return Get-CurrentUrl
}

Write-Host "[watchdog] Iniciando monitoreo en :$Port cada ${CheckIntervalSeconds}s"

$lastUrl = ""
$lastPublish = (Get-Date).AddHours(-1)
$rateLimitUntil = (Get-Date).AddHours(-1)

while ($true) {
    try {
        $url = Get-CurrentUrl
        $cf = Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq 1 }

        if (-not $cf) {
            $now = Get-Date
            if ($now -lt $rateLimitUntil) {
                Write-Host "[watchdog] Rate-limited - esperando hasta $rateLimitUntil..."
            } else {
                Write-Host "[watchdog] cloudflared no corre - iniciando..."
                Remove-Item $logFile -Force -ErrorAction SilentlyContinue
                $url = Start-Tunnel
                if ($url) { Write-Host "[watchdog] Nuevo URL: $url" }
                else {
                    $log = Get-Content $logFile -Tail 10 -ErrorAction SilentlyContinue | Out-String
                    if ($log -match '429') {
                        $rateLimitUntil = (Get-Date).AddMinutes(5)
                        Write-Host "[watchdog] 429 detectado - backoff hasta $rateLimitUntil"
                    }
                }
            }
        }
        elseif (-not $url -and $cf) {
            Write-Host "[watchdog] cloudflared corriendo sin URL - esperando..."
        }

        if ($url -and $url -ne $lastUrl) {
            Write-Host "[watchdog] URL cambio: $url"
            Write-Heartbeat $url
            Write-UrlFile $url

            Set-Location $DiligenciaDir
            & git add "$urlVaioFile" "$heartbeatFile" 2>$null
            & git commit -m "VAIO: URL actualizada - $url" 2>$null
            & git pull --rebase 2>$null
            & git push 2>$null

            $lastUrl = $url
            Write-Host "[watchdog] URL publicada en repo"
        }

        $now = Get-Date
        if (($now - $lastPublish).TotalMinutes -ge 5) {
            if (-not $url) {
                Write-Heartbeat $null
                & git add "$heartbeatFile" 2>$null
                & git commit -m "VAIO: heartbeat - sin tunnel" 2>$null
                & git pull --rebase 2>$null
                & git push 2>$null
            }
            $lastPublish = $now
        }

        Start-Sleep -Seconds $CheckIntervalSeconds
    } catch {
        Write-Host "[watchdog] Error: $_"
        Start-Sleep -Seconds $CheckIntervalSeconds
    }
}
