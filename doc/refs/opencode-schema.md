# opencode-schema.md — Schema oficial de opencode (referencia)

**Fuente:** `https://opencode.ai/config.json` (oficial) + `https://opencode.ai/docs/config/` (docs)
**Versión opencode analizada:** 1.18.9
**Severidad:** Este schema valida strict — cualquier key desconocida en la raíz causa `Unrecognized key` fatal.

---

## Ubicaciones del config (precedencia)

1. **Remote** (`.well-known/opencode` de orgs)
2. **Global** (`~/.config/opencode/opencode.json` o `.jsonc`)
3. **Custom** (`OPENCODE_CONFIG` env var)
4. **Per-project** (`opencode.json` en el proyecto, hasta el root de git)
5. **`.opencode/` dirs** (agents/, commands/, modes/, plugins/, skills/, tools/, themes/)
6. **Inline** (`OPENCODE_CONFIG_CONTENT` env var)
7. **Managed** (`/Library/Application Support/opencode/` en macOS)
8. **MDM** (managed preferences en macOS)

**Regla:** Se mergean, no se reemplazan. Más prioritario gana en conflicto.

---

## Keys válidos en la raíz (schema completo)

### Core
- `$schema` — URL al schema JSON
- `model` — ID del modelo default (`provider/model-name`)
- `small_model` — modelo para tareas ligeras (title generation, etc.)
- `default_agent` — qué agent usar cuando no se especifica (debe ser `primary`)

### Agents y permisos
- `agent` — configuración de agents (map de agent-name → agent-config)
- `subagent_depth` — profundidad de invocación de subagents (0 = desactivar, default 1)
- `permission` — permisos globales (edit, bash, webfetch, etc.)
- `tools` — habilitar/deshabilitar tools boolean

### Integrations
- `provider` — config de providers LLM (minimax, anthropic, openai, etc.)
- `provider_overrides` — overrides por provider (timeout, baseURL)
- `disabled_providers` — denylist
- `enabled_providers` — allowlist (default: todos)
- `mcp` — servidores MCP (Model Context Protocol)
- `lsp` — servidores LSP
- `formatter` — code formatters
- `plugin` — plugins npm

### Behavior
- `shell` — shell preferido para tool calls (pwsh, bash, etc.)
- `compaction` — estrategia de compactación de contexto (auto, prune, reserved)
- `snapshot` — habilitar snapshots para undo/revert
- `watcher` — patrones ignore del file watcher

### Runtime
- `server` — config de `opencode serve` (port, hostname, mdns, cors)
- `autoupdate` — auto-update (true/false/notify)
- `share` — modo de share (manual/auto/disabled)

### UX/integrations
- `attachment` — config de image attachments
- `instructions` — array de paths/globs a archivos de instrucciones (válidos)
- `experimental` — features en desarrollo

---

## Keys NO válidos (anti-patrones documentados)

| Key | Por qué no |
|---|---|
| `_diligencia` (cualquier custom) | Schema strict rechaza. ICT-DIL-20260731-01. |
| `_metadata` | Mismo error. |
| `theme` en `opencode.json` | Pertenece a `tui.json` (legacy pero se migra). |
| `keybinds` en `opencode.json` | Pertenece a `tui.json`. |
| `tui` en `opencode.json` | Deprecated, mover a `tui.json`. |

---

## Sub-keys del schema (campos válidos dentro de keys raíz)

### `provider.<id>` (estructura)
```json
{
  "provider": {
    "<providerID>": {
      "options": {
        "apiKey": "...",
        "baseURL": "...",
        "timeout": 300000
      },
      "models": {
        "<modelID>": {
          "name": "Display Name",
          "limit": { "context": 200000, "output": 8192 }
        }
      }
    }
  }
}
```

### `agent.<id>` (estructura)
```json
{
  "agent": {
    "<agentName>": {
      "description": "...",
      "model": "<provider/model>",
      "prompt": "{file:./.opencode/prompts/agent.txt}",
      "mode": "primary" | "subagent" | "all",
      "tools": { "write": false },
      "permission": { "edit": "deny", "bash": "ask" },
      "temperature": 0.1,
      "steps": 10
    }
  }
}
```

### `permission` (glob patterns soportados)
- `"*"` — wildcard para todas las acciones
- `"bash"` — todas las bash
- `"bash:git *"` — solo `git` commands
- `"edit"`, `"webfetch"`, `"mcp"` — top-level actions
- `"doom_loop"` — prompts cuando LLM se traba

### `compaction` (opciones)
- `auto` — boolean, auto-compactar cuando context se llene
- `prune` — boolean, podar outputs viejos
- `reserved` — número, buffer de tokens

### `server` (sub-keys)
- `port` (default 4096)
- `hostname` (default 127.0.0.1; usar 0.0.0.0 para acceso externo)
- `mdns` (boolean, discovery)
- `mdnsDomain` (string)
- `cors` (array of full origins)

### `instructions` (sub-keys)
- Array de strings paths/globs
- Soporta `{env:VAR}`, `{file:./path}` (variable substitution)

---

## Variable substitution (en strings)

| Formato | Significado |
|---|---|
| `{env:VARIABLE}` | Reemplaza con valor de env var |
| `{file:./relative}` | Reemplaza con contenido de archivo |
| `{file:/absolute}` | Reemplaza con contenido de archivo |

Si la variable no existe, se reemplaza con string vacío.

---

## Cómo validar un JSONC contra este schema

1. **Manual**: Abrir con editor que tenga JSON Schema validation (VS Code + extensión)
2. **CLI**: `opencode debug config` — exit code 0 = válido, 1 = inválido
3. **Programático**: Validar key por key contra la lista anterior

---

## Files relacionados
- `https://opencode.ai/config.json` — schema canónico
- `https://opencode.ai/docs/config/` — docs
- `https://opencode.ai/docs/agents/` — docs de agents
- `https://opencode.ai/docs/providers/` — docs de providers
- `doc/refs/integration-patterns.md` — patrones seguros de integración
- `doc/arch/incidentes.md` — `ICT-DIL-20260731-01` causa este documento
