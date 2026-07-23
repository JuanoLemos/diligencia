# GUIA_RECUPERACION_VAIO.md — Recovery Checklist

> Ejecutar cuando estés físicamente frente a la VAIO.
> Orden: de lo urgente a lo definitivo.

---

## Fase 1 — Estabilizar (5 min)

### 1.1 — Cancelar procesos colgados

```powershell
# Cerrar todo lo que esté colgado
Get-Process -Name "winget" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "bun*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "opencode*" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "node*" -ErrorAction SilentlyContinue | Stop-Process -Force
```

### 1.2 — Verificar que todo se detuvo

```powershell
Get-Process -Name "OpenChamber*", "opencode*", "bun*", "winget*" -ErrorAction SilentlyContinue
# Esto debe mostrar: (no se encontraron procesos)
```

### 1.3 — Verificar red

```powershell
nslookup github.com
```

### 1.4 — Verificar repo Diligencia

```powershell
cd C:\xampp\htdocs\Diligencia
git status
git fetch
```

---

## Fase 2 — Decidir ruta

### Opción A — Volver a la app instalada (rápida, recomendada si no hay apuro por el source)

```powershell
# Solo reiniciar Chamber desde el acceso directo
Start-Process -FilePath "$env:LOCALAPPDATA\Programs\@openchamberelectron\OpenChamber.exe"
```

El sistema vuelve a funcionar como antes. Las scheduled tasks se reactivan automáticamente.

### Opción B — Migrar a source con Node.js (recomendada si querés paridad con MAIN)

> ⚠️ La CPU de la VAIO no tiene AVX2 — Bun no funciona. Usamos Node.js.

**Tiempo estimado:** 10-15 min

```powershell
# 0. El repo ya está clonado de la tarea-016
cd C:\Users\USUARIO\openchamber

# 1. Instalar Node.js 22 LTS (si no está)
node --version  # si falla, instalar:
# winget install OpenJS.NodeJS.LTS
# O descargar manual: https://nodejs.org/dist/v22.0.0/node-v22.0.0-x64.msi

# 2. Dependencias con npm
npm install

# 3. Aplicar fix de runtime.js + project-config.js
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$content = Get-Content $rt -Raw
$content = $content -replace 'const sessionResponse = await client.session.create', 'let sessionID;
    const reuseSessionId = task.execution?.sessionId;
    if (reuseSessionId) { sessionID = reuseSessionId; } else {
      const sessionResponse = await client.session.create'
$content = $content -replace 'const sessionID = sessionResponse\?\.data\?\.id;', 'const sessionID = sessionResponse?.data?.id;
    }'
Set-Content $rt $content -Encoding UTF8

$pc = "C:\Users\USUARIO\openchamber\packages\web\server\lib\projects\project-config.js"
$content = Get-Content $pc -Raw
$content = $content -replace 'const variant = asNonEmptyString\(value\.variant\);', 'const variant = asNonEmptyString(value.variant);
    const sessionId = value.sessionId || null;'
$content = $content -replace '\.\.\.\(variant \? \{ variant \} : \{\}\)', '...(variant ? { variant } : {}),
      ...(sessionId ? { sessionId } : {})'
Set-Content $pc $content -Encoding UTF8
"AMBOS FIXES APLICADOS"

# 4. Iniciar Chamber desde source con Node.js (NO Bun)
node packages/web/bin/cli.js serve --port 57123
```

---

## Fase 3 — Verificar (post-recuperación)

```powershell
# Chamber responde?
curl.exe -s http://localhost:57123/api/openchamber/scheduled-tasks/status

# Scheduled tasks activas?
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | Select-Object -ExpandProperty length

# Mis tareas?
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | Select-Object -First 3 | Format-Table name, enabled, schedule
```

---

## Fase 4 — Commit de recuperación

Cuando todo funcione, avisame y desde acá creo una tarea de prueba para verificar que el worker responde.
