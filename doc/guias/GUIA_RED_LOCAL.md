# GUIA_RED_LOCAL — Conectar dos PCs Windows en red local v1.0

> Para cuando tenes dos PCs en la misma WiFi y queres trabajar en los proyectos
> desde ambas SIN instalar stacks ni depender de virtualizacion.

---

## Requisitos

- Dos PCs Windows 10/11 en la misma red WiFi (mismo router)
- VS Code en ambas (ya lo tenes)
- La PC principal tiene todo el stack: XAMPP, Docker, Node, Python, los proyectos
- La PC secundaria SOLO necesita VS Code (+ extension Remote SSH)

---

## Paso 1: Activar SSH en la PC principal (1 min)

Abrir PowerShell **como Administrador** en la PC PRINCIPAL y pegar:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Abrir puerto 22 en firewall
New-NetFirewallRule -Name "SSH Open" -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

Verificar que funciona:

```powershell
Get-Service sshd
```

Debe mostrar `Status: Running`.

---

## Paso 2: Averiguar la IP local de la PC principal

En la PC PRINCIPAL:

```powershell
ipconfig | Select-String "IPv4"
```

Anotar la IP que aparece. Normalmente es algo como `192.168.1.X` o `192.168.0.X`.

Mi PC ahora mismo:

```powershell
$env:COMPUTERNAME + " IP: " + (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -like "*WiFi*" -or $_.InterfaceAlias -like "*Ethernet*"} | Select-Object -First 1).IPAddress
```

---

## Paso 3: Conectar desde la PC secundaria (2 min)

En la PC SECUNDARIA:

1. Abrir VS Code
2. Ir a Extensiones (`Ctrl+Shift+X`) → buscar e instalar **"Remote - SSH"** (`ms-vscode-remote.remote-ssh`)
3. `Ctrl+Shift+P` → escribir **"Remote-SSH: Connect to Host..."** → Enter
4. Ingresar: `USUARIO_DE_LA_PRINCIPAL@192.168.X.X`
   - El usuario es el que usas para iniciar sesion en la PC principal (ej: `jlemo`, `Admin`)
   - La IP es la que anotaste en el Paso 2
5. Elegir la configuracion SSH por defecto (`%USERPROFILE%\.ssh\config`)
6. Ingresar la contraseña de la PC principal cuando la pida
7. VS Code se conecta, abre una ventana nueva, y en la barra de abajo dice **"SSH: 192.168.X.X"**

---

## Paso 4: Abrir los proyectos (1 min)

1. En la ventana de VS Code (ya conectada remotamente):
   - `File` → `Open Folder`
   - Navegar hasta `C:\xampp\htdocs\` o la carpeta donde tenes los proyectos
   - Elegir el proyecto (ej: Nemesis, +RM, Diligencia)

2. Abrir terminal integrada (`Ctrl+Ñ` o `` Ctrl+` ``):
   - El terminal corre EN la PC principal
   - Podes ejecutar cualquier comando: `php -S`, `npm run dev`, `docker compose up`
   - Todo corre en la principal

---

## Paso 5: Testear desde la PC secundaria

En el navegador de la PC SECUNDARIA:

| Proyecto | URL |
|---|---|
| +RM | `http://192.168.X.X:8585` |
| MarketAI | `http://192.168.X.X:8050` |
| conquisitare | `http://192.168.X.X:3000` |
| Nemesis | `http://192.168.X.X:3005` |
| Chamber (si hosteado) | `http://192.168.X.X` |

Si Chamber esta hosteado en la principal, podes abrirlo en el navegador de la secundaria y usar todos los paneles.

---

## Comandos utiles para mantenimiento

### Ver IP local de la principal (si cambio)

```powershell
ipconfig | findstr IPv4
```

### Saber el usuario de la principal

```powershell
whoami
```

### Reiniciar SSH si deja de funcionar

```powershell
Restart-Service sshd
```

### Probar conexion desde la secundaria

```powershell
ssh USUARIO@192.168.X.X
```

Si pide contraseña y entras, todo funciona.

---

## Preguntas frecuentes

### ¿Necesito virtualizacion/BIOS?

No. SSH funciona en cualquier Windows 10/11 sin Hyper-V, sin WSL, sin cambios de BIOS.

### ¿Puedo acceder desde fuera de mi casa?

No con este metodo. SSH esta limitado a la red local. Para acceso remoto desde cualquier lado, usar VS Code Tunnels o Cloudflare Tunnel — ver `GUIA_CONTROL_REMOTO.md`.

### ¿Que pasa si la PC principal se apaga?

No podes trabajar. La secundaria solo accede a los recursos de la principal. Si necesitas trabajar independientemente, clona el repo y trabaja local con Node.js (proyectos que lo soporten).

### ¿Necesito XAMPP en la secundaria?

No. Todo el stack corre en la principal. La secundaria solo edita codigo.

### ¿La PC secundaria puede ejecutar agentes de Diligencia?

Si, si OpenCode esta instalado en la secundaria y configurado para usar la PC principal como CWD. Pero es mas simple ejecutar los agentes desde el MAIN en la PC principal y solo usar la secundaria para editar y testear via navegador.

---

## Archivos relacionados

- `GUIA_CONTROL_REMOTO.md` — acceso remoto via VS Code Tunnels + Cloudflare Tunnel
- `GUIA_HOSTING_VPS.md` — version para servidor en la nube
- `ROADMAP.md` — R40 (Chamber remoto), R52 (estudio hosting)
