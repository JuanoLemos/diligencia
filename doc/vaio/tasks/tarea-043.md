# Tarea 043 — Verificar scheduled tasks en VAIO post-update

> Diagnóstico rápido. No modifica nada.

```powershell
$api57125 = "http://localhost:57125/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"

"=== Tasks en 57125 (source) ==="
$t25 = curl.exe -s $api57125 2>$null
if ($t25) { $count25 = ($t25 | ConvertFrom-Json | Select-Object -ExpandProperty tasks).Count } else { $count25 = -1 }

$ok = @"
# Resultado 043 — Verificación post-update

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

| Check | Estado |
|---|---|
| Chamber source 57125 responde | $(if($count25 -ge 0){'SI'}else{'NO'}) |
| Tasks en 57125 | $count25 |
"@
Set-Content -Path "doc\vaio\results\resultado-043.md" -Value $ok -Encoding UTF8

git add doc/vaio/results/resultado-043.md
git commit -m "VAIO: resultado tarea 043 — verificacion post-update"
git pull --rebase
git push
```
