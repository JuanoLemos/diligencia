# GUIA DE REFERENCIA RAPIDA — Diligencia v1.10.1

Referencia rápida de 1 página. Para uso diario: comandos, decisión, flujo, variables.

---

## 1. Comandos por categoría

### Flujo de sesión
| Comando | Qué hace |
|---|---|
| `/plan` | Planificar tarea (solo lectura) |
| `/adaptar` | Adaptar proyecto a Diligencia |
| `/next` | Próximos 5 pasos del roadmap |
| `/report` | Reporte consolidado |
| `/version` | Bump + updoc + commit de cierre. Post-/doctor: auto-sugiere patch |
| `/reanudar` | Recuperar sesión tras interrupción brusca |
| `/commit` | Commit con Conventional Commits |

### Calidad
| Comando | Qué hace |
|---|---|
| `/doctor` | Chequeo integral (estructura + código + tracking + limpieza + deprecación). Circuito → sugiere /version patch |
| `/health` | Salud del código (stack-aware) |
| `/diligencia-check` | Validar estructura completa |
| `/debug` | Análisis profundo de sección |
| `/qa` | Situaciones a revisar |
| `/bug` | Reportar bug en $BUGS |
| `/incidente` | Registrar crash en $INCIDENTS |
| `/limpiar` | Eliminar temporales |
| `/deprecar` | Mover obsoleto a `.old/` |

### Documentación
| Comando | Qué hace |
|---|---|
| `/updoc` | Auditoría documental entre versiones |
| `/+mec` | Crear mecánica desde template |
| `/upmec` | Actualizar mecánica |
| `/+guia` | Crear guía desde template |
| `/upguia` | Actualizar guía |

### Roadmap / Backlog
| Comando | Qué hace |
|---|---|
| `/rm` | Revisar roadmap |
| `/+rm` | Agregar ítem al roadmap |
| `/+rmi` | Editar ítem del roadmap |
| `/estado` | Reporte rápido del proyecto |
| `/checklist` | Cruce RM + checklist |

### Contexto / Edición
| Comando | Qué hace |
|---|---|
| `/foco` | Cargar contexto de área |
| `/head` | Preparar edición de sección |
| `/apply` | Aplicar handoff file a código |
| `/explica` | Explicar concepto (1-3 líneas) |
| `/+pend` | Agregar pendiente de revisión |

### Backup / Seguridad
| Comando | Qué hace |
|---|---|
| `/backup` | Backup rápido |
| `/backupall` | Zip completo |

### Comunicación
| Comando | Qué hace |
|---|---|
| `/news` | Distribuir $NEWS |
| `/notify` | Toggle notificación remota |

---

## 2. Árbol de decisión

| Quiero... | Usa | En vez de... |
|---|---|---|
| Cerrar sesión | `/version` | git commit manual |
| Recuperar sesión perdida | `/reanudar` | empezar de cero |
| Sincronizar docs entre versiones | `/updoc` | editar docs directo |
| Chequeo completo del proyecto | `/doctor` | /health + /diligencia-check por separado |
| Reportar bug | `/bug` | `/incidente` (bugs ≠ crashes) |
| Registrar crash | `/incidente` | `/bug` |
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
/reanudar          /plan → BUILD        /doctor → /updoc → /version
/foco  → /next     /commit feat/fix      /commit chore(release)
/estado
```

1. `/reanudar` — recuperar contexto si hubo interrupción
2. `/foco <area>` — cargar contexto
3. `/next` + `/estado` — saber dónde estás
4. `/plan` — planificar cambios
4. BUILD — implementar
5. `/commit tipo:` — commitear cambios parciales
7. `/doctor` — chequeo integral pre-cierre (circuito → sugiere /version patch)
8. `/updoc` — sincronizar documentación (D5 alerta template stale)
9. `/version` — versionar y cerrar (post-/doctor auto-sugiere patch)

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
| Bug fix | `/bug` → `/debug` → BUILD → `/commit fix:` |
| Recuperación de sesión | `/reanudar` |
| Cierre de sesión | `/doctor` → `/updoc` → `/version` |
| Limpieza post-merge | `/doctor` → `/limpiar` |
| Deprecar feature | `/deprecar` → `/version` |
| Sincronizar docs | `/updoc` |

---

## 6. Anti-patrones críticos

| ❌ No | ✅ Sí |
|---|---|
| Editar sin plan en cambios grandes | `/plan` → BUILD |
| `git commit` manual | `/commit` con formato |
| Borrar archivos con `rm` / `del` | `/deprecar` (a `.old/`) |
| Usar `/bug` para crashes | `/incidente` para crashes |
| Sincronizar docs sin `/updoc` | `/updoc` antes de versionar |
| Hardcodear rutas en comandos | `$variables` en AGENTS.md |
| Cerrar sesión sin versionar | `/version` al final |

---

## 7. Ecosistemas (agrupación funcional)

| Ecosistema | Comandos |
|---|---|
| DOCTOR | /doctor, /health, /diligencia-check, /bug, /incidente, /limpiar, /deprecar |
| VERSION | /version, /updoc, /reanudar |
| ADAPTAR | /adaptar, @sdd-* |
| DOCUMENTACION | /+mec, /+guia, /upmec, /upguia |
| CONTEXTO | /foco, /head, /apply, /+pend, /explica |
| BACKUP | /backup, /backupall |
| COMUNICACION | /commit, /news, /notify |
| SEGUIMIENTO | /rm, /+rm, /+rmi, /checklist, /next, /estado |

---

## Archivos relacionados
- `GUIA_DE_COMANDOS.md` — referencia completa de 35 comandos
- `GUIA_DE_BUENAS_PRACTICAS.md` — hábitos, árbol de decisión detallado, anti-patrones
- `GUIA_ECOSISTEMAS.md` — mapa completo de 9 ecosistemas
- `GUIA_DE_USO.md` — tutorial paso a paso
- `$RM` — roadmap del proyecto
- `$HARNESS` — config de test/lint/stack
