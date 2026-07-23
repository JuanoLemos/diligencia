# Diligencia Ola Chamber-First — Migración a funcionalidades nativas de Chamber v1.0

> Planificada: 2026-07-23 | Agentes: @documentador, @consejero, @circuito
> Objetivo: Reemplazar soluciones manuales por funcionalidades nativas de Chamber.
> Precondición: Chamber corriendo desde source en VAIO (Node.js, no Bun).

---

## Arquitectura objetivo

```
Antes:                              Después:
┌──────────────────────┐            ┌──────────────────────┐
│ startup-tunnel.ps1   │     ──→   │ Chamber Tunnel API   │
│ vscode.dev + manual  │     ──→   │ Terminal WS integrado  │
│ worker-log.md        │     ──→   │ SSE events + status   │
│ codebase-mcp local   │     ──→   │ MCP server en Chamber │
│ Skills locales .md   │     ──→   │ Skills vía catalog    │
│ Chamber v1.13.2      │     ──→   │ Chamber v1.16.3       │
└──────────────────────┘            └──────────────────────┘
```

---

## Ola A — Recuperación + Estabilización (1 sesión, ~30 min)

> Ejecutar física o remotamente frente a la VAIO (FELRENA).
> Sin esta ola, ninguna otra es posible.

### A1 — Instalar Node.js 22 LTS

| Campo | Valor |
|---|---|
| Depende de | — |
| OnFail | escalate |
| Esfuerzo | 2 min |

```powershell
winget install OpenJS.NodeJS.LTS --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    winget install OpenJS.NodeJS.22 --accept-package-agreements
}
node --version
# Debe mostrar: v22.x.x
```

Si `winget` no funciona:
```powershell
# Descargar manualmente
$url = "https://nodejs.org/dist/v22.0.0/node-v22.0.0-x64.msi"
$out = "$env:TEMP\node-install.msi"
Invoke-WebRequest -Uri $url -OutFile $out
Start-Process msiexec -ArgumentList "/i $out /qn" -Wait
```

### A2 — Instalar dependencias de openchamber

| Campo | Valor |
|---|---|
| Depende de | A1 |
| OnFail | retry:2 |
| Esfuerzo | 5 min |

```powershell
cd C:\Users\jlemo\openchamber
npm install
```

Nota: Si falla por dependencias nativas (`node-pty`, `better-sqlite3`):
```powershell
npm install --ignore-scripts
npm rebuild
```

### A3 — Aplicar fix de sessionId (2 archivos)

| Campo | Valor |
|---|---|
| Depende de | A2 |
| OnFail | escalate |
| Esfuerzo | 3 min |

**Archivo 1 — `runtime.js`:**

```powershell
$rt = "C:\Users\jlemo\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$content = Get-Content $rt -Raw

$old = '    let sessionID;[\s\S]*?if \(!sessionID\) \{[\s\S]*?throw new Error\(\'failed to create session\'\);\s+\}'
# Buscar el bloque actual (post-fix parcial del MAIN)
if ($content -match 'let sessionID;') {
    Write-Host "runtime.js ya tiene fix parcial. Completando..."
}
$content = $content -replace 'const sessionResponse = await client.session.create', 'let sessionID;
    const reuseSessionId = task.execution?.sessionId;
    if (reuseSessionId) {
      sessionID = reuseSessionId;
    } else {
      const sessionResponse = await client.session.create'
$content = $content -replace 'const sessionID = sessionResponse\?\.data\?\.id;', 'const sessionID = sessionResponse?.data?.id;
    }'
Set-Content $rt $content -Encoding UTF8
"runtime.js OK"
```

**Archivo 2 — `project-config.js`:**

```powershell
$pc = "C:\Users\jlemo\openchamber\packages\web\server\lib\projects\project-config.js"
$content = Get-Content $pc -Raw

# Buscar normalizeExecution y agregar sessionId
$pattern = '\.\.\.\(variant \? \{ variant \} : \{\}\)'
$replacement = '...(variant ? { variant } : {}),
      ...(sessionId ? { sessionId } : {})'

# También asegurar que sessionId se extraiga del input
$extractPattern = 'const variant = asNonEmptyString\(value\.variant\);'
$extractReplacement = 'const variant = asNonEmptyString(value.variant);
    const sessionId = value.sessionId || null;'

if ($content -match $extractPattern) {
    $content = $content -replace $extractPattern, $extractReplacement
}
if ($content -match [regex]::Escape($pattern)) {
    $content = $content -replace [regex]::Escape($pattern), $replacement
}

Set-Content $pc $content -Encoding UTF8
"project-config.js OK"
```

Verificar:
```powershell
Select-String -Path $pc -Pattern "sessionId" | Select-Object LineNumber,Line
```

### A4 — Iniciar Chamber desde source con Node.js

| Campo | Valor |
|---|---|
| Depende de | A3 |
| OnFail | escalate |
| Esfuerzo | 2 min |

```powershell
cd C:\Users\jlemo\openchamber

# Detener Chamber instalado si está corriendo
Get-Process -Name "OpenChamber*" -ErrorAction SilentlyContinue | Stop-Process -Force

# Iniciar desde source
node packages/web/bin/cli.js serve --port 57123
```

Chamber arranca en modo producción desde source. El puerto `57123` coincide con el actual.

### A5 — Verificar scheduled tasks

```powershell
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks

# 3 tareas deben estar activas:
# - VAIO: check-tareas (cada 1 min)
# - VAIO: cloudflared-watchdog (cada 5 min)
# - VAIO: publish-url (cada 1 hora)
```

Si las tareas se perdieron (por reinicio de Chamber), recrearlas:
```powershell
# Recrear las 3 tareas
$env:TEMP = $env:TEMP
$projectId = "path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE"
$api = "http://localhost:57123/api/projects/$projectId/scheduled-tasks"

$tasks = @(
    @{name="VAIO: check-tareas";cron="* * * * *";prompt="Actuá como el VAIO Worker de Diligencia.`n1. git pull en C:\xampp\htdocs\Diligencia`n2. Revisá doc/vaio/tasks/ para tareas sin resultado`n3. Si hay tarea: ejecutala, escribí resultado`n4. git add + commit + push`n5. DONE con resumen"},
    @{name="VAIO: cloudflared-watchdog";cron="*/5 * * * *";prompt="Verificá que cloudflared esté corriendo. Si no: iniciarlo. Si sí: OK con PID"},
    @{name="VAIO: publish-url";cron="0 * * * *";prompt="Actualizá la URL de cloudflared en cloudflared-url.md. Commit + push. DONE"}
)

foreach ($t in $tasks) {
    $body = @{task=@{name=$t.name;enabled=$true;schedule=@{kind="cron";cron=$t.cron;timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.prompt}}} | ConvertTo-Json -Compress
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d $body
}
```

---

## Ola B — Migración Chamber-first (2-3 sesiones, desde MAIN)

> Las sub-olas B1 a B4 son paralelizables (no comparten archivos).
> B5 depende de B1. B6 depende de B1 + B3.

---

### B1 — R72: Tunnel nativo de Chamber

| Campo | Valor |
|---|---|
| Archivos | `doc/vaio/GUIA_RECUPERACION_VAIO.md`, `doc/vaio/VAIO-SCHEDULED.md` |
| Depende de | Ola A |
| OnFail | retry:2 |
| OnSuccess | deprecar `startup-tunnel.ps1` |

**Qué cambia:** En vez de `startup-tunnel.ps1` con `cloudflared.exe`, Chamber gestiona el túnel nativamente:

```powershell
# Iniciar tunnel via API
curl.exe -s -X POST http://localhost:57123/api/openchamber/tunnel/start `
  -H "Content-Type: application/json" `
  -d '{"provider":"cloudflare","mode":"quick"}'

# Obtener URL
curl.exe -s http://localhost:57123/api/openchamber/tunnel/status | ConvertFrom-Json | Select-Object -ExpandProperty url
```

**Beneficios:**
- Chamber diagnostica y gestiona cloudflared solo
- URL accesible vía API sin archivos de estado
- Chamber reinicia el túnel automáticamente tras crash

**Documentación:** Actualizar `GUIA_RECUPERACION_VAIO.md` y `VAIO-SCHEDULED.md` para reflejar el nuevo método.

---

### B2 — R73: Terminal Chamber (reemplazar vscode.dev)

| Campo | Valor |
|---|---|
| Archivos | `doc/guias/GUIA_CONTROL_REMOTO.md` |
| Depende de | Ola A |
| OnFail | skip (exploratorio) |

**Qué cambia:** En vez de abrir vscode.dev para comandos rápidos, usar el terminal de Chamber:

```powershell
# Crear sesión terminal
$session = curl.exe -s -X POST http://localhost:57123/api/terminal/create `
  -H "Content-Type: application/json" `
  -d '{"cwd":"C:\\xampp\\htdocs\\Diligencia","cols":80,"rows":24}' | ConvertFrom-Json

# Conectar WebSocket a ws://localhost:57123/api/terminal/ws
# Enviar bind: {"t":"b","s":"<sessionId>","v":2}
# Enviar comandos como text frames
```

Para uso interactivo, Chamber UI ya muestra el terminal (icono `>_` en barra inferior).

**Evaluar:**
- ¿El terminal de Chamber UI es suficiente para comandos de mantenimiento?
- ¿O se necesita acceso programático vía WebSocket?
- Documentar la decisión en `GUIA_CONTROL_REMOTO.md`

---

### B3 — R75: MCP en Chamber

| Campo | Valor |
|---|---|
| Archivos | `~/.config/opencode/config.json` (Chamber) |
| Depende de | Ola A |
| OnFail | skip (depende de codebase-memory-mcp) |

**Qué cambia:** El servidor `codebase-memory-mcp` (que corre en localhost:9749) se registra como MCP server local en Chamber:

```powershell
$body = @{
    type = "local"
    command = @("node", "C:\Users\jlemo\.config\opencode\agents\codebase-memory-mcp\index.js")
    environment = @{}
    enabled = $true
} | ConvertTo-Json

curl.exe -s -X POST http://localhost:57123/api/config/mcp/codebase-memory `
  -H "Content-Type: application/json" -d $body
```

**Requiere:** Conocer la ruta exacta al servidor MCP (`codebase-memory-mcp`).
**Verificar:** `curl.exe -s http://localhost:57123/api/config/mcp` → debe listar `codebase-memory`.

---

### B4 — R76: Skills publicadas

| Campo | Valor |
|---|---|
| Archivos | `doc/mecanicas/MECANICA-CHAMBER-FIRST.md` |
| Depende de | — |
| OnFail | skip (sin dependencias) |

**Qué cambia:** Las skills locales de Diligencia (`~/.config/opencode/skills/`) se publican en Chamber para que otros proyectos puedan instalarlas:

```powershell
# Listar skills locales
Get-ChildItem "$env:USERPROFILE\.config\opencode\skills" -Directory | Select-Object Name

# Instalar skill via Chamber API
$body = @{
    description = "TDD estricto — RED, GREEN, TRIANGULATE, REFACTOR"
    body = Get-Content "$env:USERPROFILE\.config\opencode\skills\tdd-strict\SKILL.md" -Raw
    scope = "user"
} | ConvertTo-Json

curl.exe -s -X POST http://localhost:57123/api/config/skills/tdd-strict `
  -H "Content-Type: application/json" -d $body
```

---

### B5 — R74: Monitoreo centralizado (SSE + status)

| Campo | Valor |
|---|---|
| Archivos | `doc/vaio/VAIO-SCHEDULED.md` |
| Depende de | B1 (tunnel activo) |
| OnFail | skip (cosmético) |

**Qué cambia:** En vez de `worker-log.md` manual, consultar el estado de Chamber directamente:

```powershell
# Estado global de scheduled tasks
curl.exe -s http://localhost:57123/api/openchamber/scheduled-tasks/status

# Última ejecución de cada task
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | Select-Object name, enabled, @{n="lastRun";e={if ($_.state.lastRunAt) {[datetime]::FromFileTimeUtc($_.state.lastRunAt)} else {"Nunca"}}}

# Tunnel status (desde MAIN vía tunnel URL)
Invoke-WebRequest -Uri "https://URL_TUNNEL/api/openchamber/tunnel/status"
```

---

### B6 — R77: Upgrade Chamber v1.16.3

| Campo | Valor |
|---|---|
| Archivos | `doc/mecanicas/MECANICA-CHAMBER-FIRST.md` |
| Depende de | B1, B3 |
| OnFail | rollback |

**Qué cambia:** Chamber se actualiza de v1.13.2 → v1.16.3. Las nuevas features incluyen permission auto-accept, remote instance sin OpenCode local, SSH nativo.

```bash
cd C:\Users\jlemo\openchamber
git remote add upstream https://github.com/openchamber/openchamber.git 2>$null
git fetch upstream
git merge upstream/main --no-edit
npm install
```

**Riesgo:** El merge puede traer cambios en las APIs que usamos (túneles, scheduled tasks, MCP). Probar en PC Principal primero, luego VAIO.

---

## Mapa de dependencias

```
Ola A (recuperación VAIO)
│
├─ A1 Node.js ─→ A2 npm install ─→ A3 fix 2 archivos ─→ A4 iniciar Chamber ─→ A5 verificar
│
└───────────────────────┬──────────────────────────────┘
                        │
              ┌─────────┼─────────┬─────────┐
              ↓         ↓         ↓         ↓
             B1        B2        B3        B4
              │                  │
              ↓                  ↓
             B5                 B6
```

| Sub-ola | Paralelizable con |
|---|---|
| B1 | B2, B3, B4 |
| B2 | B1, B3, B4 |
| B3 | B1, B2, B4 |
| B4 | B1, B2, B3 |
| B5 | — (depende de B1) |
| B6 | — (depende de B1+B3) |

---

## Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Node.js 22 no disponible para CPU de VAIO | Baja | Alto | Usar Winget o MSI manual |
| `npm install` falla por `better-sqlite3` | Media | Medio | `--ignore-scripts` + `npm rebuild` |
| `node bin/cli.js serve` difiere de `bun server/index.js` | Media | Alto | Probar primero. El `package.json` declara Node.js>=22.0.0 |
| Fix de 2 archivos se pierde con `git merge upstream` | Alta | Medio | Documentar diff. Reaplicar post-upgrade |
| v1.16.3 cambia schema de scheduled tasks | Media | Medio | Probar en PC Principal primero |
| El terminal WS de Chamber no reemplaza completamente a vscode.dev | Media | Bajo | Mantener vscode.dev como fallback documentado |
| CPU sin AVX2 impide Bun (YA CONFIRMADO) | 100% | Alto | Ya migrado a Node.js — superado |

---

## Pre-ejecución

- [ ] Ola A aprobada (usuario presente frente a VAIO)
- [ ] Ola A completada (Chamber corriendo desde source via Node.js)
- [ ] Repo Diligencia actualizado en VAIO (`git pull`)
- [ ] Ola B aprobada (sesiones de MAIN)
- [ ] Cada Bx evaluada independientemente

## Post-ejecución

- [ ] Todas las tareas completadas
- [ ] `startup-tunnel.ps1` deprecado oficialmente (vía header)
- [ ] `worker-log.md` reemplazado por consulta de API
- [ ] `GUIA_RECUPERACION_VAIO.md` actualizada con Node.js
- [ ] Fallos registrados en $BUGS
- [ ] /CBP sugerido en proyecto Diligencia

---

## Archivos afectados

| Archivo | Ola | Acción |
|---|---|---|
| `doc/vaio/startup-tunnel.ps1` | B1 | Deprecar |
| `doc/vaio/cloudflared-url.md` | B1 | Deprecar |
| `doc/vaio/worker-log.md` | B5 | Reemplazar por API |
| `doc/vaio/GUIA_RECUPERACION_VAIO.md` | A, B1 | Actualizar |
| `doc/vaio/VAIO-SCHEDULED.md` | B1, B5 | Actualizar |
| `doc/guias/GUIA_CONTROL_REMOTO.md` | B2 | Actualizar |
| `doc/mecanicas/MECANICA-CHAMBER-FIRST.md` | B3-B6 | Seguimiento |
| `ROADMAP.md` | — | R72-R77 ya agregados |

---

> Generado por `/ola planear` con asistencia de @documentador, @consejero, @circuito.
> Próximo paso: Ejecutar Ola A cuando estés frente a la VAIO.
