# Tarea 002 — Reparar DNS + Iniciar Chamber + configurar tuneles

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.
>
> **IMPORTANTE:** El paso 1 requiere PowerShell como ADMINISTRADOR.
> Click derecho en Inicio → "Windows PowerShell (Administrador)" o "Terminal (Administrador)".

## Objetivo

1. Reparar DNS (requiere Admin — tarea 001 falló por falta de permisos)
2. Ubicar Chamber.exe en la VAIO
3. Iniciarlo
4. Renombrar tunnel VS Code a "VAIO-Server"
5. Activar cloudflared y capturar URL de trycloudflare

## Comandos (en orden)

### 1. Reparar DNS ⚠️ REQUIERE ADMINISTRADOR

```powershell
# Ver interfaz activa
Get-NetAdapter | Where-Object Status -eq "Up" | Format-Table Name

# Cambiar DNS (reemplazar <NOMBRE> por el nombre real, ej: "Wi-Fi")
Set-DnsClientServerAddress -InterfaceAlias "<NOMBRE>" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Ejemplo:
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Verificar:
```powershell
nslookup api.trycloudflare.com
```

Debe devolver una IP. Si sigue diciendo "Non-existent domain", DNS no se cambió.

### 2. Ubicar Chamber.exe

Buscar en rutas comunes primero:

```powershell
$rutas = @(
    "C:\Program Files\Chamber\Chamber.exe",
    "C:\Program Files (x86)\Chamber\Chamber.exe",
    "$env:LOCALAPPDATA\Programs\Chamber\Chamber.exe",
    "$env:USERPROFILE\OneDrive\Desktop\openchamber\Chamber.exe",
    "$env:USERPROFILE\Desktop\openchamber\Chamber.exe"
)
foreach ($r in $rutas) {
    $expandida = [System.Environment]::ExpandEnvironmentVariables($r)
    if (Test-Path $expandida) {
        Write-Host "ENCONTRADO: $expandida"
        $global:chamberPath = $expandida
        break
    } else {
        Write-Host "NO: $expandida"
    }
}
```

Si no aparece en ninguna, buscar en todo C: (puede tardar unos minutos):

```powershell
Get-ChildItem -Path C:\ -Filter Chamber.exe -Recurse -ErrorAction SilentlyContinue -Depth 6 | Select-Object -First 1 -ExpandProperty FullName
```

Anotar la ruta exacta donde está Chamber.exe.

### 3. Iniciar Chamber

```powershell
Start-Process -FilePath "<RUTA_DE_CHAMBER.EXE>"
```

Reemplazar `<RUTA_DE_CHAMBER.EXE>` por la ruta real encontrada en el paso 1.

Ejemplo:
```powershell
Start-Process -FilePath "C:\Program Files\Chamber\Chamber.exe"
```

### 4. Verificar que Chamber está corriendo

Esperar 5 segundos y verificar:

```powershell
Start-Sleep -Seconds 5
netstat -ano | findstr :3000
```

Si no muestra nada, Chamber no inició. Revisar si hay algún error o ventana de diálogo.

### 5. Renombrar tunnel VS Code

```powershell
code tunnel rename VAIO-Server
```

Si falla con "already exists" o similar, verificar nombre actual:
```powershell
code tunnel --help
```

### 6. Activar cloudflared

```powershell
cloudflared tunnel --url http://localhost:3000
```

**IMPORTANTE:** Este comando se queda corriendo (muestra logs continuos). Dejar la ventana abierta.

Anotar la URL que aparece, algo como:
```
https://random-name.trycloudflare.com
```

### 7. Escribir resultado

Crear `doc/vaio/results/resultado-002.md` con este formato:

```
# Resultado 002

DNS reparado: [SI/NO — servidor DNS actual]
Ruta Chamber.exe: [pegar ruta]
Chamber corriendo en :3000: [SI/NO]
Tunnel VS Code renombrado: [SI/NO — nombre actual]
URL cloudflared: [pegar URL de trycloudflare]
Errores: [pegar errores si los hubo]
```

### 8. Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 002"
git pull --rebase
git push
```
