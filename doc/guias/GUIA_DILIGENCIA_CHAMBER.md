# GUIA DILIGENCIA CHAMBER — Cómo Diligencia se integra con OpenChamber v1.0.0

Diligencia y OpenChamber tienen una relación de cerebro ↔ cuerpo. Diligencia gobierna comandos, reglas, circuitos, herencia y versionado. Chamber ejecuta la interfaz visual: terminal, diff viewer, file browser, notificaciones, y próximamente paneles interactivos.

---

## 1. Roles

| Capa | Diligencia | Chamber |
|---|---|---|
| Rol | Cerebro — metodología y orquestación | Cuerpo — interfaz visual y ejecución |
| Comandos | 28 comandos fundamentales en `.opencode/commands/` | Accesibles vía terminal integrado |
| Repo | `github.com/JuanoLemos/diligencia.git` | `github.com/JuanoLemos/openchamber` (fork de `btriapitsyn/openchamber`) |
| Skills | 7 skills locales (consejo, circuito, SDD, etc.) | Skills Catalog (próximamente) |

## 2. Estado actual

| Componente | Estado |
|---|---|
| Chamber adaptado a Diligencia | ✅ v1.18.1 (pendiente upgrade a v2.2.0) |
| Comandos Diligencia en terminal Chamber | ✅ |
| Panel UX interactivo (R49) | 🔴 Pendiente |
| Dashboard visual (R36) | 🔴 Pendiente |
| Iconos por proyecto (R51) | 🔴 Pendiente |
| Badge BETA en README (R37) | 🔴 Pendiente |

## 3. Workflow típico

```
1. Abrir Chamber → terminal integrado
2. /estado → ver salud del proyecto
3. /next → plan de ejecución por olas
4. /plan --ola 1 → planificar grupo de tareas
5. BUILD → implementar
6. /commit --push → commitear
7. /version → cerrar sesión
```

## 4. Roadmap de integración

| R# | Feature | Estado |
|---|---|---|
| R25 | Adaptación liviana: DILIGENCIA.md + INDEX + RM + AGENTS | 🔴 Pendiente |
| R26 | Multi-proyecto visual con $PROYECTOS | 🔴 Pendiente |
| R35 | 8 temas Diligencia en formato Chamber JSON | 🔴 Pendiente |
| R36 | Dashboard React (cards por proyecto) | 🔴 Pendiente |
| R47 | Botones /CBP /doctor /salud en UI de Chamber | 🔴 Pendiente |
| R49 | Panel interactivo UX Checklist | 🔴 Pendiente |
| R51 | Iconos personalizados por proyecto | 🔴 Pendiente |

## Archivos relacionados
- `GUIA_CHAMBER.md` — guía de usuario de OpenChamber
- `AGENTS.md` — variables `$PROYECTOS`, `$UX_CHECK`
- `ROADMAP.md` — items R25-R30, R35-R44, R47, R49-R51
- `.opencode/commands/` — comandos disponibles en terminal Chamber
