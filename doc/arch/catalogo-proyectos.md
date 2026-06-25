# Catálogo de Proyectos — Diligencia v1.18.1

Mapa completo de proyectos adaptados a Diligencia en el ecosistema local.
Actualizado: 2026-06-23.

---

## Proyectos activos

| # | Proyecto | Ruta | Diligencia | Versión propia | Tipo | IA integrada | WT | Acción pendiente |
|---|---|---|---|---|---|---|---|---|
| 1 | **Diligencia** | `C:\xampp\htdocs\Diligencia` | v1.18.1 | 1.18.0 | Metodología documental | No | Clean | Referente. Único con $REPO. |
| 2 | **MarketAI** | `C:\xampp\htdocs\MarketAI` | v1.18.1 | 1.3.0 | Trading multi-capa | DeepSeek V4 Flash | Clean | Al día. Monitorear. |
| 3 | **buenobonitobarato** | `C:\xampp\htdocs\buenobonitobarato` | v1.18.0 | 0.1.0 | CLI Node.js | No | Clean | Casi al día. |
| 4 | **Nemesis** | `C:\xampp\htdocs\nemesis` | v1.18.1 ✅ | 3.8.2 | Juego narrativo IA | DeepSeek Flash+Pro, Claude, Gemini | Clean | Al día. 2238 líneas ROADMAP, 30 ADRs. |
| 5 | **+RM** | `C:\xampp\htdocs\+RM` | v1.17.9 ⚠️ | Sin versionar | Dashboard PHP | No | Clean | Commit reciente (dashboard + tray + scanner). Actualizar a v1.18.1. |
| 6 | **conquisitare** | `C:\xampp\htdocs\conquisitare` | v1.17.6 ⚠️ | 0.7.0 | Juego conquista WebGL | No | Clean | 2 versiones atrás. |

## Proyectos congelados

| # | Proyecto | Ruta | Diligencia | Estado |
|---|---|---|---|---|
| 7 | **closefront-io** | `C:\xampp\htdocs\closefront-io` | v1.17.4 | 🧊 Suspendido |
| 8 | **closefront-test** | `C:\xampp\htdocs\closefront-test` | v1.17.2 | 🧊 Worktree testing |

## Proyectos candidatos a adaptar

| # | Proyecto | Ruta | Diligencia | Estado |
|---|---|---|---|---|
| 9 | **OldWorld** | `C:\Users\jlemo\OneDrive\Desktop\OldWorld` | ❌ sin adaptar | Sin DILIGENCIA.md, sin git. |

## Proyectos legacy / sin adaptar

| # | Proyecto | Ruta | Detalle |
|---|---|---|---|---|
| 10 | **Diligencia.old** | `C:\xampp\htdocs\Diligencia.old` | Plataforma IA multi-proveedor. Sin git. Legacy v2.1. |
| 11 | **dashboard** | `C:\xampp\htdocs\dashboard` | Sin adaptar |
| 12 | **nscentral** | `C:\xampp\htdocs\nscentral` | Sin adaptar |
| 13 | **JdlV** | `C:\xampp\htdocs\JdlV` | Sin adaptar |

---

## Métricas

| Indicador | Valor |
|---|---|
| Proyectos activos | 6 |
| Candidatos a adaptar | 1 (OldWorld) |
| Al día (v1.18.x) | 3 |
| Atrasados | 3 |
| Congelados | 2 |
| IA integrada | 2 (MarketAI, Nemesis) |
| $REPO definido | 1 (Diligencia) |
| Working tree dirty | 1 (+RM) |

## Backups

Ejecutar `scripts/backup-all.ps1` antes de cualquier actualización masiva.
Los bundles se guardan en `C:\xampp\htdocs\backups\<fecha>\`.

## Archivos relacionados
- `MANDATO.md` — mandatos de Diligencia
- `scripts/backup-all.ps1` — script de backup
- `GUIA_UPDATE_DILIGENCIA.md` — guía de actualización de proyectos
