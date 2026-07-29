# Tarea 042 — Post-update Chamber VAIO

> Chamber fue actualizado en VAIO. Verificar que todo sigue funcionando y re-aplicar fixes.

## Paso 1 — Verificar Chamber

```powershell
# ¿Chamber source responde?
$r = curl.exe -s http://localhost:57125/api/openchamber/tunnel/status 2>$null
if ($r) { "Source en 57125: OK" } else { "ERROR: no responde" }

# ¿Chamber Electron responde?
$r2 = curl.exe -s http://localhost:57123/api/openchamber/tunnel/status 2>$null
if ($r2) { "Electron en 57123: OK" } else { "Electron: OK (sin API — normal si no se usa)" }
```

## Paso 2 — Verificar scheduled tasks en source

```powershell
$api = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
Write-Host "Tasks: $($tasks.Count)"
if ($tasks.Count -eq 0) {
    Write-Host "SIN TASKS — recreando..."
    # check-tareas
    $prompt = "Ejecutá secuencialmente sin interpretar.`n1. cd C:\xampp\htdocs\Diligencia && git pull --rebase`n2. Buscá tareas en doc/vaio/tasks/ sin resultado`n3. Si hay: leé la tarea, ejecutá los comandos, escribí resultado`n4. git add doc/vaio/results/ && git commit -m 'VAIO: resultado' && git push"
    $body = @{task=@{name="VAIO: check-tareas";enabled=$true;schedule=@{kind="cron";cron="* * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\042-check.json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\042-check.json" | Out-Null
    
    # publish-url
    $prompt2 = "Leé URL de cloudflared.`n1. Get-Content `$env:TEMP\cloudflared-url.log`n2. Extraé https://*.trycloudflare.com`n3. Escribí en doc/vaio/cloudflared-url-vaio.md`n4. git add + commit + push"
    $body2 = @{task=@{name="VAIO: publish-url";enabled=$true;schedule=@{kind="cron";cron="0 * * * *";timezone="UTC"};execution=@{providerID="deepseek";modelID="deepseek-v4-pro";prompt=$prompt2}}} | ConvertTo-Json -Depth 10
    $body2 | Set-Content "$env:TEMP\042-pub.json" -Encoding UTF8 -Force
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\042-pub.json" | Out-Null
    "Tasks recreadas"
} else {
    $tasks | Select-Object name, enabled | Format-Table
}
```

## Paso 3 — Fijar sessionId

```powershell
Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
$sid = $ct.state.lastSessionId
if ($sid) {
    foreach ($t in $tasks) {
        $p = $t.execution.prompt
        $fix = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$sid;providerID="deepseek";modelID="deepseek-v4-pro";prompt=$p}}} | ConvertTo-Json -Depth 10
        $fix | Set-Content "$env:TEMP\042-fix-$($t.id).json" -Encoding UTF8 -Force
        curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\042-fix-$($t.id).json" | Out-Null
    }
    "sessionId: $sid"
}
```

## Paso 4 — Re-aplicar tray fix al ASAR del Electron EXE

```powershell
$asarPath = "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar"
if (-not (Test-Path $asarPath)) {
    "ASAR no encontrado — tray fix no se puede aplicar"
    "Usando source como principal — el Electron EXE no se usa"
} else {
    $workDir = "$env:TEMP\asar-vaio-fix"
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    Push-Location $workDir
    npx --yes @electron/asar extract $asarPath $workDir 2>&1 | Out-Null
    
    $main = "$workDir\dist-bundle\main.mjs"
    $lines = Get-Content $main
    
    $itemIdx = -1; $endIdx = -1
    for ($i=0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '"Sessions", enabled: false') { $sessionIdx = $i }
    }
    for ($i=$sessionIdx; $i -ge 0; $i--) { if ($lines[$i] -match 'const sessionItem') { $itemIdx = $i; break } }
    for ($i=$sessionIdx; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '"No active sessions"') { $endIdx = $i; break } }
    
    if ($itemIdx -ge 0 -and $endIdx -gt $itemIdx) {
        for ($i=$itemIdx; $i -le $endIdx; $i++) { $lines[$i] = "" }
        $lines[$itemIdx] = "// Sessions removed"
        Set-Content $main $lines -Encoding UTF8
        Copy-Item $asarPath "$asarPath.backup" -Force
        npx --yes @electron/asar pack $workDir $asarPath 2>&1 | Out-Null
        "Tray fix: aplicado"
    } else { "Tray fix: estructura diferente — revisar" }
    Pop-Location; Remove-Item -Recurse -Force $workDir
}
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 042 — Post-update Chamber

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| Chamber source 57125 | SI/NO |
| Tasks activas | $($tasks.Count) |
| sessionId fijado | SI/NO |
| Tray fix ASAR | SI/NO |
"@
Set-Content -Path "doc\vaio\results\resultado-042.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-042.md
git commit -m "VAIO: resultado tarea 042 — post-update"
git pull --rebase
git push
```
