# GUIA CHAMBER — OpenChamber como interfaz de Diligencia v1.0.0

OpenChamber es la interfaz visual que ejecuta la metodología Diligencia. Proporciona terminal, diff viewer, file browser, notificaciones, y paneles interactivos para gestionar proyectos OpenCode.

---

## 1. Panel lateral

El panel lateral de Chamber muestra el estado actual del proyecto. Desde ahí podés:

- **Ver COMANDOS.md** — los 31 comandos agrupados por acción (CREAR/PLANIFICAR/EJECUTAR/REVISAR/CUIDAR)
- **Ver $UX_CHECK** — checklist de validación post-implementación
- **Ver UPDATE-AVAILABLE.md** — notificaciones de nuevas versiones de Diligencia

## 2. Terminal integrado

Todos los comandos de Diligencia funcionan en el terminal de Chamber:

| Comando | Acción |
|---|---|
| `/estado` | Reporte rápido del proyecto |
| `/next` | Plan de ejecución por olas |
| `/plan --ola N` | Planificar grupo de tareas |
| `/commit --push` | Commitear y pushear |
| `/doctor` | Cuidado integral del proyecto |
| `/propagar` | Propagar updates a proyectos hermanos |

## 3. File Browser

Chamber permite navegar archivos del proyecto. Los archivos clave de Diligencia están en:

| Ruta | Contenido |
|---|---|
| `AGENTS.md` | Variables y comandos del proyecto |
| `ROADMAP.md` | Roadmap con tareas pendientes |
| `doc/arch/` | ADRs, bugs, incidentes, health checks |
| `doc/guias/` | Guías de uso |
| `.opencode/commands/` | 28 comandos fundamentales |
| `UPDATE-AVAILABLE.md` | Notificación de nueva versión Diligencia (si aplica) |

## 4. Próximas funcionalidades (en desarrollo)

| Funcionalidad | R# | Descripción |
|---|---|---|
| Dashboard multi-proyecto | R26,R36 | Cards con salud de cada proyecto en $PROYECTOS |
| Botones /CBP, /doctor, /salud | R47 | Accesos directos en la UI, no solo terminal |
| Panel UX Checklist | R49 | Checkboxes interactivos que leen `$UX_CHECK` |
| Temas personalizados | R35 | 8 variantes Diligencia en Chamber |
| Iconos por proyecto | R51 | Cada proyecto con su ícono visual en la carpeta |

## 5. Resolución de problemas

| Problema | Solución |
|---|---|
| Comando no reconocido | Verificar que el comando esté en `.opencode/commands/` o en los globales |
| Panel no muestra datos | Ejecutar `/doctor` o `/salud` para regenerar indicadores |
| UPDATE-AVAILABLE.md sin leer | Ejecutar `/propagar` para refrescar desde Diligencia |

## Archivos relacionados
- `GUIA_DILIGENCIA_CHAMBER.md` — arquitectura de integración
- `AGENTS.md` — variables de configuración
- `.opencode/commands/` — comandos ejecutables
