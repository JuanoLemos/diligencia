# startup-tunnel.ps1 — Inicia cloudflared, captura URL, publica en el repo
$projectRoot = "C:\xampp\htdocs\Diligencia"
$urlFile = "$projectRoot\doc\vaio\cloudflared-url.md"
$logFile = "$projectRoot\doc\vaio\tunnel-startup.log"
$date = Get-Date -Format "yyyy-MM-dd HH:mm UTC"

Set-Location $projectRoot
git pull --rebase 2>&1 | Out-Null

$cloudflared = "C:\Program Files (x86)\cloudflared\cloudflared.exe"
if (-not (Test-Path $cloudflared)) {
    "NO: cloudflared no encontrado" | Set-Content -Path $logFile
    exit 1
}

Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$tempFile = "$env:TEMP\cloudflared-tunnel-output.txt"
$process = Start-Process -FilePath $cloudflared -ArgumentList "tunnel --url http://localhost:57123 --no-autoupdate" -WindowStyle Hidden -PassThru -RedirectStandardError $tempFile

$url = $null
$timeout = 30
$elapsed = 0
while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 1
    $elapsed++
    if (Test-Path $tempFile) {
        $content = Get-Content -Path $tempFile -Raw -ErrorAction SilentlyContinue
        if ($content -match "https://([a-z\-]+\.trycloudflare\.com)") {
            $url = $matches[0]
            break
        }
    }
}

if ($url) {
    $md = "# cloudflared-url`n`n"
    $md += "| Campo | Valor |`n"
    $md += "|---|---|`n"
    $md += "| URL | $url |`n"
    $md += "| Fecha | $date |`n"
    $md += "| Puerto | 57123 |`n"
    $md += "| PID | $($process.Id) |`n"
    $md | Set-Content -Path $urlFile -Encoding UTF8
    "URL: $url" | Set-Content -Path $logFile
    git add doc/vaio/cloudflared-url.md
    git commit -m "VAIO: URL cloudflared = $url" 2>&1 | Out-Null
    git pull --rebase 2>&1 | Out-Null
    git push 2>&1 | Out-Null
} else {
    "ERROR: sin URL en ${timeout}s" | Set-Content -Path $logFile
    exit 1
}
exit 0
