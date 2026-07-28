# Tarea 039 — Instalar start-chamber.ps1 como startup auto-curativo

> **Objetivo:** Reemplazar el arranque manual de Chamber por el script auto-curativo.
> `doc/vaio/start-chamber.ps1` ya existe en el repo. Solo hay que conectarlo al Startup de Windows.

## Paso 1 — Verificar que start-chamber.ps1 está en el repo

```powershell
if (Test-Path "C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1") {
    "EXISTE: C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1"
} else { "NO EXISTE — hacer git pull" }
```

## Paso 2 — Detener Chamber actual y probar arranque auto-curativo

```powershell
# Detener Chamber source actual (en 57125)
$proc = netstat -ano | Select-String ":57125.*LISTENING"
if ($proc) {
    $pid = ($proc -split '\s+')[-1]
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    "Chamber detenido"
}

# Iniciar con el script auto-curativo
powershell -ExecutionPolicy Bypass -File "C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1"
```

## Paso 3 — Instalar en Startup folder de Windows

```powershell
$scriptPath = "C:\xampp\htdocs\Diligencia\doc\vaio\start-chamber.ps1"
$startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = "$startupDir\VAIO-Chamber.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
$shortcut.WindowStyle = 7  # Minimized
$shortcut.Description = "Arranque auto-curativo de Chamber (check-tareas + tunnel)"
$shortcut.Save()

"Shortcut creado: $shortcutPath"
```

## Paso 4 — Verificar que funciona

```powershell
# Probar que Chamber responde
curl.exe -s http://localhost:57125/api/openchamber/tunnel/status

# Probar que hay tasks
curl.exe -s http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | Select-Object -ExpandProperty tasks | Select-Object name, enabled

# Verificar tunnel activo
curl.exe -s http://localhost:57125/api/openchamber/tunnel/status | ConvertFrom-Json | Select-Object active, url
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 039 — Auto-curativo instalado

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| start-chamber.ps1 ejecutado | SI |
| check-tareas activa | SI/NO |
| publish-url activa | SI/NO |
| Tunnel URL | [URL] |
| Startup shortcut creado | SI/NO |
"@
Set-Content -Path "doc\vaio\results\resultado-039.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-039.md
git commit -m "VAIO: resultado tarea 039 — auto-curativo instalado"
git pull --rebase
git push
```
