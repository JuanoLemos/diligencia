# GUIA_HOSTING_VPS — De 0 a servidor con $PROYECTOS + Chamber v1.0

> Para gente que no sabe nada de servidores. Cada paso tiene el comando exacto.

---

## Conceptos clave (en criollo)

| Término | Qué es |
|---|---|
| **VPS** | Una computadora alquilada 24/7 en un data center. Sin monitor, siempre prendida. |
| **SSH** | Forma de conectarte a esa computadora desde tu terminal. Como escritorio remoto pero solo texto. |
| **Puerto** | Una "puerta" numerada. Puerto 80 = web, 443 = web seguro, 22 = SSH. Cada servicio usa el suyo. |
| **Docker** | Empaqueta una app con todo lo que necesita para funcionar. "En mi máquina funciona" → nunca más. |
| **Reverse proxy** | Un recepcionista que recibe todo el tráfico en puerto 80/443 y lo redirige al servicio correcto según la URL. |
| **Caddy** | Reverse proxy que además pone HTTPS automático (candadito verde). Sin configurar nada. |

---

## Fase 1: Contratar el VPS

### Opción A: Hetzner (recomendado — $4.39/mo)

1. Ir a https://www.hetzner.com/cloud
2. Click "Sign Up" arriba derecha
3. Completar datos. Pedirá verificación (DNI/pasaporte).
4. Una vez aprobado: "Cloud" → "Create Server"
5. Configurar:
   - **Location**: Nuremberg o Falkenstein (más baratos)
   - **Image**: Ubuntu 24.04 LTS
   - **Type**: CX22 (2 vCPU, 4 GB RAM, 40 GB SSD) → **$4.39/mo**
   - **SSH Key**: saltar (usaremos contraseña)
6. Click "Create & Buy Now"
7. Te dan una IP (ej: `142.93.45.12`) y una contraseña root.

### Opción B: DigitalOcean (más fácil, $12/mo)

1. Ir a https://www.digitalocean.com
2. Sign Up → email + tarjeta
3. "Create" → "Droplets"
4. Configurar:
   - **Region**: New York o San Francisco
   - **Image**: Ubuntu 24.04 LTS
   - **Size**: Basic → Regular → $12/mo
   - **Auth**: Password
5. "Create Droplet"
6. Te llega un email con IP y contraseña.

---

## Fase 2: Conectarse la primera vez

### Desde PowerShell (Windows 10/11)

```powershell
ssh root@<LA_IP_DEL_SERVIDOR>
```

Ejemplo: `ssh root@142.93.45.12`

La primera vez pregunta "Are you sure?" — escribir `yes` + Enter.

Te pide la contraseña (la del panel de Hetzner/DigitalOcean).

### Si usás PuTTY (alternativa)

1. Descargar de https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
2. Buscar `putty-64bit-installer.msi`, instalar
3. En "Host Name" poner la IP, click "Open"

### Cambiar contraseña root

```bash
passwd
```
Elegí una que recuerdes. Anotala.

---

## Fase 3: Seguridad básica

Una sola línea a la vez en la terminal SSH:

```bash
apt update && apt upgrade -y
```
(Te va a pedir confirmación un par de veces. Responder Y + Enter.)

```bash
apt install ufw -y
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable
```
Responde Y cuando pregunte "Proceed with operation?".

Verificar:
```bash
ufw status
```
Debe mostrar: `Status: active` y las 3 reglas.

---

## Fase 4: Instalar Docker

```bash
curl -fsSL https://get.docker.com | sh
```

```bash
usermod -aG docker $USER
```

Cerrar sesión y volver a entrar (la conexión SSH se corta):

```powershell
ssh root@<LA_IP>
```

Verificar:
```bash
docker --version
docker compose version
```

Ambos deben mostrar números de versión. Si `docker compose` da error, probar `docker-compose` (con guión).

---

## Fase 5: Instalar todo lo demás

```bash
# Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install nodejs -y

# Python 3
apt install python3 python3-pip python3-venv -y

# PHP 8.3
apt install php8.3 php8.3-cli php8.3-fpm -y

# Git
apt install git -y

# Caddy (reverse proxy con SSL automático)
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update && apt install caddy -y
```

---

## Fase 6: Configurar Caddy (el recepcionista web)

```bash
nano /etc/caddy/Caddyfile
```

Se abre un editor. Borrar TODO lo que tenga (Ctrl+K varias veces) y pegar esto exactamente:

```
:80 {
    # +RM — Dashboard
    handle /rm/* {
        reverse_proxy localhost:8585
    }

    # MarketAI — Trading
    handle /market/* {
        reverse_proxy localhost:8050
    }

    # conquisitare — Juego
    handle /conquis/* {
        reverse_proxy localhost:3000
    }

    # nemesis — Detective RPG
    handle /nemesis/* {
        reverse_proxy localhost:3005
    }

    # Chamber — Consola central (raíz)
    handle {
        reverse_proxy localhost:3001
    }
}
```

Guardar: `Ctrl+O` → Enter → `Ctrl+X`.

Reiniciar Caddy:
```bash
systemctl restart caddy
```

> Sin dominio propio, funciona solo en HTTP (puerto 80). Cuando tengas dominio, Caddy pone HTTPS solo.

---

## Fase 7: Bajar los proyectos al servidor

Crear carpeta donde vivirán:
```bash
mkdir -p /opt/proyectos
```

Clonar cada repositorio (necesitás las URLs de GitHub o copiar los ZIPs):

```bash
cd /opt/proyectos

git clone https://github.com/JuanoLemos/nemesis.git
# Para +RM, MarketAI, conquisitare:
git clone <URL_DE_CADA_REPO>
# Chamber:
git clone <URL_DE_OPENCHAMBER>
```

Si los repos no están en GitHub: usar WinSCP.

### Alternativa: subir archivos con WinSCP

1. Descargar https://winscp.net/ → Download → Instalar
2. Abrir → "New Site" → Protocol: SFTP
3. Host: IP del servidor, Usuario: root, Contraseña: la tuya
4. Login → arrastrar carpetas desde tu PC a `/opt/proyectos/`

---

## Fase 8: Nemesis (ya tiene Docker, es el más fácil)

```bash
cd /opt/proyectos/nemesis
docker build -t nemesis .
mkdir -p /data/nemesis
docker run -d \
  --name nemesis \
  --restart always \
  -p 3005:3005 \
  -v /data/nemesis:/data \
  -e NODE_ENV=production \
  -e PORT=3005 \
  -e DATABASE_PATH=/data/nemesis.db \
  nemesis
```

Probar:
```bash
curl http://localhost:3005/health
```
Debería responder algo que no sea "Connection refused".

---

## Fase 9: Chamber (la consola central)

```bash
cd /opt/proyectos/openchamber

# Build Docker
docker build -t chamber .

# Ejecutar
docker run -d \
  --name chamber \
  --restart always \
  -p 3001:3000 \
  -v /data/chamber:/data \
  chamber
```

Abrir navegador: `http://<IP_DEL_SERVIDOR>` — deberías ver Chamber.

---

## Fase 10: +RM (PHP, sencillo)

Crear un servicio systemd para que el servidor PHP arranque solo:

```bash
nano /etc/systemd/system/rm.service
```

Pegar:

```
[Unit]
Description=+RM Dashboard
After=network.target

[Service]
ExecStart=php -S 0.0.0.0:8585 -t /opt/proyectos/+RM
WorkingDirectory=/opt/proyectos/+RM
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

Guardar y activar:

```bash
systemctl daemon-reload
systemctl enable rm
systemctl start rm
```

Probar: `curl http://localhost:8585`

---

## Fase 11: MarketAI (Python, necesita Dockerfile)

Crear Dockerfile:

```bash
nano /opt/proyectos/MarketAI/Dockerfile
```

Pegar:
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8050
CMD ["python", "orchestrator.py", "--mode", "loop"]
```

Construir y ejecutar:

```bash
cd /opt/proyectos/MarketAI
docker build -t marketai .
docker run -d \
  --name marketai \
  --restart always \
  -p 8050:8050 \
  -v /opt/proyectos/MarketAI/data:/app/data \
  marketai
```

---

## Fase 12: conquisitare (Node.js + WebSocket)

```bash
cd /opt/proyectos/conquisitare

# Dockerfile
nano Dockerfile
```

Pegar:
```dockerfile
FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/server/index.js"]
```

Construir y ejecutar:

```bash
docker build -t conquisitare .
docker run -d \
  --name conquisitare \
  --restart always \
  -p 3000:3000 \
  conquisitare
```

---

## Fase 13: Verificar todo

```bash
# Listar todos los servicios
docker ps
```

Debe mostrar 4 contenedores: nemesis, chamber, marketai, conquisitare.

Además: `systemctl status rm` → debe mostrar "active (running)".

Probar cada uno desde el servidor:

```bash
curl http://localhost:8585     # +RM
curl http://localhost:8050     # MarketAI
curl http://localhost:3000     # conquisitare
curl http://localhost:3005     # nemesis
curl http://localhost:3001     # Chamber
```

Ninguno debe decir "Connection refused". Si alguno falla, revisar logs:

```bash
docker logs <nombre_del_contenedor> --tail 20
```

---

## Fase 14: Mantenimiento diario

### Comandos útiles

```bash
# Ver qué está corriendo
docker ps

# Ver logs en vivo (Ctrl+C para salir)
docker logs chamber --tail 50 -f

# Reiniciar un servicio
docker restart nemesis

# Detener un servicio
docker stop marketai

# Ver recursos del servidor (instalar: apt install htop -y)
htop
```

### Actualizar proyectos después de cambios

```bash
cd /opt/proyectos/nemesis
git pull                    # bajar código nuevo
docker stop nemesis
docker rm nemesis
docker build -t nemesis .
docker run -d --name nemesis --restart always -p 3005:3005 -v /data/nemesis:/data nemesis
```

### Backups automáticos

```bash
crontab -e
```

Agregar al final del archivo:

```
0 3 * * * cp /data/nemesis/nemesis.db /root/backups/nemesis-$(date +\%Y\%m\%d).db
2 3 * * * cp /data/chamber/*.db /root/backups/chamber-$(date +\%Y\%m\%d).db
```

Esto copia las bases de datos todos los días a las 3 AM en `/root/backups/`.

---

## Checklist de verificación final

- [ ] VPS contratado (Hetzner $4.39 o DigitalOcean $12)
- [ ] IP del servidor anotada
- [ ] Contraseña root anotada
- [ ] Conexión SSH funciona
- [ ] Firewall activo (puertos 22, 80, 443)
- [ ] Docker instalado y funcionando
- [ ] Caddy configurado y corriendo
- [ ] Nemesis corriendo en puerto 3005
- [ ] Chamber corriendo en puerto 3001 (visible en raíz)
- [ ] +RM corriendo en puerto 8585
- [ ] MarketAI corriendo en puerto 8050
- [ ] conquisitare corriendo en puerto 3000
- [ ] Todos responden a `curl localhost:PUERTO`
- [ ] Navegador muestra algo en `http://IP/`
