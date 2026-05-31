# GUIA DE COMANDOS — Diligencia v1.0

Referencia completa de comandos del sistema Diligencia.

---

## 1. Comandos globales (heredados)

Viven en `~/.config/opencode/commands/`. Funcionan en cualquier proyecto sin configuración adicional.

| Comando | Descripción | App |
|---|---|---|
| `/adaptar` | Adapta el proyecto actual a estructura Diligencia. Detecta nuevo/existente/adaptado. | Todos |
| `/plan` | Planifica en modo PLAN (solo lectura). Ejecuta BUILD tras aprobación. | Todos |
| `/commit` | `git add -A` + commit con formato estándar. | Con git |
| `/health` | 3 verificaciones: balance paréntesis, consistencia rutas, sintaxis JS. | JS |
| `/debug` | Análisis profundo de backend/ruta, frontend/componente, DB/tabla. | Todos |
| `/limpiar` | Busca y elimina archivos temporales (`*.log`, `*.tmp`, `*.bak.*`). | Todos |

---

## 2. Comandos adaptables (requieren estructura de proyecto)

Estos comandos existen en proyectos adaptados (Némesis, MarketAI) y usan `$variables`. Para llevarlos a otro proyecto basta copiar el `.md` y ajustar las variables en `AGENTS.md`.

| Comando | Descripción | Variables que usa |
|---|---|---|
| `/estado` | Reporte rápido: últimos commits, pendientes, próximos pasos | $CHECKLIST, $ROADMAP |
| `/checklist` | Revisar CHECKLIST + ROADMAP | $CHECKLIST, $ROADMAP |
| `/rm` | Revisar ROADMAP por área | $RM_TX, $RM_UI, $RM_UX |
| `/+rm` | Agregar item al ROADMAP | $ROADMAP |
| `/+guia` | Crear guía nueva en doc/guias | $GUIAS, $GUIAS_TEMPLATE |
| `/updoc` | Sincronizar documentación completa | $CHECKLIST, $ROADMAP, $COMANDOS_FILE, $TESTING, AGENTS.md |
| `/backup` | Backup crítico de archivos clave | $ADR, $SISTEMA, etc. |

---

## 3. Cómo crear comandos locales

Los comandos locales van en `.opencode/commands/` de tu proyecto.

### Reglas:
1. **Usar solo `$variables`** para rutas. NUNCA rutas absolutas o relativas directas.
2. **Un archivo `.md` por comando.** El nombre del archivo es el nombre del comando.
3. **El contenido son instrucciones** que el orquestador lee y ejecuta.

### Template mínimo:

```markdown
# /micomando — Descripción breve

Hace X cosa.

## Argumentos
`/micomando <arg>` — qué hace

## Qué hace
1. Lee $ALGUN_VARIABLE
2. Hace algo
3. Reporta resultado

## Archivos que modifica
- $ALGUN_VARIABLE
- $OTRO_VARIABLE
```

### Ejemplo real:

```markdown
# /estado — Reporte rápido del proyecto

1. Lee `git log --oneline -5`
2. Lee $CHECKLIST para items PENDIENTE
3. Lee $CHANGELOG para última versión
4. Reporta tabla resumen
```

---

## 4. Variables disponibles en comandos

Las variables se definen en `AGENTS.md` → `Mapeo de rutas`. Son específicas de cada proyecto.

### Estándar (presentes en todo proyecto Diligencia):

| Variable | Apunta a |
|---|---|
| `$ROADMAP` | `ROADMAP.md` |
| `$CHECKLIST` | `CHECKLIST.md` |
| `$CHANGELOG` | `CHANGELOG.md` |
| `$GUIAS` | `doc/guias/` |
| `$GUIAS_TEMPLATE` | `doc/guias/_template.md` |
| `$ARCH` | `doc/arch/` |

### Específicas de proyecto (ej. Némesis):

| Variable | Apunta a |
|---|---|
| `$RM_TX` | `ROADMAP.md#tecnico` |
| `$RM_UI` | `ROADMAP.md#ui` |
| `$RM_UX` | `ROADMAP.md#ux` |
| `$ADR` | `doc/arch/ADR.md` |
| `$SISTEMA` | `doc/arch/SISTEMA.md` |
| `$BITACORA` | `doc/arch/bitacora.md` |
| `$MECANICAS` | `doc/mecanicas/` |
| `$BACKEND_DIR` | `backend/` |
| `$FRONTEND_DIR` | `frontend/` |

---

## 5. Patrones comunes

### Patrón "Leer y reportar"
```markdown
1. Leer $ARCHIVO
2. Extraer items con estado PENDIENTE o DONE
3. Reportar tabla
```

### Patrón "Crear archivo"
```markdown
1. Si no existe $DIRECTORIO, crearlo
2. Copiar $TEMPLATE a $DESTINO
3. Preguntar título al usuario
4. Escribir contenido en $DESTINO
```

### Patrón "Sincronizar"
```markdown
1. Leer $CHECKLIST y $ROADMAP
2. Comparar items DONE en ROADMAP vs CHECKLIST
3. Agregar faltantes a CHECKLIST
4. Marcar como actualizados en bitácora
```

### Patrón "Verificar"
```markdown
1. Leer $ARCHIVO
2. Verificar condición (existe? sintaxis? consistencia?)
3. Reportar OK o ERROR con detalle
```
