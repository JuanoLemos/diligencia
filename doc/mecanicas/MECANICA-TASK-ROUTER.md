# MECANICA-TASK-ROUTER — Enrutador de tareas por tipo v1.0

Define qué agente + modelo + API se usa para cada tipo de trabajo.
El MAIN lee esta tabla al iniciar una tarea y delega automáticamente.

---

## Tabla de ruteo

| Tipo de tarea | Agente | Modelo | APIs externas | ¿Qué hace? |
|---|---|---|---|---|
| Diseño UI/UX | `@disenador` | MiniMax M3 | MiniMax image-01 | Mockups, paletas, componentes |
| Arquitectura / plan | `@sdd-architect` | DeepSeek V4 Pro | — | Diseño de sistemas, propuestas |
| Implementación código | `@sdd-implement` | DeepSeek V4 Flash | — | Escribir código, endpoints |
| Revisión de código | `@sdd-reviewer` | DeepSeek V4 Pro | — | Audit de PRs, bugs, seguridad |
| Verificación / tests | `@sdd-verify` | DeepSeek V4 Flash | — | Ejecutar tests, validar |
| Auditoría documental | `@documentador` | DeepSeek V4 Pro | — | 24 checks, versiones, cross-refs |
| Decisión / consejo | `@consejero` | DeepSeek V4 Pro | — | Roadmap, dominio, trayectoria |
| Integridad lógica | `@circuito` | DeepSeek V4 Flash | — | Handlers, rutas, UX, navegación |
| Prompt narrativo / worldbuilding | `@narrador` | DeepSeek V4 Pro | ElevenLabs Text-to-Dialogue | System prompts, personajes, Nemesis |
| Mecánicas de juego / balance | `@game-designer` | DeepSeek V4 Pro | — | Balance, economía, árbol tecnológico |
| Trading / finanzas | `@trader` | DeepSeek V4 Pro | — | Estrategias, riesgo, brokers |
| Mapas / datos geoespaciales | `@cartografo` | DeepSeek V4 Pro | — | GIS, terrain, chunks, conquisitare |
| Producción de video | `@editor-video` | MiniMax M3 | MiniMax video + ElevenLabs TTS | Pipeline composición OpenMontage |
| Sistemas de diseño (CSS) | `@design-system` | DeepSeek V4 Pro | — | Componentes, paletas, accesibilidad |
| Narración / voz | MAIN genera código | — | ElevenLabs TTS + Voice Clone | TTS en Nemesis, OpenMontage |
| STT (voz a texto) | MAIN genera código | — | ElevenLabs Scribe v2 | Comandos por voz en Chamber |
| SFX / efectos sonido | MAIN genera código | — | ElevenLabs SFX + MiniMax Music-2.6 | Efectos para conquisitare |
| Video generación | MAIN genera código | — | MiniMax Hailuo 2.3 | Videos para OpenMontage |
| Propagación | `/propagar` | — | — | Actualizar $PROYECTOS |
| Versionado | `/CBP version` | — | — | CHANGELOG + tag + push |
| Hosting / deploy | MAIN | DeepSeek V4 Pro | — | Servidor, Docker, VPS |

---

## Cómo se usa

1. El usuario dice "hacé X"
2. MAIN clasifica la tarea por tipo
3. Busca el tipo en la tabla
4. Delega al agente correcto con el modelo correcto
5. Si hay APIs externas, el código generado las llama con las keys del maestro `.env`

## Reglas

- MAIN no ejecuta tareas que tienen un agente asignado — delega.
- Si el tipo no está en la tabla, MAIN decide con criterio y anota el caso para agregarlo.
- Si múltiples tipos aplican, priorizar: Arquitectura → Implementación → Revisión.

## Archivos relacionados
- `MECANICA-LLM.md` — estrategia multi-proveedor
- `~/.config/opencode/agents/` — definiciones de agentes
- `~/.config/opencode/.env` — API keys maestro
- `doc/arch/benchmark-minimax-vs-deepseek.md` — benchmark que justifica la estrategia híbrida
