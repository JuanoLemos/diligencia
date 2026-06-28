# ROADMAP — Diligencia

Metodología de estructura estándar para proyectos OpenCode.

Última actualización: 2026-06-13

---

## Stack

- Metodología documental (sin código runtime)
- Dependencias: OpenCode, `templates/doc-base/`, `ADAPTAR-COMANDOS.md`
- Proyectos adaptados: proyecto-alfa Detective, proyecto-beta

---

## Ahora (Now)

*(nada en progreso actualmente)*

## Siguiente (Next)

| ID | Item | Prioridad | Estado | Depende de |
|----|------|-----------|--------|------------|
| R08 | +audit: sincronizar INDEX labels de todos los docs del proyecto | P2 | 🔴 Pendiente | — |
| R09 | +grooming: revisar proyectos adaptados (proyecto-alfa, proyecto-beta) | P2 | 🔴 Pendiente | — |
| R10 | +mejora: integrar recomendaciones de /estado en flujo /doctor | P3 | 🔴 Pendiente | R03 |
| R11 | +UX/UI: template UX-CHECKLIST.md como buena práctica heredable | P2 | 🔴 Pendiente | — |
| R16 | +room: mejora general de cobertura doc de comandos (diagramas, flows en criollo) | P3 | 🔴 Pendiente | R12,R13,R14,R15 |
| R17 | +legal: migrar GPL-3.0 → AGPL-3.0 + MANIFIESTO.md | P1 | ✅ Completado | — |
| R18 | +legal: SECURITY.md template mejorado (Scope, Out of Scope) | P1 | ✅ Completado | — |
| R19 | +contexto: MECANICA-CONTEXTO.md — modelo L0/L1/L2 para carga de documentación | P2 | 🟡 En progreso | — |
| R20 | +graphify: MECANICA-GRAPHIFY.md + .graphifyignore template | P2 | 🟡 En progreso | — |
| R21 | +memory: MECANICA-MEMORY.md — memoria persistente con claude-mem | P3 | 🟡 En progreso | — |
| R25 | +openchamber hub: adaptación liviana (DILIGENCIA.md, INDEX.md, ROADMAP.md, AGENTS.md +$PROYECTOS) | P2 | ✅ Completado | — |
| R26 | +openchamber hub: integración con $PROYECTOS para multi-proyecto visual | P2 | 🔴 Pendiente | R25 |
| R27 | +openchamber hub: dashboard visual de salud de proyectos (status-salud, diff, RM table) | P3 | 🔴 Pendiente | R26 |
| R28 | +openchamber hub: upstream watch — monitorear repo original (btriapitsyn/openchamber) para mergear mejoras | P2 | 🔴 Pendiente | R25 |
| R29 | +openchamber hub: skills de Diligencia (workflow, docs, health, commands, adaptation) para Skills Catalog | P2 | 🔴 Pendiente | R25 |
| R30 | +openchamber hub: portear 8 temas Diligencia al formato de UI de OpenChamber | P2 | 🔴 Pendiente | R25 |
| R34 | +skills Diligencia en repo público (workflow, docs, health, commands, adaptation) para Chamber Skills Catalog | P1 | ✅ Completado | — |
| R35 | +portear 8 temas Diligencia al formato Chamber UI (JSON ~180 props) | P1 | 🗑️ Deprecado | — (Chamber ya tiene 60+ temas dark/light) |
| R36 | +dashboard Diligencia en Chamber React (cards por proyecto: versión, WT, salud, RM %) | P2 | 🔴 Pendiente | R34,R35 |
| R37 | +README.md con badge BETA + link a issues en los 6 proyectos activos | P1 | ✅ Completado | — |
| R38 | +manuales: GUIA_DILIGENCIA_CHAMBER.md + GUIA_CHAMBER.md | P1 | ✅ Completado | R34 |
| R39 | +upstream watch Chamber (btriapitsyn/openchamber) para detectar nuevas releases | P2 | 🔴 Pendiente | R25 |
| R40 | +Chamber remoto vía Cloudflare Tunnel para acceso desde cualquier dispositivo | P2 | 🔴 Pendiente | — |
| R41 | +/news multi-proyecto — distribuir novedades a todos los $PROYECTOS desde Chamber | P2 | 🔴 Pendiente | R34 |
| R42 | +agentes SDD integrados con Chamber Team Mode (4 agentes en paralelo) | P2 | 🔴 Pendiente | R34 |
| R43 | +auto-discovery de proyectos con DILIGENCIA.md desde Chamber | P3 | 🔴 Pendiente | R36 |
| R44 | +scheduled health checks automáticos cada N horas vía Chamber | P3 | 🔴 Pendiente | R36 |
| R45 | +/next --plan: evolución de diagnóstico a ejecución (clusteriza tareas sin bloqueos en lotes, ejecuta secuencial) | P1 | 🔴 Pendiente | — |
| R46 | +audit Chamber: revisar todas las herramientas nativas (Terminal, DiffView, Skills Catalog, Team Mode, Background Agents, Scheduled Tasks, Git, File Browser) para optimizar comandos Diligencia | P2 | ✅ Completado | R34,R35 |
| R47 | +integrar comandos Diligencia con Chamber UI (botones /CBP, /doctor, /salud desde la interfaz visual, no solo terminal) | P2 | ✅ Completado | R46 |
| R48 | +propagar: comando para propagar updates de Diligencia a $PROYECTOS (semiautomático: /version sugiere, /propagar ejecuta) + UPDATE-AVAILABLE.md + $PROPAGAR_LOG → MECANICA-PROPAGACION.md | P2 | ✅ Completado | — |
| R49 | +ux: panel interactivo de checklist en Chamber por proyecto — checkboxes, progreso %, lee $UX_CHECK. Cada proyecto adaptado hereda el panel vía /adaptar. | P2 | 🔴 Pendiente | R25,R26 |
| R50 | +MiniMax: integrar procesamiento multimodal (video, imagen, voz) vía Token Plan Max — testing en OpenMontage | P1 | 🔴 Pendiente | R25,R26 |
| R51 | +chamber: iconos personalizados por proyecto para visual en carpeta de OpenChamber — template SVG en doc-base, /adaptar lo copia | P2 | ✅ Completado | R25 |
| R52 | +estudio: proyectos con potencial hosteo de server para actuarlos en producción + mejor camino para administrar todo | P2 | 🔴 Pendiente | — |

## Futuro (Later)

| ID | Item | Prioridad | Estado | Depende de |
|----|------|-----------|--------|------------|
| R05 | CLI tool independiente | P3 | 🔴 Pendiente | — |
| R06 | Plugin marketplace | P3 | 🔴 Pendiente| — |
| R22 | +planloop + loop: circuito autónomo de ejecución de ROADMAP (planloop→loop→checkpoint) | P3 | 🔴 Pendiente | — |
| R23 | +loop-watcher: app externa (PowerShell) para monitoreo de progreso y detección de crash | P3 | 🔴 Pendiente | R22 |
| R24 | +loop auto-restart: recuperación automática tras crash/desconexión | P3 | 🔴 Pendiente | R22,R23 |
| R31 | +openchamber hub: base SQLite para snapshots históricos de salud (tendencias, alertas) | P3 | 🔴 Pendiente | R25 |
| R32 | +openchamber hub: CLI standalone para /diligencia-check sin dependencia de agente IA | P3 | 🔴 Pendiente | R25 |
| R33 | +openchamber hub: discovery automático de proyectos con DILIGENCIA.md en directorio padre | P3 | 🔴 Pendiente | R25,R26 |

## Completado

| Item | Instancia |
|---|---|
| Documentación completa del sistema (ADRs + guías + estructura) | v1.0 |
| ADRs de arquitectura (001-003) | v1.0 |
| Guías de uso + adaptación | v1.0 |
| GUIA_DE_BUENAS_PRACTICAS.md — hábitos y workflows para el orquestador | v1.6 |
| Template `incidentes.md` en doc-base (externalizado para /adaptar) | v1.6 |
| Template `sesion.md` en doc-base (journal multi-agente) | v1.6 |
| Template doc-base (7 archivos) | v1.0 |
| Comando global /adaptar (Diligencia v1.0) | v1.0 |
| Migración proyecto-alfa Detective | v1.0 |
| Migración proyecto-beta | v1.0 |
| ADAPTAR-COMANDOS.md v1.3 | v1.0 |
| Estandarización comandos globales (guarda + imperativo + Formato/Validación/Anti-patrones) | v1.1 |
| 12 comandos proyecto-alfa adaptados a globales (29 total) + /adaptar copia comandos | v1.2 |
| ROADMAP stale data corregido (Ahora→Completado, duplicados Next) | v1.3 |
| AGENTS.md actualizado: 29 comandos + variables faltantes | v1.3 |
| /updoc mejorado: auditoría documental entre versiones | v1.3 |
| CHECKLIST sincronizado (ADRs/guías tildados, duplicado P3 removido) | v1.3 |
| GUIA_DE_COMANDOS.md actualizado a v1.3: 30 comandos + /explica + arquitectura + categorías | v1.3 |
| `diligencia-check` — validación automática de estructura (ADR-003, variables, comandos, versión) | v1.3 |
| HARNESS.md integrado al estándar: template, ADR-003, /adaptar, diligencia-check | v1.3 |
| MECANICA-DOCUMENTAL.md reestructurada con índice y 6 secciones (motor, tracking, QA, sesión, conservación, anti-patrones) | v1.6 |
| Comando `/deprecar` para deprecar archivos/estructuras obsoletas | v1.4 |
| Comando `/bug` — reportar bugs en $BUGS con template estándar | v1.5 |
| Comando `/incidente` — registrar crashes runtime en $INCIDENTS | v1.5 |
| `GUIA_ECOSISTEMAS.md` — mapa de ecosistemas y fronteras entre comandos | v1.7.2 |
| CHANGELOG adopta Keep a Changelog: `[Unreleased]` + 6 categorías (Added, Changed, Deprecated, Removed, Fixed, Security) | v1.7.2+ |
| ADR lifecycle states (Proposed → Accepted → Deprecated → Superseded) con campos `Supersedes`/`Superseded by` | v1.7.2+ |
| `/commit` — validación de formato Conventional Commits (tipo/scope obligatorios) | v1.7.2+ |
| `/version` — soporte `[YANKED]` en CHANGELOG, migración automática de `[Unreleased]` | v1.7.2+ |
| `/doctor` — cuidado integral del proyecto | v1.8.0 |
| Plantillas por stack (Node, Python, Go) | v1.8.0 |
| GUIA_REFERENCIA_RAPIDA.md | v1.8.0 |
| Integración con CI/CD — GitHub Actions workflow de validación de estructura (Category A/ADR-003) | v1.9.0 |
| `/version` — autodetección post-/doctor: si `[Unreleased]` contiene `/doctor`, sugiere `patch` | v1.10.0 |
| `/doctor` — circuito → `/version patch` tras correcciones en Fase 3 | v1.10.0 |
| `/reanudar` — recuperar sesión tras interrupción brusca (pérdida de conexión, brutalstop) | v1.10.0 |
| Template DILIGENCIA.md y adaptar.md sincronizados a v1.10.0 (bug: reportaban v1.7.1 y v1.3) | v1.10.1 |
| `/version`: si proyecto = Diligencia, actualiza template + adaptar.md al versionar | v1.10.1 |
| `/updoc`: D5 — detección de staleness template vs proyecto | v1.10.1 |
| `/pushgh`: comando build-only para push a GitHub, integrado en /CBP | v1.16.0 |
| `/salud BUILD*`: status-salud.md generado como reporte integrado en /CBP | v1.12.0 |
| Meta-orquestador: /CBP completo detecta agentes/skills según working tree | v1.12.0 |
| Meta-PLAN (PRO) + BUILD (FLASH): fase PRO confirma único plan antes de BUILD | v1.12.0 |
| +Backup en /doctor: backup preventivo + pruning configurable ($BACKUP_KEEP) + log en $BACKUPS | v1.16.2 |
| +guia usuario noob, usando primera vez AI | v1.16.3 |
| +revisión de agentes y skills: compatibilidad con circuito, actualizar docs | v1.16.3 |
| +informe-salud inter-proyecto basado en estructura Diligencia | v1.16.3 |
| +adaptación escalativa del /CBP (commit/parcial/full con detección automática) | v1.16.4 |
| +paralelización del Meta-PLAN (Waves 1-4, 20 fases concurrentes) | v1.16.4 |
| +GUIA_DE_INFORMES.md — ecosistema de reportes, post-update y workflow semanal | v1.16.4 |
| +GUIA_LEGAL.md + /legal command + NOTICE + SECURITY.md templates — Plan A legal | v1.16.5 |
| +MECANICA-WORKTREE.md + GUIA_MULTI_REPO.md — Plan B multi-repo | v1.16.5 |
| +MECANICA-CALIDAD.md + ROADMAP template estándar — Plan C calidad doc | v1.16.5 |
| +$NEWS_FILE creado en design/report/news.txt — /news desbloqueado | v1.16.5 |
| +asistente de configuración $PROYECTOS para /informe-salud | v1.16.7 |
| +ayuda en worktree /estado con recomendaciones proactivas | v1.16.7 |
| +dashboard unificado — /estado absorbe /report (--full, --update) + salud + bloqueos | v1.16.7 |
| +themes opencode customs — GUIA_THEMES.md + diligencia.json theme | v1.16.7 |
| +audit variables: $STACK, $PROJECT_NAME definidas; $NEWS_FILE removida; 5 comandos deprecados | v1.17.8 |
| +deprecados: /+pend, /+rmi, /news, /notify, /qa movidos a .old/commands/ | v1.17.8 |
| +fix: apply.md, deprecar.md corregidos; guias sincronizadas | v1.17.8 |
| +licencia: GPL-3.0 → AGPL-3.0 | v1.17.9 |
| +manifiesto: MANIFIESTO.md con 6 principios | v1.17.9 |
| +SECURITY.md template mejorado con Scope, Out of Scope, PoC | v1.17.9 |

## Archivos relacionados
- `CHECKLIST.md` — checklist de tareas
- `CHANGELOG.md` — historial de versiones
- `INDEX.md` — catálogo de documentación
