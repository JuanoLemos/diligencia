# GUIA_DE_INFORMES — Diligencia v1.16.3

Ecosistema de reportes, salud y monitoreo del proyecto.

---

## 1. Mapa del ecosistema de reportes

```
┌─────────────────────────────────────────────────────────────────┐
│  PRODUCTORES DE DATOS (capa de diagnóstico)                     │
│                                                                 │
│  /updoc PLAN    → stale counts, gap counts, cross-ref counts    │
│  /doctor PLAN   → estructura OK/❌, ADRs, último doctor         │
│  git status     → working tree dirty/clean, modified files      │
│  /version V4a-f → pre-flight: 6 checks de salud                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  REPORTES DE SALUD (capa estructural)                          │
│                                                                 │
│  /salud         → doc/arch/status-salud.md (10 indicadores)    │
│  /informe-salud → doc/arch/informe-salud-proyectos.md (N proy.) │
│  /version V4    → pre-flight: bloquea/release el bump          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  REPORTES DE ESTADO (capa operativa)                           │
│                                                                 │
│  /estado   → git + RM + CHECKLIST snapshot rápido              │
│  /report   → RM + CHECKLIST + git (15 commits) consolidado     │
│  /rm       → ROADMAP filtrado por área                         │
│  /next     → Top 5 items accionables (con dependencias)        │
│  /checklist→ Inconsistencias RM ↔ CHECKLIST                    │
│  /news     → $NEWS_FILE → distribución a $RM                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  DIAGNÓSTICO (capa de investigación activa)                    │
│                                                                 │
│  /doctor     → 3 fases: diagnóstico + corrección + backup      │
│  /bug        → Registrar bugs confirmados                      │
│  /incidente  → Registrar crashes runtime                       │
│  /qa         → Revisión de situaciones ambiguas                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Cuándo usar cada comando

### Para saber el estado del proyecto

| Quiero saber... | Comando | Tiempo |
|---|---|---|
| ¿Hay cambios sin commitear? | `/estado` | 2 seg |
| ¿Qué dice el ROADMAP? | `/rm` | 5 seg |
| ¿CHECKLIST y ROADMAP están sincronizados? | `/checklist` | 5 seg |
| ¿Cuáles son los próximos pasos? | `/next` | 10 seg |
| Vista completa (RM + CHECKLIST + git log) | `/report` | 10 seg |

### Para evaluar la salud del proyecto

| Quiero saber... | Comando | Tiempo |
|---|---|---|
| ¿Hay docs stale o gaps documentales? | `/updoc` standalone | 30 seg |
| ¿La estructura del proyecto está íntegra? | `/doctor` standalone | 1 min |
| Reporte de salud con 10 indicadores | `/salud` (via /CBP) | BUILD* |
| Salud de múltiples proyectos | `/informe-salud` | 1 min |

### Para cerrar una sesión

| Tipo de sesión | Comando | Qué hace |
|---|---|---|
| Solo cambié código fuente | `/CBP commit` | git add + commit + push |
| Toqué 1-5 docs | `/CBP parcial` | updoc A→F + version patch + push |
| Cierro milestone o working tree sucio | `/CBP full` | Meta-PLAN completo + BUILD |
| Versionado rápido sin updoc | `/CBP version` | bump + push |

---

## 3. Flujo post-update

Después de ejecutar `/version` + `/pushgh`:

```
1. ✅ VERIFICAR git clean
   git status --porcelain → debe estar vacío

2. 📋 REVISAR status-salud.md
   doc/arch/status-salud.md → indicadores post-release

3. 🗺️ ACTUALIZAR ROADMAP
   Mover items de "Siguiente" a "Completado" si aplica
   /+rm o /+rmi para items nuevos descubiertos durante la sesión

4. 📢 NOTIFICAR (opcional)
   /notify si hay cambios que comunicar al equipo
   /news si hay cambios entrantes a distribuir

5. 🩺 HIGIENE MENSUAL (no por sesión)
   /doctor → diagnóstico completo
   /informe-salud → revisión inter-proyecto

6. 🔄 REVISAR $NEWS_FILE
   design/report/news.txt → leer y distribuir items a $RM
```

### Qué NO hacer post-update

- No ejecutar /CBP completo inmediatamente después de versionar
- No duplicar /updoc si acabas de ejecutar /CBP parcial o full
- No regenerar status-salud.md a menos que haya cambios documentales

---

## 4. Gaps y mejoras conocidas

| Gap | Estado | Impacto |
|---|---|---|
| `$NEWS_FILE` no definido en AGENTS.md — /news no puede funcionar | ❌ Sin resolver | /news fuera de servicio |
| `$PROYECTOS` sin configurar — /informe-salud nunca ejecutado | ⚠️ Pendiente configurar | Sin informe inter-proyecto |
| No hay analytics de tendencias (¿stale sube o baja?) | 🔜 Futuro P3 | Oportunidad de mejora |
| No hay dashboard unificado (merge /estado + /salud + /report) | 🔜 Futuro P3 | Usabilidad |
| 5 comandos ligeros con solapamiento (/estado, /report, /rm, /next, /checklist) | ⚠️ Diseñado (cada uno tiene un lente distinto) | Ver árbol de decisión §2 |

---

## 5. Workflow semanal recomendado

| Día | Acción | Tiempo |
|---|---|---|
| **Lunes** | `/estado` — verificar estado del working tree | 10 seg |
| **Viernes** | Si hubo cambios en la semana: `/CBP parcial` o `/CBP full` | 1-3 min |
| **Fin de milestone** | `/CBP full` + `/doctor` + `/informe-salud` | 5 min |
| **Mensual** | `/doctor` completo + revisión de $BUGS/$INCIDENTS | 2 min |

---

## 6. Archivos que genera el ecosistema

| Archivo | Generado por | Propósito |
|---|---|---|
| `doc/arch/status-salud.md` | `/salud` BUILD* | 10 indicadores de salud + historial |
| `doc/arch/informe-salud-proyectos.md` | `/informe-salud` | Salud consolidada de N proyectos |
| `doc/arch/bugs.md` | `/bug` | Bug tracker (P1/P2/P3) |
| `doc/arch/incidentes.md` | `/incidente` | Incidentes runtime |
| `doc/arch/backups.md` | `/doctor` backup | Log de backups con pruning |
| `doc/reporte-proyecto.md` | `/report --update` | Reporte consolidado persistente |
