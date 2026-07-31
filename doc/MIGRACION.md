# MIGRACIÓN v3.11.0 → Futuro: Control en PC Servidor Externa

**Versión:** v3.11.0 | **Fecha:** 2026-07-31 | **Status:** Plan futuro (no implementado)

---

## Contexto: Por qué deprecamos VAIO

### Problemas de v3.10.x (VAIO + Server Remoto)

| Problema | Impacto | Evidencia |
|---|---|---|
| **Loops infinitos** | USD 10/día burn rate | CHANGELOG.md:90 — loop `check-tareas` cada 1 min |
| **Triangularidad** | Frágil y manual | 52 tasks manuales en `doc/vaio/tasks/` |
| **Watchdogs** | Ruido de commits | 45 heartbeat commits en v3.9.2 |
| **Complexity** | Difícil de mantener | Tunnels + Tailscale + ngrok + opencode serve |
| **MiniMax completion-oriented** | Agente hace cosas sin pedir | ICT-DIL-20260731-03 (commit sin autorización) |

**Decisión v3.11.0:** Deprecar VAIO completamente. Volver a arquitectura simple: Claude Desktop + git local.

---

## Situación Actual (v3.11.0)

✅ **Arquitectura:**
- Claude Desktop: PLAN + BUILD local en PC Principal
- Diligencia: metodología pura (rol 🔵 Circuito)
- Git: source of truth único
- Presupuesto: USD 20-100/mes (controlado)

❌ **Deprecados:**
- VAIO (PC servidor remota)
- `opencode serve` API
- Scheduled tasks IA
- Triangularidad GitHub
- Tunnels (Cloudflare, ngrok, Tailscale)
- Chamber (UI)
- MiniMax (multimodal)

---

## Visión Futura: Cuándo y Cómo Agregar Control Remoto

### Cuándo necesitarías servidor remoto

✅ **Casos legítimos:**
- Tests nocturnos (CI/CD)
- Backups automáticos cada N horas
- Procesamiento batch (video encoding, image processing)
- Monitoreo 24/7 de sitios en producción
- Recursos: PC secundaria con GPU, servidor en cloud

❌ **Casos que NO justifican:**
- "Ejecutar tareas sin estar en teclado" (= loops infinitos)
- "Agente autónomo 24/7" (= burn rate + complejidad)
- "Synchronization magic" (= triangularidad)

---

## Plan A: GitHub Actions (RECOMENDADO)

**Cuándo:** Tests nocturnos, validación automática, backups

**Arquitectura:**
```
GitHub repository → Actions workflow (free)
    ↓
    └─ trigger: schedule (cron) | push | manual
    ↓
    └─ job: run tests / backup / lint
    ↓
    └─ result: commit or PR (en repo)
```

**Ventajas:**
- ✅ Gratis (2000 minutos/mes)
- ✅ Native en GitHub
- ✅ Sin custom infra
- ✅ Auditable (workflow visible)

**Ejemplo workflow:**
```yaml
name: Nightly Tests
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
      - name: Commit results
        if: failure()
        run: |
          git config user.name "CI"
          git commit -am "fix: failing tests"
          git push
```

**Limitación:** Solo Linux/macOS runners. Windows requiere self-hosted (costo).

---

## Plan B: Cloud Compute (si necesitas 24/7 remoto)

**Cuándo:** Servidor producción, monitoreo continuo, streaming remoto

**Opciones:**

| Proveedor | Costo | Aptitud |
|---|---|---|
| **AWS Lambda** | $0.20/M requests + compute | Tasks bajo demanda (sin 24/7) |
| **Render.com** | $7-12/mes | Background jobs, cron |
| **Railway** | $5-10/mes | Scheduled tasks |
| **DigitalOcean** | $6-12/mes | VPS simple |
| **Heroku** | Deprecado (2024) | ❌ NO USAR |

**Arquitectura Lambda (recomendada):**
```
Claude Desktop → EventBridge (scheduled)
    ↓
    └─ trigger: cron rule
    ↓
    └─ Lambda function: ejecuta tarea
    ↓
    └─ result: push a GitHub / webhook
```

**Ventaja:** Paga solo por uso, sin servidor idle.

---

## Plan C: PC Secundaria via SSH (si hardware disponible)

**Cuándo:** VAIO u otra PC secundaria en red local

**Arquitectura (simple, sin loops):**

```
Claude Desktop (PC Principal)
    ↓ SSH key exchange
    └─ PC Secundaria (VAIO)
        ↓
        └─ Ejecuta tarea X bajo demanda (NO automático)
        ↓
        └─ Resultado vía git push o email
```

**Diferencia crítica con v3.10.x:**
- ❌ v3.10.x: scheduled tasks IA + loops cada 1 min
- ✅ v3.11.0+: tareas bajo demanda, iniciadas por usuario

**Setup:**
1. SSH key: `ssh-keygen -t ed25519` en ambas PCs
2. Autorizar key en PC secundaria: `.ssh/authorized_keys`
3. Test: `ssh user@vaio "git status"`
4. Integración: Claude Desktop detecta necesidad → SSH → ejecuta bajo demanda

**Ejemplo flujo:**
```
Usuario pregunta: "¿Qué cambios tiene Nemesis?"
Claude: "Necesito info de otra PC. ¿Autorizo SSH?"
Usuario: "Sí"
Claude: ssh vaio "git -C /path/to/nemesis log -5"
         [resultado vía stdout]
Claude: "Nemesis tiene 3 commits nuevos: ..."
```

**Ventajas:**
- ✅ Sin loops
- ✅ Sin triangularidad
- ✅ Demanda bajo pedido
- ✅ Auditable (Claude lo solicita, usuario aprueba)

**Limitación:** PC secundaria debe estar encendida (no 24/7)

---

## Lecciones de v3.10.x (A NO REPETIR)

### ❌ Anti-patrón 1: Loops infinitos
```powershell
# MALO (v3.10.x):
loop cada 1 min:
  git fetch
  si hay cambios:
    invocar deepseek-v4-pro  ← USD 10/día
  sleep 60s
```

**Corrección (v3.11.0+):**
```powershell
# BUENO:
Usuario pide acción → Claude → ejecuta bajo demanda → resultado
# SIN loops automáticos
```

### ❌ Anti-patrón 2: Scheduled tasks IA
```powershell
# MALO (v3.10.x):
Scheduled Task: run-every-minute.ps1
  → invoke-agent-task.ps1 deepseek-v4-pro
  → resultado a doc/vaio/results/
# Agente autónomo sin control
```

**Corrección (v3.11.0+):**
```powershell
# BUENO:
GitHub Actions (controlado)
O
Demanda manual (usuario aprueba)
```

### ❌ Anti-patrón 3: Triangularidad GitHub
```
tasks/ → git push
results/ ← git pull
# Frágil, manual, requiere polling
```

**Corrección (v3.11.0+):**
```
SSH directa O GitHub Actions webhook (event-driven)
```

### ✅ Lección clave
**Regla R79.2 (decisión humana sobre git)** se aplica igual a:
- Commits locales
- Scheduled tasks remotas
- Agentes autónomos

**Patrón seguro:**
```
Usuario da orden → Agente ejecuta → Solicita confirmación antes de git commit/push
NUNCA: Agente decide solo
```

---

## Línea de tiempo propuesta

| Fecha | Hito | Acción |
|---|---|---|
| **2026-07-31** | v3.11.0 | Deprecar VAIO, simplificar a Claude Desktop |
| **2026-08-31** (30 días) | Review | Si Claude Desktop es suficiente, mantener así |
| **2026-09-30** (90 días) | Decisión | Si necesita 24/7, migrar a Plan A/B/C |
| **2026-Q4** | Opción | Integrar GitHub Actions si aplica |

---

## Recomendación final

**Mantener v3.11.0 (Claude Desktop) por 6-12 meses.**

Cuando **realmente necesites** server remoto:
1. **Primero:** GitHub Actions (gratis, CI/CD)
2. **Si no alcanza:** Plan B cloud ($5-12/mes)
3. **Último recurso:** Plan C SSH (si tienes PC secundaria)

**NUNCA volver a:**
- Loops infinitos
- Scheduled tasks IA
- Triangularidad GitHub
- Agentes autónomos sin control humano

---

## Archivos relacionados
- `doc/arch/incidentes.md` — ICT-DIL-20260731-02, ICT-DIL-20260731-03 (problemas VAIO)
- `.old/deprecation-2026-07-31/` — VAIO + scripts deprecated
- `AGENTS.md` — Regla R79.2 (decisión humana)
