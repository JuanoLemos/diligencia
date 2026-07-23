# Tarea 009 — Prueba de ida y vuelta (round-trip test)

> **Tarea de prueba.** No ejecuta comandos destructivos. No toca MarketAI ni otros proyectos.
> Objetivo: verificar que el ciclo MAIN → git push → VAIO detecta → ejecuta → reporta → MAIN lee funciona correctamente.

## Instrucciones

1. Leer el timestamp de este archivo
2. Escribir un archivo de prueba en `doc/vaio/results/` con el resultado
3. Commitear y pushear

## Comandos

```powershell
# 1. Crear archivo de prueba
$test = @"
# Resultado 009 — Round-Trip Test

**Iniciado por MAIN:** 2026-07-22
**Ejecutado por VAIO:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC")
**Hostname:** $($env:COMPUTERNAME)
**Usuario:** $($env:USERNAME)

## Resultado

Autonomous VAIO round-trip: ✅ EXITOSO

MAIN creó tarea-009 → git push
VAIO detectó tarea-009 sola → ejecutó → escribió resultado
VAIO hizo commit + push sin intervención humana
MAIN hará git pull y leerá este resultado

## Archivos involucrados

| Archivo | Rol |
|---|---|
| doc/vaio/tasks/tarea-009.md | Creada por MAIN |
| doc/vaio/results/resultado-009.md | Creado por VAIO Worker (este archivo) |
"@
Set-Content -Path "doc\vaio\results\resultado-009.md" -Value $test -Encoding UTF8

# 2. Verificar que se creó
Get-Content "doc\vaio\results\resultado-009.md"

# 3. Commit + push
cd C:\xampp\htdocs\Diligencia
git add doc/vaio/results/resultado-009.md
git commit -m "VAIO: resultado tarea 009 — round-trip test exitoso"
git pull --rebase
git push
```
