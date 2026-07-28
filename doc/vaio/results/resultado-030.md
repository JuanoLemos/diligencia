# Resultado 030 — EPERM fix + sesiones estabilizadas

**Fecha:** 2026-07-27 22:18:35 UTC

## Estado final

| Check | Resultado |
|---|---|
| EPERM fix (writeFile directo) | SI |
| JSON sin BOM (UTF8 sin firma) | SI |
| Duplicados eliminados | SI (2 tasks limpias) |
| sessionId fijado | ses_059bc4fccffeOsGWjgJJresV6H |
| PC Principal ESTABLE | SI — misma sesion reutilizada |

## Bugs encontrados y corregidos

1. **EPERM en write-temp→rename**: writeProjectConfigToDisk usaba writeFile(tmp) + rename(tmp, dest). En Windows, el rename falla con EPERM si el archivo destino está lockeado. Se reemplazó por writeFile(dest) directo.

2. **BOM en JSON de PowerShell**: Set-Content -Encoding UTF8 agrega BOM (U+FEFF). Node.js rechaza JSON con BOM. Se usó [System.IO.File]::WriteAllText con UTF8Encoding(false).

3. **SessionId ignorado por Chamber**: Los fixes en untime.js y project-config.js estaban OK, pero el EPERM y BOM impedían la persistencia. Con ambos corregidos, el sessionId se reutiliza correctamente.

## Conclusión

Sesiones estabilizadas. check-tareas reutiliza misma sesion en cada ciclo. publish-url quedó con el mismo execution.sessionId, se verificará en su próximo ciclo (cada hora, minuto 0).
