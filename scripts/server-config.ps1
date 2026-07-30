# server-config.ps1
# Configuracion persistente de conexion al servidor remoto (VAIO).
# Se carga automaticamente desde watch-server.ps1 e invoke-agent-task.ps1.
# Si no existe .server-config.json, lo crea con los valores por defecto.
# Uso directo (solo la primera vez o para cambiar):
#   .\scripts\server-config.ps1 -Save "http://100.120.192.43:4096" "diligencia-vaio-2026"

param(
    [string]$SaveServer,
    [string]$SavePassword
)

$script:configPath = Join-Path $PSScriptRoot ".server-config.json"

function Load-Config {
    if (Test-Path $script:configPath) {
        try {
            $cfg = Get-Content $script:configPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.server) { $env:DILIGENCIA_SERVER = $cfg.server }
            if ($cfg.password) { $env:OPENCODE_SERVER_PASSWORD = $cfg.password }
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

function Save-Config {
    param([string]$Server, [string]$Password)
    $cfg = @{ server = $Server; password = $Password } | ConvertTo-Json -Compress
    Set-Content -Path $script:configPath -Value $cfg -Encoding UTF8
    $env:DILIGENCIA_SERVER = $Server
    $env:OPENCODE_SERVER_PASSWORD = $Password
}

# Si se llamo con parametros, guardar
if ($SaveServer -and $SavePassword) {
    Save-Config -Server $SaveServer -Password $SavePassword
    Write-Host "Config guardada en $script:configPath"
    exit 0
}

# Si no hay config cargada, intentar cargar
if (-not $env:DILIGENCIA_SERVER -or -not $env:OPENCODE_SERVER_PASSWORD) {
    $loaded = Load-Config
    if (-not $loaded) {
        # Crear config por defecto con Tailscale
        Save-Config -Server "http://100.120.192.43:4096" -Password "diligencia-vaio-2026"
        Write-Host "Config por defecto creada en $script:configPath" -ForegroundColor Yellow
        Write-Host "Para cambiarla: .\scripts\server-config.ps1 -SaveServer <url> -SavePassword <pass>" -ForegroundColor Yellow
    }
}
