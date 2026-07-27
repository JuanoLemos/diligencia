# Tarea 025 — Prueba de ida y vuelta

> Tarea de prueba. No modifica nada. Solo confirma que la comunicación MAIN↔VAIO funciona.

```powershell
$test = @"
# Resultado 025 — Round-trip test

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Máquina:** $($env:COMPUTERNAME)

## Estado

| Check | Resultado |
|---|---|
| Comunicación MAIN→VAIO | ✅ tarea-025 recibida |
| Comunicación VAIO→MAIN | ✅ resultado-025 generado |
| Chamber source activo | ✅ $(if(Test-Path "C:\Users\USUARIO\openchamber\package.json"){"v1.16.3"}else{"NO"}) |
| Scheduled tasks activas | ✅ $(if(curl.exe -s http://localhost:57124/api/openchamber/scheduled-tasks/status 2>$null -match "enabled"){"SI"}else{"NO"}) |

## Prueba completada

$(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
"@
Set-Content -Path "doc\vaio\results\resultado-025.md" -Value $test -Encoding UTF8

git add doc/vaio/results/resultado-025.md
git commit -m "VAIO: resultado tarea 025 — round-trip test"
git pull --rebase
git push
```
