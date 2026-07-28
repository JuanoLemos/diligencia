# Tarea 033 — Resolver sesiones múltiples definitivamente

> **Objetivo:** 1 sola sesión para check-tareas. Reutilizada en cada ciclo. Con permisos de build.
> **Vos tenés acceso al source de Chamber. Vos tenés la API. Vos lo resolvés.**

## El problema

Cada vez que check-tareas ejecuta (cada 1 min), Chamber crea una sesión nueva. Queremos que SIEMPRE use la misma sesión.

## Por qué pasa

Chamber tiene un bug en su código fuente (que está en `C:\Users\USUARIO\openchamber`). Dos archivos necesitan cambios:

1. **`packages/web/server/lib/scheduled-tasks/runtime.js`** (~línea 595): Siempre crea sesión nueva. Debería verificar si la task ya tiene un `sessionId` configurado y reusarlo.

2. **`packages/web/server/lib/projects/project-config.js`** (~línea 214): La función `normalizeExecution` descarta el campo `sessionId` al guardar. Debería preservarlo.

## Lo que tenés que hacer

1. **Leer esos 2 archivos.** Entender qué hacen.
2. **Modificarlos** para que soporten reutilización de sesión.
3. **Editar** el campo `execution.sessionId` de check-tareas (vía API PUT) con el ID de una sesión existente que tenga permisos de build.
4. **Reiniciar Chamber** (matar proceso en 57124, iniciar de nuevo con `node packages/web/bin/cli.js serve --port 57124`).
5. **Verificar:** esperar 2 ciclos (2 minutos). Si `state.lastSessionId` es el mismo en ambos, funciona.

## Referencia: cómo funciona en PC Principal

En PC Principal YA funciona. El código cambiado es:

**runtime.js (línea 595-606):**
```javascript
let sessionID;
const reuseSessionId = task.execution?.sessionId;
if (reuseSessionId) {
  sessionID = reuseSessionId;
} else {
  const sessionResponse = await client.session.create({
    directory: projectPath,
    title,
  });
  sessionID = sessionResponse?.data?.id;
  if (!sessionID) {
    throw new Error('failed to create session');
  }
}
```

**project-config.js (línea 214, 232-234):**
```javascript
const sessionId = value.sessionId || null;
// ... en el return:
...(sessionId ? { sessionId } : {}),
```

## Lo que NO tenés que hacer

- NO uses `prompt="DONE"` al editar la task. Preservá el prompt real.
- NO crees tareas duplicadas.
- NO modifiques nada fuera de esos 2 archivos.
- NO toques MarketAI ni otros proyectos.

## Cómo verificar que funcionó

```powershell
$api = "http://localhost:57124/api/projects/path_QzoveGFtcHAvaHRkb2NzL0RpbGlnZW5jaWE/scheduled-tasks"
$tasks = curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks
$ct = $tasks | Where-Object {$_.name -eq "VAIO: check-tareas"}
# Esperar 65s
Start-Sleep -Seconds 65
$ct2 = (curl.exe -s $api | ConvertFrom-Json | Select-Object -ExpandProperty tasks) | Where-Object {$_.name -eq "VAIO: check-tareas"}
if ($ct.state.lastSessionId -eq $ct2.state.lastSessionId) {
  "ESTABLE — misma sesion en 2 ciclos consecutivos"
} else {
  "FALLO — sesiones diferentes"
}
```

## Escribir resultado

Cuando funcione, escribí `resultado-033.md` con lo que hiciste, qué cambiaste, y la verificación. Commit + push.
