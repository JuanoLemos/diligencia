# VAIO Runbook - Procedimientos de operación

**Versión:** v3.10.3
**Propósito:** guía rápida para que vos (no la IA) operes el stack VAIO sin necesitarme.

---

## 🚀 Estado del stack

| Componente | Estado esperado |
|---|---|
| opencode serve en :4096 | Escuchando |
| Chamber Electron en :57123 | Escuchando |
| Tailscale | Activo, IP `100.120.192.43` |
| ngrok dual tunnel | Activo, URL `https://*.ngrok-free.dev` |
| Watchdog (Task Scheduler) | `Diligencia-VAIO-Services` Running |
| ngrok task | `ngrok-Diligencia` Ready (triggers: Startup + Logon) |

---

## 🔍 Verificación de salud (smoke test rápido)

Pegá esto en PowerShell:

```powershell
# 1. Procesos vivos
Get-Process -Name "opencode", "OpenChamber", "ngrok" -ErrorAction SilentlyContinue | Format-Table Name, Id, StartTime

# 2. Puertos escuchando
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 4096,57123,4040 } | Format-Table LocalPort, OwningProcess

# 3. Health opencode
curl.exe -s -m 3 -u "diligencia:diligencia-vaio-2026" http://localhost:4096/global/health

# 4. Tunnel ngrok
Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" | Select-Object -ExpandProperty tunnels | Format-Table name, public_url, config.addr

# 5. Tailscale
tailscale status
```

Si todo OK, deberías ver: opencode + OpenChamber + ngrok como procesos; puertos 4096, 57123, 4040 escuchando; health `{"healthy":true,...}`; 2 tunnels en ngrok; Tailscale con tu IP.

---

## 🚑 Recovery procedures

### A. opencode serve no responde en :4096

```powershell
# 1. Verificar si hay proceso
Get-Process -Name "opencode" -ErrorAction SilentlyContinue

# 2. Si está, matar y relanzar
Get-Process -Name "opencode" -ErrorAction SilentlyContinue | Where-Object { (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object OwningProcess -eq $_.Id).Count -gt 0 } | Stop-Process -Force

# 3. Relanzar opencode serve manualmente
$env:OPENCODE_SERVER_USERNAME = "diligencia"
$env:OPENCODE_SERVER_PASSWORD = "diligencia-vaio-2026"
$env:MINIMAX_API_KEY = (Get-ItemProperty "HKCU:\Environment" -Name MINIMAX_API_KEY -ErrorAction SilentlyContinue).MINIMAX_API_KEY
$opencodeExe = "C:\Users\jlemo\AppData\Local\Programs\@openchamberelectron\resources\opencode-cli\opencode.exe"
Start-Process -FilePath $opencodeExe -ArgumentList "serve","--port","4096","--hostname","0.0.0.0" -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\opencode-server-stdout.log" -RedirectStandardError "$env:TEMP\opencode-server-stderr.log"
Start-Sleep -Seconds 5
curl.exe -s -m 3 -u "diligencia:diligencia-vaio-2026" http://localhost:4096/global/health
```

### B. ngrok tunnels caídos

```powershell
# 1. Verificar ngrok
Get-Process -Name "ngrok" -ErrorAction SilentlyContinue

# 2. Si no está, lanzar ngrok start --all
$ngrok = "C:\Users\jlemo\AppData\Local\Microsoft\WinGet\Links\ngrok.exe"
Start-Process -FilePath $ngrok -ArgumentList "start","--all" -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\ngrok-all.log"

# 3. Esperar 5 segundos y verificar
Start-Sleep -Seconds 5
Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" | Select-Object -ExpandProperty tunnels | Format-Table name, public_url
```

### C. Chamber Electron no responde en :57123

```powershell
# Chamber es interactivo - lo abrís desde el menú Inicio o shortcut
# Si está colgado:
Get-Process -Name "OpenChamber" -ErrorAction SilentlyContinue | Stop-Process -Force
# Reabrir desde Start Menu
```

### D. Tailscale inactivo

```powershell
# Verificar estado
tailscale status

# Si dice "not running", levantar servicio
Start-Service Tailscale

# Si dice "needs login", reautenticar
tailscale up
```

### E. API key MiniMax expirada o inválida

```powershell
# Verificar
[System.Environment]::GetEnvironmentVariable("MINIMAX_API_KEY", "User")

# Si está vacía o cambió, setear de nuevo
[System.Environment]::SetEnvironmentVariable("MINIMAX_API_KEY", "sk-cp-...", "User")
# Reiniciar opencode serve para que la lea
Get-Process -Name "opencode" -ErrorAction SilentlyContinue | Where-Object { (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object OwningProcess -eq $_.Id).Count -gt 0 } | Stop-Process -Force
# Relanzar (ver seccion A)
```

---

## 🔄 Reboot completo de VAIO

Si necesitás reiniciar VAIO entero:

```powershell
shutdown /r /t 0
```

Después del reboot (60-90s), las tasks de Windows se ejecutan automáticamente:
- `Diligencia-VAIO-Services` (AtStartup + AtLogOn) → levanta opencode serve + Chamber tunnel
- `ngrok-Diligencia` (AtStartup + AtLogOn) → arranca ngrok dual tunnel

**Verificación post-reboot**: ejecutar el smoke test (arriba).

---

## 📊 Tests E2E de los 3 agents custom

Una vez que opencode serve está vivo, podés testear cada agent:

```powershell
$auth = "Basic ZGlsaWdlbmNpYTpkaWxpZ2VuY2lhLXZhaW8tMjAyNg=="
$body = '{"title":"[e2e] test","agent":"AGENT_NAME"}'
$sess = Invoke-RestMethod -Uri "http://localhost:4096/session" -Method Post -Body $body -ContentType "application/json" -Headers @{Authorization=$auth} -TimeoutSec 15

$msgBody = '{"parts":[{"type":"text","text":"Confirma que estas activo y MiniMax responde."}],"model":{"providerID":"minimax-coding-plan","modelID":"MiniMax-M2.7"}}'
$msg = Invoke-RestMethod -Uri "http://localhost:4096/session/$($sess.id)/message" -Method Post -Body $msgBody -ContentType "application/json" -Headers @{Authorization=$auth} -TimeoutSec 60
$txt = ($msg.parts | Where-Object { $_.type -eq "text" } | Select-Object -First 1).text
Write-Host "RESPUESTA: $txt"
```

Reemplazar `AGENT_NAME` por: `server-admin`, `code-reviewer`, o `project-handler`.

---

## 📁 Files relacionados

- `doc/refs/observability.md` - triggers de monitoreo
- `doc/refs/opencode-troubleshooting.md` - 10 issues frecuentes
- `doc/refs/opencode-schema.md` - schema oficial opencode
- `doc/refs/openchamber-overview.md` - arquitectura Chamber
- `doc/refs/integration-patterns.md` - patrones seguros
- `scripts/smoke-test.ps1` - smoke test automatizado
- `AGENTS.md` R6, R79.1 - reglas de disciplina
- `~/.config/opencode/.diligencia.json` - metadata Diligencia
