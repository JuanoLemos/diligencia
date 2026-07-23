# Tarea 015 — Verificar instalación de Chamber (ASAR o desempaquetado)

> **Tarea de diagnóstico.** No modifica archivos. Solo lectura.

## Objetivo

Determinar si Chamber está empaquetado en `app.asar` o desempaquetado como archivos planos.

## Comandos

```powershell
$results = @()

# 1. Existe app.asar?
$asar = Test-Path "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\app.asar"
$results += "app.asar: $asar"

# 2. Existe packages/ con source plano?
$pkg = Test-Path "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\packages"
$results += "packages/: $pkg"

# 3. Existe runtime.js como archivo plano?
$rt = Test-Path "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\packages\web\server\lib\scheduled-tasks\runtime.js"
$results += "runtime.js plano: $rt"

# 4. Qué hay en resources/?
$list = Get-ChildItem "$env:LOCALAPPDATA\Programs\@openchamberelectron\resources\" -Depth 0 | ForEach-Object { $_.Name }
$results += "resources/: [$($list -join ', ')]"

$results -join "`n"
```

## Escribir resultado

```powershell
$report = @"
# Resultado 015 — Diagnóstico instalación Chamber

**Fecha:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")

## Resultados

| Check | Valor |
|---|---|
| app.asar existe | [SI/NO] |
| packages/ existe (source plano) | [SI/NO] |
| runtime.js plano existe | [SI/NO] |
| Contenido de resources/ | [...] |

## Conclusión

[Chamber está empaquetado en ASAR / Chamber está desempaquetado]
[El runtime.js se puede modificar SI/NO directamente]
"@
Set-Content -Path "doc\vaio\results\resultado-015.md" -Value $report -Encoding UTF8

git add doc/vaio/results/resultado-015.md
git commit -m "VAIO: resultado tarea 015 — diagnostico instalacion Chamber"
git pull --rebase
git push
```
