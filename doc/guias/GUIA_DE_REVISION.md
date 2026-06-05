# GUIA DE REVISIÓN — Diligencia v1.15.1

Plan paso a paso para auditar todos los motores/módulos del sistema Diligencia.

---

## Módulo 1: Template `doc-base` (la plantilla inicial)

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 1.1 | Existen los 14 archivos y directorios del template: .markdownlint.json, AGENTS.md, bugs.md, CHANGELOG.md, CHECKLIST.md, DILIGENCIA.md, HARNESS.md, incidentes.md, INDEX.md, ROADMAP.md, sesion.md, diligencia-check.yml, doc/arch/README.md, doc/arch/adr-template.md | `ls -Recurse` en `~\.config\opencode\templates\doc-base\` | `/adaptar` flujo A no puede copiar el template completo |
| 1.2 | Template AGENTS.md tiene las 16 `$variables` estándar, 5 comandos globales + 6 locales | Leer AGENTS.md del template | Proyecto nuevo nace sin variables |
| 1.3 | Template CHECKLIST.md no está vacío y tiene sección "Proyecto nuevo" | Leer CHECKLIST.md del template | Proyecto nuevo nace sin checklist inicial |

---

## Módulo 2: Comando `/adaptar` (el ejecutor)

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 2.1 | Lógica de detección automática (3 señales → 3 escenarios) | Leer `adaptar.md`, verificar que las 3 condiciones son mutuamente excluyentes | Escenario mal detectado = migración rota |
| 2.2 | Flujo A (nuevo): copia template, pregunta 3 datos, escribe AGENTS.md + ROADMAP.md | Simular mentalmente con proyecto vacío | Proyecto nuevo nace incompleto |
| 2.3 | Flujo B (existente): las 6 fases están bien delegadas a `@sdd-architect`, `@sdd-implement`, `@sdd-reviewer` | Leer `adaptar.md` §Flujo B, verificar que cada fase delega al agente correcto | Migración sin delegación = descontrol |
| 2.4 | Flujo C (ya adaptado): verifica `$variables`, confirma root files, reporta salud | Leer `adaptar.md` §Flujo C | Proyecto adaptado no se repara si hay inconsistencias |
| 2.5 | Post-adaptación: sugiere commit, revisa git | Leer `adaptar.md` §Post-adaptación | Sin commit = sin checkpoint |

---

## Módulo 3: Comandos globales (heredados por todos)

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 3.1 | Existen 36 archivos en `~\.config\opencode\commands\` | `ls` | Proyecto sin comandos universales |
| 3.2 | `commit.md`, `plan.md`, `debug.md`, `health.md`, `limpiar.md` son funcionales | Leer cada uno, verificar que no tienen rutas hardcodeadas ni dependencias de proyecto | Comandos rotos en cualquier proyecto |
| 3.3 | `ADAPTAR-COMANDOS.md` es el stub de 6 líneas (ya reducido en v1.0) | Leer y medir | Si revierte a 321 líneas = duplicación |

---

## Módulo 4: Sistema de `$variables` (AGENTS.md como SSOT)

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 4.1 | La convención de naming se cumple: `$` + MAYÚSCULAS + `_` | Revisar AGENTS.md de Némesis y MarketAI | Variables ilegibles o no detectables |
| 4.2 | Cada `$variable` en AGENTS.md apunta a un archivo/directorio que existe | Para cada variable, verificar que la ruta existe en disco | Comandos que leen `$VARIABLE` fallan silenciosamente |
| 4.3 | Ningún comando en `.opencode/commands/` tiene rutas hardcodeadas (cero paths absolutos/relativos) | `grep` sobre `*.md` buscando `C:\\`, `xampp`, `docs/` | Migración de ruta rompe N comandos |
| 4.4 | La resolución de anclas (`$RM_TX` → `ROADMAP.md#tecnico`) funciona — los anchors existen en el archivo | Abrir ROADMAP.md y verificar que `#tecnico`, `#ui`, `#ux` existen como headings | `/rm tx` no encuentra la sección |

---

## Módulo 5: Estructura estándar (en cada proyecto adaptado)

| # | Qué verificar | Némesis | MarketAI |
|---|---|---|---|
| 5.1 | `ROADMAP.md` en raíz | ✅ OK | ❌ En `doc/documentos/` |
| 5.2 | `CHECKLIST.md` en raíz | ✅ OK | ❌ En `doc/documentos/` |
| 5.3 | `CHANGELOG.md` en raíz | ✅ OK | ❌ En `doc/` |
| 5.4 | `DILIGENCIA.md` en raíz | ❌ No existe | ❌ No existe |
| 5.5 | `doc/arch/` con ADRs, SISTEMA, bitácora | ✅ OK | ❌ No existe; bitácora en `doc/informes/` |
| 5.6 | `doc/guias/` (plural) | ✅ OK (9 archivos) | ✅ OK (8 archivos, falta `_template.md`) |
| 5.7 | `doc/mecanicas/` | ✅ OK (18 archivos) | ❌ No existe (decidir si aplica) |

---

## Módulo 6: Documentación Diligencia (proyecto documental)

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 6.1 | 6 archivos raíz existen y no están vacíos | `ls` + medir líneas | Documentación incompleta |
| 6.2 | 3 ADRs cubren los 3 pilares (dos capas, variables, estructura) | Leer ADR-001, 002, 003 | Decisiones no documentadas |
| 6.3 | 3 guías cubren uso, adaptación, comandos | Leer GUIA_DE_USO, GUIA_DE_ADAPTACION, GUIA_DE_COMANDOS | Sin manual de referencia |
| 6.4 | ROADMAP.md refleja el estado real (Ahora, Siguiente, Futuro, Completado) | Leer y cruzar con CHECKLIST.md | Desincronización |

---

## Módulo 7: Verificación cruzada de consistencia

| # | Qué verificar | Cómo |
|---|---|---|
| 7.1 | Las 13 variables del template AGENTS.md coinciden con las que usa `/adaptar` | Leer template AGENTS.md vs adaptar.md |
| 7.2 | Las guías de Diligencia no referencian rutas viejas (`autoridad/`, `docs/viejos/`) | `grep` sobre `C:\xampp\htdocs\Diligencia\` |
| 7.3 | `ADAPTAR-COMANDOS.md` (stub) no duplica contenido de las guías | Leer stub (debe ser ≤10 líneas) |

---

## Módulo 8: Nuevas funcionalidades post-v1.0

| # | Qué verificar | Cómo | Afecta si falla |
|---|---|---|---|
| 8.1 | CI/CD: `diligencia-check.yml` existe en template doc-base y se copia en `/adaptar` | Buscar el archivo en template y en proyecto adaptado | Proyecto nuevo sin validación automática |
| 8.2 | Stack templates: `templates/{node,python,go}/HARNESS.md` existen | `ls` en `~\.config\opencode\templates\` | Proyecto nuevo sin test/lint pre-configurados |
| 8.3 | ADR lifecycle: los 3 ADRs tienen estado y campos Supersedes/Superseded by | Leer ADR-001/002/003 | Decisiones sin trazabilidad de evolución |
| 8.4 | Comandos nuevos: /doctor, /bug, /incidente, /reanudar existen y son funcionales | Leer cada comando en `commands\` | Faltan herramientas de calidad y recuperación |
| 8.5 | GUIA_ECOSISTEMAS.md y GUIA_REFERENCIA_RAPIDA.md existen y están referenciadas | Verificar existencia y cross-refs en GUIA_DE_COMANDOS.md §8 | Documentación de orquestación incompleta |
| 8.6 | INDEX.md existe como catálogo de documentación | Verificar en raíz del proyecto | Docs informativos sin trazabilidad |
| 8.7 | HARNESS.md del proyecto tiene test/lint definidos | Leer `.opencode/HARNESS.md` | No se pueden ejecutar tests ni lint automáticos |

---

## Orden de revisión recomendado

```
Paso 1: Módulo 1 (template)       ← la base, sin esto nada funciona
Paso 2: Módulo 4 (variables)      ← el corazón, define qué se resuelve
Paso 3: Módulo 2 (/adaptar)       ← el ejecutor, lógica de 3 flujos
Paso 4: Módulo 3 (comandos globales) ← heredados, deben ser limpios
Paso 5: Módulo 5 (estructura)     ← verificar Némesis y MarketAI
Paso 6: Módulo 6 (docs Diligencia) ← el proyecto documental
Paso 7: Módulo 7 (consistencia)   ← cruzar todo
```

---

## Hallazgos detectados (v1.10.1)

| # | Hallazgo | Gravedad |
|---|---|---|
| H1 | **MarketAI no sigue la estructura estándar**: ROADMAP/CHECKLIST en `doc/documentos/`, CHANGELOG en `doc/`, sin `doc/arch/`, sin `DILIGENCIA.md` | 🔴 Alta |
| H2 | **Némesis no tiene `DILIGENCIA.md`** | 🟡 Media |
| H3 | **MarketAI no tiene `doc/mecanicas/`** — posiblemente no aplica (no es juego) | 🟢 Baja |
| H4 | **Template doc-base**: expandido de 8 a 14 archivos desde v1.0 — verificar que `/adaptar` copia todos | 🟡 Media |
| H5 | **MarketAI bitácora** en `doc/informes/bitacora.md` en vez de `doc/arch/bitacora.md` | 🟡 Media |
| H6 | **MarketAI `$GUIAS_TEMPLATE`** apunta a `doc/guias/_template.md` que no existe | 🟡 Media |
| H7 | **Stack templates**: `templates/{node,python,go}/HARNESS.md` creados en v1.8.0 — verificar que existen y son funcionales | 🟡 Media |
| H8 | **CI/CD**: `diligencia-check.yml` no verificado en proyectos adaptados post-v1.9.0 | 🟢 Baja |
