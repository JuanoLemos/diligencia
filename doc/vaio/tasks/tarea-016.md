# Tarea 016 — Clonar Chamber source en VAIO (paridad con MAIN)

> Ejecutar en la VAIO. Instala Chamber desde source (mismo setup que PC Principal).
> runtime.js editable sin ASAR.

## Objetivo

Reemplazar Chamber instalado (app.asar) por Chamber desde source code (archivos planos editables).

---

## Paso 1 — Instalar Bun

```powershell
# Descargar e instalar Bun (runtime que usa Chamber)
winget install Bun --accept-package-agreements 2>$null
if ($LASTEXITCODE -ne 0) {
    # Fallback: install manual
    powershell -c "irm https://bun.sh/install.ps1 | iex"
}

# Verificar
bun --version
```

---

## Paso 2 — Clonar openchamber

```powershell
cd C:\Users\USUARIO
git clone https://github.com/openchamber/openchamber.git openchamber
cd openchamber
```

Si el repo pide autenticación:
```powershell
git clone https://github.com/openchamber/openchamber.git openchamber 2>&1
```

---

## Paso 3 — Instalar dependencias

```powershell
cd C:\Users\USUARIO\openchamber
bun install
```

---

## Paso 4 — Aplicar el fix de runtime.js

```powershell
$rt = "C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js"
$content = Get-Content -Path $rt -Raw

$old = '    const sessionResponse = await client.session.create\(\{[\s\S]*?\n    \}\);[\s\S]*?    if \(!sessionID\) \{'
$new = @'
    let sessionID;
    if (task.execution?.sessionId) {
      sessionID = task.execution.sessionId;
    } else {
      const sessionResponse = await client.session.create({
        directory: projectPath,
        title,
      });
      sessionID = sessionResponse?.data?.id;
      if (!sessionID) {
'@

if ($content -match $old) {
    $content = $content -replace $old, $new
    Set-Content -Path $rt -Value $content -Encoding UTF8
    "FIX APLICADO"
} else {
    "FIX MANUAL — abrir $rt y buscar: const sessionResponse = await client.session.create({"
}
```

---

## Paso 5 — Iniciar Chamber desde source

```powershell
cd C:\Users\USUARIO\openchamber
bun run dev --port 57123
```

Chamber arranca desde source. El runtime.js es editable directamente.

---

## Paso 6 — Verificar scheduled tasks

```powershell
curl.exe -s http://localhost:57123/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

---

## Escribir resultado

```powershell
$ok = @"
# Resultado 016 — Chamber source clonado y runtime.js editable

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Acción | Resultado |
|---|---|
| Bun instalado | SI/NO |
| OpenChamber clonado | SI/NO |
| Dependencias instaladas | SI/NO |
| runtime.js fix aplicado | SI/NO |
| Chamber corriendo desde source | SI/NO |

## Notas

Chamber ahora corre desde source. runtime.js en:
C:\Users\USUARIO\openchamber\packages\web\server\lib\scheduled-tasks\runtime.js

Mismo setup que la PC Principal.
"@
Set-Content -Path "doc\vaio\results\resultado-016.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-016.md
git commit -m "VAIO: resultado tarea 016 — Chamber source clonado"
git pull --rebase
git push
```
