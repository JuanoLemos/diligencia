# cost-tracker.ps1 - R69 Dashboard de costos de OpenCode/DeepSeek
# Solucion R79.1 burn rate: provee visibilidad continua de costos.
# Cada 5min consulta GET /session, acumula tokens y costo en
# doc/vaio/cost-YYYY-MM-DD.md. Activa circuit breaker si dia > cap.
#
# Uso:
#   .\scripts\cost-tracker.ps1                 # Una corrida (snapshot)
#   .\scripts\cost-tracker.ps1 -Daemon         # Loop infinito (cada 5min)
#   .\scripts\cost-tracker.ps1 -Interval 60    # Daemon con intervalo custom
#   .\scripts\cost-tracker.ps1 -DailyCap 5.0   # Cambiar cap diario (default 5)
#   .\scripts\cost-tracker.ps1 -Alert          # Solo alerta si cap excedido

param(
    [switch]$Daemon,
    [int]$Interval = 300,
    [double]$DailyCap = 5.0,
    [switch]$Alert,
    [string]$DiligenciaDir = "C:\xampp\htdocs\Diligencia"
)

$ErrorActionPreference = "Continue"

$costDir = Join-Path $DiligenciaDir "doc\vaio"
$today = Get-Date -Format "yyyy-MM-dd"
$costFile = Join-Path $costDir ("cost-" + $today + ".md")
$alertFile = Join-Path $costDir "cost-alerts.md"

# Cargar config persistente
$configPath = Join-Path $PSScriptRoot "server-config.ps1"
if (Test-Path $configPath) { . $configPath }

$Server = $env:DILIGENCIA_SERVER
$Password = $env:OPENCODE_SERVER_PASSWORD

if (-not $Server) {
    Write-Host "ERROR: DILIGENCIA_SERVER no definido." -ForegroundColor Red
    exit 1
}
if (-not $Password) {
    Write-Host "ERROR: OPENCODE_SERVER_PASSWORD no definido." -ForegroundColor Red
    exit 1
}

$username = "diligencia"
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($username + ":" + $Password)))
$headers = @{ "Authorization" = "Basic $base64Auth"; "Content-Type" = "application/json" }

function Get-Snapshot {
    try {
        $sessions = Invoke-RestMethod -Uri ($Server + "/session") -Headers $headers -TimeoutSec 10
        if (-not $sessions) { return @() }
        return @($sessions)
    } catch {
        Write-Host "WARN: No se pudo conectar a $Server/session: $_" -ForegroundColor Yellow
        return @()
    }
}

function Get-Balance {
    try {
        $key = $env:DEEPSEEK_API_KEY
        if (-not $key) { return $null }
        $hdr = @{ "Authorization" = "Bearer $key"; "Content-Type" = "application/json" }
        $bal = Invoke-RestMethod -Uri "https://api.deepseek.com/user/balance" -Headers $hdr -TimeoutSec 10
        if ($bal.balance_infos -and $bal.balance_infos.Count -gt 0) {
            return [double]$bal.balance_infos[0].balance
        }
    } catch {
        Write-Host "WARN: No se pudo consultar balance DeepSeek: $_" -ForegroundColor Yellow
    }
    return $null
}

function Format-Cost {
    param([double]$Value)
    return $Value.ToString('N4')
}

function Write-Snapshot {
    param($Sessions, [double]$TotalCost, [int]$TotalIn, [int]$TotalOut, $Balance)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $costStr = Format-Cost -Value $TotalCost
    $capStr = $DailyCap.ToString('N2')
    $pctCap = if ($DailyCap -gt 0) { [math]::Round(($TotalCost / $DailyCap) * 100, 1) } else { 0 }
    $lines = @()
    $lines += "# Cost Snapshot - $today"
    $lines += ""
    $lines += ("[Timestamp] " + $ts)
    $lines += ("[Daily cap] `$$capStr")
    if ($null -ne $Balance) {
        $balStr = Format-Cost -Value $Balance
        $lines += ("[Balance] `$$balStr")
    }
    $lines += ""
    $lines += "## Aggregate"
    $lines += ""
    $lines += "| Metric | Value |"
    $lines += "|---|---|"
    $lines += ("| Total sessions | $($Sessions.Count) |")
    $lines += ("| Input tokens | $TotalIn |")
    $lines += ("| Output tokens | $TotalOut |")
    $lines += ("| Total cost | `$$costStr |")
    $lines += ("| % of daily cap | $pctCap% |")
    $lines += ""
    $lines += "## Per-Session"
    $lines += ""
    $lines += "| ID | Status | Model | In | Out | Cost | Updated |"
    $lines += "|---|---|---|---|---|---|---|"
    foreach ($s in ($Sessions | Sort-Object { $_.cost } -Descending)) {
        $sid = if ($s.id.Length -gt 12) { $s.id.Substring(0, 12) } else { $s.id }
        $model = $s.info.modelID
        $sCostStr = Format-Cost -Value ([double]$s.cost)
        $lines += ("| $sid | $($s.info.status) | $model | $($s.tokens.input) | $($s.tokens.output) | `$$sCostStr | $($s.time.updated) |")
    }
    $lines += ""
    $lines += "---"
    $lines += ""
    $content = ($lines -join "`n")
    Add-Content -Path $costFile -Value $content -Encoding UTF8
}

function Test-CircuitBreaker {
    param($Sessions, [double]$TotalCost)
    if ($TotalCost -gt $DailyCap) {
        $capStr = $DailyCap.ToString('N2')
        $costStr = Format-Cost -Value $TotalCost
        $msg = "## ALERT $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" + "`n" + "Daily cost `$$costStr excede cap `$$capStr. Accion: kill all sessions."
        Add-Content -Path $alertFile -Value $msg -Encoding UTF8
        Write-Host "ALERTA: Daily cost `$$costStr > `$$capStr. Matando sesiones..." -ForegroundColor Red
        foreach ($s in $Sessions) {
            try {
                Invoke-RestMethod -Uri ($Server + "/session/$($s.id)/abort") -Method Post -Headers $headers -TimeoutSec 5 | Out-Null
            } catch {}
        }
        return $true
    }
    return $false
}

function Invoke-Once {
    $sessions = Get-Snapshot
    if ($sessions.Count -eq 0) {
        Write-Host "Sin sesiones o server offline."
        return
    }
    $totalCost = 0; $totalIn = 0; $totalOut = 0
    foreach ($s in $sessions) {
        $totalCost += [double]$s.cost
        $totalIn += [int]$s.tokens.input
        $totalOut += [int]$s.tokens.output
    }
    $balance = Get-Balance
    Write-Snapshot -Sessions $sessions -TotalCost $totalCost -TotalIn $totalIn -TotalOut $totalOut -Balance $balance
    $costStr = Format-Cost -Value $totalCost
    Write-Host ("Snapshot guardado en " + $costFile) -ForegroundColor Green
    Write-Host ("  Total cost: `$$costStr | In: $totalIn | Out: $totalOut | Sessions: $($sessions.Count)")
    if ($null -ne $balance) {
        $balStr = Format-Cost -Value $balance
        Write-Host ("  DeepSeek balance: `$$balStr")
    }
    $tripped = Test-CircuitBreaker -Sessions $sessions -TotalCost $totalCost
    if ($tripped) { Write-Host "Circuit breaker TRIPPED." -ForegroundColor Red }
}

# Modo alert only
if ($Alert) {
    $sessions = Get-Snapshot
    $totalCost = 0
    foreach ($s in $sessions) { $totalCost += [double]$s.cost }
    $costStr = Format-Cost -Value $totalCost
    if ($totalCost -gt $DailyCap) {
        Write-Host ("ALERTA: `$$costStr > `$$DailyCap") -ForegroundColor Red
        exit 1
    }
    Write-Host ("OK: `$$costStr <= `$$DailyCap")
    exit 0
}

# Modo daemon
if ($Daemon) {
    Write-Host ("Daemon cost-tracker cada ${Interval}s. Daily cap: `$$DailyCap") -ForegroundColor Cyan
    Write-Host ("Output: " + $costFile)
    Write-Host "Presiona Ctrl+C para detener."
    while ($true) {
        try {
            Invoke-Once
        } catch {
            Write-Host ("ERROR: $_") -ForegroundColor Red
        }
        Start-Sleep -Seconds $Interval
    }
}

# Default: una corrida
Invoke-Once
