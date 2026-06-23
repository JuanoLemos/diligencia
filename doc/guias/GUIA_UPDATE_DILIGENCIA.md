# GUIA_UPDATE_DILIGENCIA — Cómo mantener tu proyecto al día v1.0

Guía para proyectos adaptados a Diligencia que necesitan actualizar a una versión más nueva de la metodología.

---

## 1. ¿Por qué actualizar?

Cada versión de Diligencia puede agregar:

| Tipo | Ejemplos |
|---|---|
| **Templates nuevos** | NOTICE, SECURITY.md, nuevos doc-base |
| **Comandos nuevos** | /legal, /informe-salud, /CBP escalativo |
| **Reglas del orquestador** | Pre-flight de versión, paralelismo Meta-PLAN |
| **Cambios en formato** | ROADMAP con IDs y prioridades, CHECKLIST expandido |
| **Variables nuevas** | $MECANICAS_TEMPLATE, $BACKUPS |
| **Correcciones** | Labels stale, sync de estructura, enforcement |

No actualizar puede dejar el proyecto con herramientas rotas, comandos ausentes o estructura inconsistente.

---

## 2. Verificar tu versión

```bash
# Tu versión actual
head -1 DILIGENCIA.md
# → # Diligencia v1.16.4 — Estructura estándar de documentación

# Última versión disponible
head -5 ~/.config/opencode/commands/adaptar.md | grep "Versión"
# → | Versión | v1.16.5 |
```

Si tu versión < versión disponible, estás atrasado.

---

## 3. Checklist de actualización

Después de ejecutar `/adaptar` (Flujo C), revisar:

- [ ] `DILIGENCIA.md` — versión actualizada
- [ ] `INDEX.md` — labels sincronizados
- [ ] `AGENTS.md` — nuevas variables agregadas
- [ ] `ROADMAP.md` — ¿cambió el formato? (MECANICA-CALIDAD)
- [ ] Comandos nuevos en `.opencode/commands/` (sincronizados por /adaptar)
- [ ] Templates nuevos en doc-base (NOTICE, SECURITY.md)
- [ ] Si hay cambios en CBP.md (global) — afecta el orquestador de todos los proyectos
- [ ] `HARNESS.md` — ¿nueva sección opcional (Testing worktree)?
- [ ] Sin comandos stale (ver Flujo C Fase 2.5)

---

## 4. Ejecutar `/adaptar`

```bash
/CBP → detecta versión stale → pregunta → ejecuta /adaptar
```

O manualmente:
```
/adaptar → Flujo C (proyecto ya adaptado)
```

El orquestador (`/CBP`) ahora detecta automáticamente si estás atrasado y te lo pregunta antes de cualquier workflow. Si querés forzar manual:

```
/adaptar
```

Responder "sí" al upgrade cuando `/adaptar` lo pregunte. Si hay varios comandos stale, `/adaptar` preguntará uno por uno.

---

## 5. Post-update

Después de actualizar:

1. Verificar que `DILIGENCIA.md` muestre la nueva versión:
   ```bash
   head -1 DILIGENCIA.md
   ```

2. Verificar que `INDEX.md` tenga la versión correcta:
   ```bash
   grep "DILIGENCIA.md" INDEX.md
   ```

3. Verificar comandos sincronizados:
   ```bash
   ls .opencode/commands/ | wc -l
   ```

4. Si hay templates nuevos (NOTICE, SECURITY.md), personalizarlos con los datos del proyecto.

5. Commit sugerido: `chore: upgrade Diligencia vA.B → vX.Y`

---

## 6. Proyectos con mucho atraso (3+ versiones)

Si pasaron varias versiones desde tu último update:

1. **No saltees versiones** — actualizá de a una.
2. Revisá la tabla **Migración entre versiones** en `~/.config/opencode/commands/adaptar.md`.
3. Por cada versión intermedia:
   - Ejecutar `/adaptar`
   - Revisar checklist §3
   - Commitear: `chore: upgrade vA.B → vA.(B+1)`
4. Las reglas del orquestador cambian con el tiempo — siempre releer `CBP.md` después de un upgrade mayor.
5. Si tenés dudas: `/estado` + `/doctor` diagnostican el proyecto.

---

## 7. Checklist resumen

Rápido para después de cualquier `/adaptar`:

```markdown
- [ ] DILIGENCIA.md en nueva versión
- [ ] INDEX.md sincronizado
- [ ] AGENTS.md variables al día
- [ ] ROADMAP.md formato correcto
- [ ] Comandos sincronizados (sin stale)
- [ ] Templates nuevos copiados
- [ ] CBP.md reglas revisadas
- [ ] HARNESS.md secciones opcionales
- [ ] Commit de upgrade
```

---

## Archivos relacionados
- `CBP.md` §Despacho de entrada — pre-flight automático de versión
- `adaptar.md` Flujo C — upgrade estructural
- `MECANICA-CALIDAD.md` — estándares de formato ROADMAP y docs
- `GUIA_DE_BUENAS_PRACTICAS.md` — hábitos de actualización
