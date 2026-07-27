# Tarea 022 — Fijar sessionId en VAIO (estabilizar sesiones)

> **Problema:** El sessionId actual en VAIO pertenece a una instancia vieja de OpenCode.
> Cada ejecución falla y crea sesión nueva. Hay que repetir el proceso que funcionó en PC Principal.

## Comandos — TODO en un solo bloque

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# 1. Quitar sessionId de ambas tasks (volver a crear sesión normal)
Write-Host "=== Quitando sessionId viejo ==="
$tasks = curl.exe -s $api | ConvertFrom-Json
foreach ($t in $tasks.tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\clean-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\clean-$($t.id).json" | Out-Null
    Write-Host "sessionId removido de: $($t.name)"
}

# 2. Esperar que check-tareas ejecute y cree sesión fresca
Write-Host "=== Esperando primer ciclo (65s) ==="
Start-Sleep -Seconds 65

# 3. Capturar el nuevo sessionId
Write-Host "=== Capturando nueva sesion ==="
$tasks = curl.exe -s $api | ConvertFrom-Json
$checkTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$newSessionId = $checkTask.state.lastSessionId
$status = $checkTask.state.lastStatus
Write-Host "Estado: $status | Nueva sesion: $newSessionId"

# 4. Fijar sessionId en ambas tasks
Write-Host "=== Fijando sessionId ==="
foreach ($t in $tasks.tasks) {
    $body = @{task=@{id=$t.id;name=$t.name;enabled=$true;schedule=$t.schedule;execution=@{sessionId=$newSessionId;providerID="deepseek";modelID="deepseek-v4-flash";prompt=$t.execution.prompt}}} | ConvertTo-Json -Depth 10
    $body | Set-Content "$env:TEMP\fix-$($t.id).json" -Encoding UTF8
    curl.exe -s -X PUT $api -H "Content-Type: application/json" -d "@$env:TEMP\fix-$($t.id).json" | Out-Null
    Write-Host "sessionId fijado en: $($t.name)"
}

# 5. Esperar un ciclo más y verificar
Write-Host "=== Verificando estabilidad (65s) ==="
Start-Sleep -Seconds 65
$tasks = curl.exe -s $api | ConvertFrom-Json
$checkTask = $tasks.tasks | Where-Object { $_.name -eq "VAIO: check-tareas" }
$finalSessionId = $checkTask.state.lastSessionId
$finalStatus = $checkTask.state.lastStatus
$finalDuration = $checkTask.state.lastDurationMs

if ($finalSessionId -eq $newSessionId) {
    Write-Host "ESTABLE — misma sesion reutilizada ($finalDuration ms)"
} else {
    Write-Host "FALLO — sesion diferente"
}
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 022 — SessionId estabilizado en VAIO

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Estado

| Check | Resultado |
|---|---|
| sessionId viejo removido | SI/NO |
| Nueva sesion creada | $newSessionId |
| sessionId fijado en tasks | SI/NO |
| Segundo ciclo: misma sesion | SI/NO |
| Duración último ciclo | $($checkTask.state.lastDurationMs) ms |

## Conclusión

$(if ($finalSessionId -eq $newSessionId) { "Sesiones estabilizadas — sin sesiones nuevas" } else { "Revisar manualmente" })
"@
Set-Content -Path "doc\vaio\results\resultado-022.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-022.md
git commit -m "VAIO: resultado tarea 022 — sessionId estabilizado"
git pull --rebase
git push
```
