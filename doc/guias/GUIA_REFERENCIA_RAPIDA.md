# GUIA DE REFERENCIA RAPIDA — Diligencia v1.16.2

Referencia rápida de 1 página. Para uso diario: comandos, decisión, flujo, variables.

---

## 1. Comandos por categoría

### Flujo de sesión
| Comando | Qué hace |
|---|---|
| `/plan` | Planificar tarea (solo lectura) |
| `/adaptar` | Adaptar proyecto a Diligencia |
| `/next` | Próximos 5 pasos del roadmap |
| `/estado` | Reporte rápido del proyecto |
| `/version` | Bump + doc sync + commit de cierre. Usar /CBP version para bump automático |
| `/reanudar` | Recuperar sesión tras interrupción brusca |
| `/commit` | Commit con Conventional Commits |

### Calidad
| Comando | Qué hace |
|---|---|
| `/doctor` | Chequeo integral (estructura + código + tracking + limpieza + deprecación). /CBP doctor para chain completo |
| `/health` | Salud del código (stack-aware) |
| `/diligencia-check` | Validar estructura completa |
| `/debug` | Análisis profundo de sección |
| `/deprecar` | Mover obsoleto a `.old/` |
| `/reportar --tipo bug` | Reportar bug en $BUGS |
| `/reportar --tipo incidente` | Registrar crash en $INCIDENTS |
| `/limpiar` | Eliminar temporales |

### Documentación
| Comando | Qué hace |
|---|---|
| `/updoc` | Auditoría documental entre versiones. /CBP updoc para chain completo (updoc→version→doctor) |
| `/doc --tipo mecanica` | Crear mecánica desde template |
| `/doc --tipo mecanica --actualizar` | Actualizar mecánica |
| `/doc --tipo guia` | Crear guía desde template |
| `/doc --tipo guia --actualizar` | Actualizar guía |

### Roadmap / Backlog
| Comando | Qué hace |
|---|---|
| `/rm` | Revisar roadmap |
| `/+rm` | Agregar ítem al roadmap |
| `/estado --full` | Reporte completo del proyecto |
| `/rm` | Revisar roadmap completo |
| `/next` | Próximos pasos agrupados por olas |

### Contexto / Edición
| Comando | Qué hace |
|---|---|
| `/foco` | Cargar contexto de área |
| `/head` | Preparar edición de sección |
| `/explica` | Explicar concepto (1-3 líneas) |

### Backup / Seguridad
| Comando | Qué hace |
|---|---|
| `/backup` | Backup rápido |
| `/backup --all` | Backup completo del proyecto |

---

## 2. Árbol de decisión

| Quiero... | Usa | En vez de... |
|---|---|---|
| Cerrar sesión | `/version` | git commit manual |
| Recuperar sesión perdida | `/reanudar` | empezar de cero |
| Sincronizar docs entre versiones | `/updoc` | editar docs directo |
| Chequeo completo del proyecto | `/doctor` | /health + /diligencia-check por separado |
| Reportar bug | `/reportar --tipo bug` | `/reportar --tipo incidente` (bugs ≠ crashes) |
| Registrar crash | `/reportar --tipo incidente` | `/reportar --tipo bug` |
| Deprecar archivo | `/deprecar` | `rm` / `del` |
| Limpiar temporales | `/limpiar` | rm manual |
| Agregar item a roadmap | `/+rm` | Editar ROADMAP.md directo |
| Ver próximos pasos | `/next` | Leer ROADMAP.md directo |
| Entender concepto | `/explica` | Leer guía completa |
| Preparar cambio grande | `/plan` | Editar sin plan |
| Commitear | `/commit` | git commit (sin validación) |

---

## 3. Ciclo de sesión

```
PRE                DURANTE              POST
/reanudar          /plan → BUILD        /CBP updoc
/foco  → /next     /commit feat/fix      /CBP doctor
/estado                                  /CBP version (sin /updoc)
```

1. `/reanudar` — recuperar contexto si hubo interrupción
2. `/foco <area>` — cargar contexto
3. `/next` + `/estado` — saber dónde estás
4. `/plan` — planificar cambios
5. BUILD — implementar
6. `/commit tipo:` — commitear cambios parciales (opcional)
7. `/CBP updoc` — auditoría + versionado + doctor en un solo workflow
8. `/CBP doctor` — chequeo integral + /version patch si hay correcciones
9. El POST usa el **orquestador `/CBP`** (`doc/mecanicas/MECANICA-CBP.md`) que ejecuta los comandos en secuencia con encadenamiento controlado

---

## 4. Variables esenciales

| Variable | Ruta | Propósito |
|---|---|---|
| $RM | `ROADMAP.md` | Roadmap del proyecto |
| $CHECKLIST | `CHECKLIST.md` | Checklist operativo |
| $CHANGELOG | `CHANGELOG.md` | Historial de versiones |
| $GUIAS | `doc/guias/` | Guías de uso |
| $ARCH | `doc/arch/` | ADRs + sistema |
| $MECANICAS | `doc/mecanicas/` | Reglas de negocio |
| $BUGS | `doc/arch/bugs.md` | Bug tracker |
| $INCIDENTS | `doc/arch/incidentes.md` | Crash tracker |
| $HARNESS | `.opencode/HARNESS.md` | Test/lint/stack config |
| $COMMANDS_DIR | `.opencode/commands/` | Comandos locales |
| $TEMPLATE_DIR | `~/.config/opencode/templates/doc-base/` | Templates base |
| $TESTING | *(en HARNESS.md)* | Comando de test |

---

## 5. Workflows comunes

| Tarea | Cadena |
|---|---|
| Nuevo proyecto | `/adaptar` → *(configurar)* |
| Feature nueva | `/plan` → BUILD → `/commit feat:` |
| Bug fix | `/reportar --tipo bug` → `/debug` → BUILD → `/commit fix:` |
| Recuperación de sesión | `/reanudar` |
| Cierre de sesión | `/CBP completo` (updoc→doctor→version) |
| Limpieza post-merge | `/doctor` → `/limpiar` |
| Deprecar feature | `/deprecar` → `/CBP version` |
| Sincronizar docs | `/updoc` |

---

## 6. Anti-patrones críticos

| ❌ No | ✅ Sí |
|---|---|
| Editar sin plan en cambios grandes | `/plan` → BUILD |
| `git commit` manual | `/commit` con formato |
| Borrar archivos con `rm` / `del` | `/deprecar` (a `.old/`) |
| Usar `/reportar --tipo bug` para crashes | `/reportar --tipo incidente` para crashes |
| Sincronizar docs sin `/updoc` | `/updoc` antes de versionar |
| Hardcodear rutas en comandos | `$variables` en AGENTS.md |
| Cerrar sesión sin versionar | `/version` al final |

---

## 7. Ecosistemas (agrupación funcional)

| Ecosistema | Comandos |
|---|---|
| DOCTOR | /doctor, /health, /diligencia-check, /reportar, /limpiar, /deprecar |
| VERSION | /version, /updoc, /reanudar |
| ADAPTAR | /adaptar, @sdd-* |
| DOCUMENTACION | /doc --tipo mecanica, /doc --tipo guia |
| CONTEXTO | /foco, /head, /explica |
| BACKUP | /backup, /backup --all |
| COMUNICACION | /commit, /pushgh |
| SEGUIMIENTO | /rm, /+rm, /next, /estado |

---

## Archivos relacionados
- `GUIA_DE_COMANDOS.md` — referencia completa de 37 comandos
- `GUIA_DE_BUENAS_PRACTICAS.md` — hábitos, árbol de decisión detallado, anti-patrones
- `GUIA_ECOSISTEMAS.md` — mapa completo de 9 ecosistemas
- `GUIA_DE_USO.md` — tutorial paso a paso
- `$RM` — roadmap del proyecto
- `$HARNESS` — config de test/lint/stack
