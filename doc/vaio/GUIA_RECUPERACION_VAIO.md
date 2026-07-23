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

### Opción B — Migrar a source code (si querés paridad con MAIN)

**Tiempo estimado:** 15-20 min

```powershell
# 1. Instalar Bun
powershell -c "irm https://bun.sh/install.ps1 | iex"
bun --version

# 2. Clonar openchamber
cd C:\Users\USUARIO
git clone https://github.com/openchamber/openchamber.git openchamber
cd openchamber

# 3. Dependencias
bun install

# 4. Aplicar fix de runtime.js
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$content = Get-Content $rt -Raw
$content = $content -replace 'const sessionResponse = await client.session.create', 'let sessionID;
if (task.execution?.sessionId) {
  sessionID = task.execution.sessionId;
} else {
  const sessionResponse = await client.session.create'
$content = $content -replace 'const sessionID = sessionResponse\?\.data\?\.id;', 'const sessionID = sessionResponse?.data?.id;
  }'
Set-Content $rt $content -Encoding UTF8
"FIX APLICADO"

# 5. Iniciar Chamber desde source
bun run dev --port 57123
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
