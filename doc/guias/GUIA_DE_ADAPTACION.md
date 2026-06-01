# GUIA DE ADAPTACION — Diligencia v1.0

Proceso completo para migrar un proyecto existente a la estructura estándar Diligencia.

---

## 1. Detección del escenario

| Señal | Escenario |
|---|---|
| No existe `AGENTS.md` | Proyecto nuevo → copiar template |
| Existe `AGENTS.md` sin `ROADMAP.md` en raíz | Existente no adaptado → migrar |
| Existe `ROADMAP.md` en raíz | Ya adaptado → verificar |

Usar `/adaptar` para disparar la detección y el flujo automáticamente.

---

## 2. Las 6 fases de migración

### Fase 1 — Exploración

Leer la estructura actual del proyecto:
- `ls -R` del proyecto completo
- `AGENTS.md` existente (si hay)
- `.opencode/commands/*` (todos los comandos)
- Scripts de backup, sesión, bot

Generar tabla de equivalencia:

| Ruta vieja | $Variable | Ruta destino |
|---|---|---|
| `docs/viejo/roadmap.md` | `$ROADMAP` | `ROADMAP.md` |
| `docs/viejo/tasks.md` | `$CHECKLIST` | `CHECKLIST.md` |
| `docs/viejo/adr.md` | `$ADR` | `doc/arch/ADR.md` |

### Fase 2 — Definir variables

Escribir en `AGENTS.md` el bloque `Mapeo de rutas` con todas las `$VARIABLES` y sus rutas **destino**.

No mover archivos aún. Las variables apuntan a donde VAN a estar los archivos, no a donde están ahora.

### Fase 3 — Refactorizar comandos

Para cada comando en `.opencode/commands/*.md`:
1. Identificar rutas hardcodeadas con `grep`
2. Reemplazar cada una por su `$variable` correspondiente

Resultado esperado: cero rutas absolutas o relativas directas en comandos.

### Fase 4 — Migración física

Mover archivos según la tabla:
- Roadmaps, tasklists, changelogs → raíz (`ROADMAP.md`, `CHECKLIST.md`, `CHANGELOG.md`)
- ADRs, sistema, bitácora, estructura → `doc/arch/`
- Guías → `doc/guias/` (renombrar `doc/guia/` si existe)
- Mecánicas → `doc/mecanicas/` (usualmente ya existe)

Borrar directorios fuente vacíos.

### Fase 5 — Actualizar dependencias

Buscar rutas viejas con `grep` sobre TODO el proyecto y actualizar:
- Scripts de backup (`backup-critical.js`, etc.)
- Scripts de sesión/guard (`sesion.js`, etc.)
- Prompts de bots (`tel-prompt.txt`, etc.)
- `HARNESS.md`, `OPENCODE.md` (referencias a archivos movidos)
- Skills locales
- Guías de diseño (`DESIGN_GUIDE.md`, etc.)
- Referencias internas en documentación movida (`SISTEMA.md`, `METODOLOGIA_DE_PROYECTO.md`, etc.)

Distinguir referencias activas (hay que cambiarlas) vs históricas (bitácora, ADRs viejos — se dejan como están).

### Fase 6 — Verificación

Con `@sdd-reviewer`:
- Cada `$variable` en AGENTS.md → archivo existente
- Ningún comando tiene rutas hardcodeadas
- Backup scripts → ubicaciones reales
- No quedan directorios vacíos de la estructura vieja

---

## 3. Post-adaptación

- Commit: `chore: adaptación Diligencia v1.0`
- Si el proyecto no tiene git, inicializarlo

---

## 4. Checklist de verificación (post-migración)

- [ ] `ROADMAP.md` en raíz
- [ ] `CHECKLIST.md` en raíz
- [ ] `CHANGELOG.md` en raíz
- [ ] `AGENTS.md` con todas las variables resueltas
- [ ] `doc/arch/` existe con ADRs/SISTEMA/bitácora
- [ ] `doc/guias/` existe (renombrado de `doc/guia/` si aplica)
- [ ] `.opencode/commands/` sin rutas hardcodeadas
- [ ] `.opencode/HARNESS.md` creado desde template
- [ ] backup scripts apuntan a ubicaciones nuevas
- [ ] scripts de guard apuntan a ubicaciones nuevas
- [ ] `autoridad/` (o carpeta legacy) ya no existe
