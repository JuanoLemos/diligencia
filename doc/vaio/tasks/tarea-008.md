# Tarea 008 — Diagnosticar URL cloudflared no accesible desde afuera

> Ejecutar en la VAIO. No tocar MarketAI ni otros proyectos.

## Objetivo

La URL `https://accuracy-sept-remain-replaced.trycloudflare.com` funciona desde la VAIO pero NO desde la PC Principal. Diagnosticar y dejar el túnel operativo.

---

## Paso 1 — Estado actual de cloudflared

```powershell
# 1a — Procesos
Get-Process -Name "cloudflared*" -ErrorAction SilentlyContinue

# 1b — PID actual comparado con el último registrado
$savedUrl = Get-Content "C:\xampp\htdocs\Diligencia\doc\vaio\cloudflared-url.md" -Raw
Write-Host "URL guardada:"
$savedUrl
```

---

## Paso 2 — ¿Chamber responde localmente?

```powershell
curl.exe -s -o NUL -w "HTTP: %{http_code}\n" http://localhost:57123
```

Debe devolver `HTTP: 200`.

---

## Paso 3 — Diagnosticar el túnel desde adentro

```powershell
# Probar la URL actual desde la VAIO misma
curl.exe -s -o NUL -w "HTTP: %{http_code}\n" https://accuracy-sept-remain-replaced.trycloudflare.com
```

Si da `HTTP: 200` → el túnel funciona, el problema es externo (DNS regional, firewall de Cloudflare).
Si da error → el túnel murió.

---

## Paso 4 — Si el túnel murió: forzar restart público

Ejecutar startup-tunnel.ps1 para capturar y publicar una URL fresca:

```powershell
cd C:\xampp\htdocs\Diligencia
powershell -File doc\vaio\startup-tunnel.ps1
```

Verificar resultado:
```powershell
cat doc\vaio\cloudflared-url.md
```

---

## Paso 5 — Verificación cruzada

Después de publicar la nueva URL, verificar DESDE ADENTRO del túnel:

```powershell
$nuevaUrl = (Select-String -Path "C:\xampp\htdocs\Diligencia\doc\vaio\cloudflared-url.md" -Pattern "https://").Line -replace '.*\| ', ''
curl.exe -s -o NUL -w "TUNNEL: %{http_code}\n" -m 10 $nuevaUrl
```

Si esto da `TUNNEL: 200` → la URL es válida. Si falla → repetir Paso 4 o verificar que Chamber sigue en `:57123`.

---

## Escribir resultado

Crear `doc/vaio/results/resultado-008.md`:

```
# Resultado 008

**Fecha:** [fecha/hora UTC]

## Resumen

| Campo | Valor |
|---|---|
| cloudflared vivo | SI/NO — PID |
| Chamber local | 200/ERROR |
| Túnel desde adentro | 200/ERROR |
| Nueva URL publicada | SI/NO — [URL] |
| URL verifica desde adentro | SI/NO |

## Diagnóstico

[explicación de por qué no funcionaba desde afuera]

## URL funcional actual

[URL de trycloudflare]
```

---

## Commit + push

```powershell
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/
git commit -m "VAIO: resultado tarea 008 — diagnostico URL cloudflared"
git pull --rebase
git push
```
