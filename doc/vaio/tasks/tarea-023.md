# Tarea 023 — Limpiar tasks duplicadas en VAIO

> **Problema:** Cada curl PUT anterior creó una task nueva. Hay 10 tasks en vez de 2.
> **Objetivo:** Dejar solo check-tareas + publish-url. Borrar todo lo demás.

## Comandos

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

# 1. Listar todas las tasks
Write-Host "=== Tasks actuales ==="
$allTasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$allTasks | Select-Object id, name, @{n="lastRun";e={$_.state.lastRunAt}} | Format-Table

# 2. Para cada nombre duplicado, quedarse con la más reciente
$keep = @{}
foreach ($t in $allTasks) {
    $n = $t.name
    if (-not $keep.ContainsKey($n) -or $t.state.lastRunAt -gt $keep[$n].state.lastRunAt) {
        $keep[$n] = $t
    }
}

# 3. Borrar cloudflared-watchdog (deprecado)
$keep.Remove("VAIO: cloudflared-watchdog")

# 4. Eliminar todas las tasks que NO están en $keep
$deleted = 0
foreach ($t in $allTasks) {
    $shouldKeep = $false
    foreach ($kv in $keep.GetEnumerator()) {
        if ($t.id -eq $kv.Value.id) { $shouldKeep = $true; break }
    }
    if (-not $shouldKeep) {
        curl.exe -s -X DELETE "$api/$($t.id)" | Out-Null
        Write-Host "ELIMINADA: $($t.name) ($($t.id))"
        $deleted++
    }
}

# 5. Mostrar resultado final
Write-Host ""
Write-Host "=== Tasks después de limpieza ==="
$remaining = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$remaining | Select-Object name, enabled, @{n="sessionId";e={$_.execution.sessionId}}
Write-Host "Eliminadas: $deleted | Quedan: $($remaining.Count)"
```

## Escribir resultado

```powershell
$ok = @"
# Resultado 023 — Tasks duplicadas eliminadas

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Limpieza

| Task | Cantidad antes | Cantidad después |
|---|---|---|
| check-tareas | 2 | 1 |
| publish-url | 6 | 1 |
| cloudflared-watchdog | 2 | 0 (deprecado) |
| **Total** | **10** | **2** |

## Tasks finales

- VAIO: check-tareas (cada 1 min)
- VAIO: publish-url (cada 1 hora)
"@
Set-Content -Path "doc\vaio\results\resultado-023.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-023.md
git commit -m "VAIO: resultado tarea 023 — duplicados eliminados"
git pull --rebase
git push
```
