# Benchmark: DeepSeek V4 Pro vs MiniMax M3

> Evaluación comparativa de modelos para agentes de razonamiento en Diligencia.
> Fecha: 2026-07-01
> Metodología: A/B parallel — misma tarea, mismo prompt, mismo proyecto

---

## Escenario 1 — Diseño arquitectura (sdd-architect)

**Tarea**: Diseñar sistema de notificaciones push para Nemesis (WebSocket + FCM + cola de jobs + SQLite)

| Dimensión | DeepSeek V4 Pro | MiniMax M3 |
|---|---|---|
| **Propuesta** | Completa: alcance, 13 RF, 9 RNF, 4 non-goals | Completa: alcance, 11 RF, 8 RNF, 6 non-goals |
| **Especificación técnica** | Diagrama ASCII, 6 componentes detallados, flujo completo 3 paths, endpoints, eventos WS, esquema DB, variables de entorno | Diagrama ASCII, 5 componentes, flujo completo, endpoints, eventos WS, esquema DB, .env |
| **Decisiones de diseño** | 8 decisiones justificadas (DD-01 a DD-08) | 6 decisiones justificadas (DD-01 a DD-06) |
| **Plan de tareas** | 19 tareas en 5 olas con dependencias, ~1500 líneas estimadas | 13 tareas en 6 fases, ~3h estimadas |
| **Total archivos planificados** | 10 nuevos + 9 modificados | 4 nuevos + 7 modificados |
| **Calidad decisiones** | Socket.io sobre ws (auto-reconnect), cola SQLite, FCM feature flag, módulo autocontenido | ws puro (0 dep), cola SQLite, skip-queue para WS online, auth query param heredado |
| **Puntos fuertes** | Más realista: socket.io (el frontend ya necesita reconexión), feature flag FCM, tabla normalizada 3 tablas | Más minimalista: ws puro menos peso, skip de cola para online, menos archivos nuevos |
| **Puntos débiles** | Over-engineered para MVP: socket.io + firebase-admin en paquete, 19 tareas es ambicioso | Subestimó el frontend: solo 2 archivos modificados, no consideró Service Worker FCM |
| **Veredicto** | 8.5/10 — mejor para producción | 7.5/10 — mejor para MVP rápido |

---

## Escenario 2 — Implementación de código (sdd-implement)

**Tarea**: Endpoint GET /api/stats en +RM — estadísticas de casos con auth, validación, SQL

| Dimensión | DeepSeek V4 Flash | MiniMax M2.7 |
|---|---|---|
| **Código entregado** | Endpoint PHP completo, SQL DDL, seed data | Endpoint PHP completo, SQL DDL |
| **Auth** | API Key via X-API-Header + `hash_equals()` timing-safe | Bearer token + `hash_equals()` timing-safe |
| **Manejo de errores** | DB conn, query errors, debug mode condicional | DB conn, query errors, debug mode condicional |
| **Base de datos** | MySQL + SQLite dual (configurable en config.php) | SQLite only |
| **Extras** | .htaccess rewrite rules, seed de prueba, duración en minutos | Inline CREATE TABLE IF NOT EXISTS, duración formateada "47h 20min" |
| **Formato JSON** | Total + por estado + promedio + metadata | Total + por estado + promedio + texto legible |
| **Puntos fuertes** | Dual DB option, seed data, .htaccess | Duración legible, inline migration, CHECK constraint |
| **Puntos débiles** | MySQL es overkill para proyecto sin DB | Sin seed data, solo SQLite |
| **Veredicto** | 8.5/10 — más completo | 8/10 — sólido pero menos opciones |

---

## Escenario 3 — Code Review (sdd-reviewer)

**Tarea**: Encontrar bugs en diff simulado con 3 bugs intencionales (SQL injection, missing param, password leak)

| Dimensión | DeepSeek V4 Pro | MiniMax M3 |
|---|---|---|
| **SQL injection detectado** | ✅ B1 — 🔴 Blocker | ✅ 1 — 🔴 Blocker |
| **Missing parameter detectado** | ✅ B2 — 🔴 Blocker (query nunca ejecuta) | ✅ 3 — 🟡 Important (nota: se otorgan puntos igual) |
| **Password_hash exposure** | ✅ B3 — 🔴 Blocker | ✅ 2 — 🔴 Blocker |
| **CSV injection** | ✅ B4 — 🔴 Blocker (formula injection + mal escape) | ✅ 4 — 🟡 Important (menciona formula injection) |
| **`==` vs `===`** | ✅ I1 — 🟡 Important (coerción de tipos) | ✅ 5 — 🔵 Nice-to-have |
| **Content-Disposition** | ✅ I2 — 🟡 Important | ❌ No detectado |
| **Paginación / rate limit** | ✅ N1 — 🔵 Nice-to-have | ❌ No detectado |
| **String concat ineficiente** | ✅ N2 — 🔵 Nice-to-have | ❌ No detectado |
| **Código fix inline** | ✅ Sí — cada hallazgo con código de corrección | ❌ Solo descripción |
| **Clasificación severidad** | ✅ Clara y consistente | ✅ Clara y consistente |
| **Total hallazgos** | 8 (4 🔴 + 2 🟡 + 2 🔵) | 5 (3 🔴 + 2 🟡 + 0 🔵) |
| **Veredicto** | 9.5/10 — excepcionalmente minucioso | 7/10 — bueno pero perdió 3 hallazgos |

---

## Escenario 4 — Auditoría documental (documentador)

**Tarea**: 24 checks en 6 categorías sobre Diligencia

| Dimensión | DeepSeek V4 Pro | MiniMax M3 |
|---|---|---|
| **Total verificaciones** | 24 checks (6 categorías) | 26 verificaciones |
| **Hallazgos P1 (críticos)** | 1 (INDEX.md resumen numérico incorrecto) | 0 |
| **Hallazgos P2 (importantes)** | 12 | 6 |
| **Hallazgos P3 (menores)** | 4 | 4 |
| **Sin novedad** | 4 | 16 |
| **Detección de versión desfasada** | ✅ 7 archivos con versión incorrecta | ✅ 3 archivos detectados |
| **Detección de referencias stale** | ✅ CHECKLIST en DILIGENCIA/HARNESS/INDEX/README | ✅ CHECKLIST en HARNESS |
| **Conteo comandos** | ✅ Detectó 3 cifras distintas (29/30/33) | ✅ 29 vs 30 |
| **Puntos fuertes** | Más agresiva en hallazgos, detectó errores sutiles (versiones desfasadas, referencias cruzadas) | Más conservadora, 0 P1, enfocada en lo estructural |
| **Puntos débiles** | Puede ser excesivo (20 hallazgos en proyecto sano) | Menos profunda en versiones y referencias cruzadas |
| **Veredicto** | 9/10 — auditoría exhaustiva | 7.5/10 — auditoría ligera |

---

## Scorecard general

| Escenario | DeepSeek | MiniMax | Ganador |
|---|---|---|---|
| 1 — Diseño arquitectura | 8.5 | 7.5 | **DeepSeek V4 Pro** |
| 2 — Implementación | 8.5 | 8.0 | **DeepSeek V4 Flash** (margen estrecho) |
| 3 — Code Review | 9.5 | 7.0 | **DeepSeek V4 Pro** (notable diferencia) |
| 4 — Auditoría documental | 9.0 | 7.5 | **DeepSeek V4 Pro** |
| **Promedio** | **8.88** | **7.50** | **+1.38 puntos DeepSeek** |

### ¿Puede MiniMax reemplazar a DeepSeek?

| Para rol actual de: | Modelo actual | Recomendación |
|---|---|---|
| `sdd-architect` (diseño) | DeepSeek V4 Pro | 😴 Mantener DeepSeek — MiniMax M3 fue sólido pero menos profundo |
| `consejero` (análisis) | DeepSeek V4 Pro | 😴 Mantener DeepSeek — necesita profundidad |
| `sdd-reviewer` (code review) | DeepSeek V4 Pro | 😴 **Mantener DeepSeek** — MiniMax perdió 3/8 hallazgos |
| `documentador` (auditoría) | DeepSeek V4 Pro | 😴 Mantener DeepSeek — más exhaustivo |
| `sdd-implement` (ejecución) | DeepSeek V4 Flash | 🤔 **Evaluar MiniMax M2.7** — fue comparable en calidad |
| `sdd-verify` (tests) | DeepSeek V4 Flash | 😴 Mantener DeepSeek — no testeado |
| `circuito` (integridad) | DeepSeek V4 Flash | 😴 Mantener DeepSeek — no testeado |

### Conclusión

**MiniMax M3 aún no supera a DeepSeek V4 Pro en razonamiento y código.** La brecha es más notable en code review (9.5 vs 7.0) donde MiniMax perdió detalles importantes. DeepSeek V4 Flash vs MiniMax M2.7 en implementación fue el empate más cercano (8.5 vs 8.0).

**Estrategia recomendada:**
1. **Mantener DeepSeek para agentes de razonamiento** (PRO: architect, reviewer, consejero, documentador)
2. **Probar MiniMax M2.7 para ejecución** (Flash: implement, verify) — hubo paridad
3. **MiniMax se gana su lugar por multimodal** (imagen/video/audio/música) y el **Token Plan de $50** que ofrece ~20× más tokens que el equivalente en DeepSeek
4. **Rol ideal de MiniMax en el ecosistema**: proyectos Nemesis (voz narrativa), Crucix-master (análisis multimodal), OpenMontage (video generación) + backup de agente cuando DeepSeek esté saturado
