# Tarea 001 — Activar cloudflared para Chamber

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.

## Comandos (en orden)

### 1. Reparar DNS
```powershell
Get-NetAdapter | Where-Object Status -eq "Up" | Format-Table Name
```

Anotar el nombre de la interfaz activa. Luego:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "<NOMBRE>" -ServerAddresses ("1.1.1.1", "8.8.8.8")
```

Reemplazar `<NOMBRE>` por el nombre real (ej: "WiFi").

### 2. Verificar DNS
```powershell
nslookup google.com
```

### 3. Activar cloudflared
```powershell
cloudflared tunnel --url http://localhost:3000
```

Anotar la URL que aparece (algo como `https://random-name.trycloudflare.com`).

### 4. Escribir resultado
Abrir `doc/vaio/results/resultado-001.md` y pegar:

```
# Resultado 001

cloudflared: [SI/NO]
URL: [pegar URL si funciona]
Errores: [pegar errores si no funciona]
```

### 5. Commit + push
```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 001"
git pull --rebase
git push
```
