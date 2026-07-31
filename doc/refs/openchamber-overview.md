# openchamber-overview.md — Chamber (openchamber fork) referencia

**Fuente:** `https://docs.openchamber.dev/` (oficial) + fork local en `C:\Users\jlemo\OneDrive\Desktop\openchamber`
**Última actual de upstream docs:** 2026-07-28
**Fork local:** chamber electron para Windows, custom tunnel integration (ngrok + Cloudflare)

---

## ¿Qué es Chamber?

Chamber es el **workspace visual alrededor de opencode**. Es la "sala de control" para:
- Ver y steer sesiones de opencode en una UI gráfica
- Branching sessions (worktrees)
- Review de diffs
- Gestión de terminals
- Project actions y automation
- Multi-device sync via relay cifrado E2E

**Upstream:** [openchamber/openchamber](https://github.com/openchamber/openchamber) — 82.6k stars

**Fork local del usuario:** `C:\Users\jlemo\OneDrive\Desktop\openchamber` — incluye integraciones custom de tunnel (ngrok + Cloudflare) y runtime fork del Electron app.

---

## Arquitectura

```
┌─────────────────────────────────────────────────┐
│  Chamber Electron (UI visual)                   │
│  ├─ Desktop renderer (React)                    │
│  ├─ Main process (Electron)                     │
│  └─ OpenChamber server (Bun/Node)               │
│      ├─ Projects (multi-project)                │
│      ├─ Worktrees (branching sessions)          │
│      ├─ Sessions (session mgmt)                 │
│      ├─ Tools/LSP/MCP integrators              │
│      └─ Tunnel system (ngrok/Cloudflare)        │
└─────────────────────────────────────────────────┘
                  │
                  │  ACP (Agent-Client Protocol)
                  ▼
┌─────────────────────────────────────────────────┐
│  opencode CLI / serve (backend)                  │
│  ├─ HTTP API on :4096                            │
│  ├─ Agents (build, plan, custom)                │
│  ├─ Providers (MiniMax, Anthropic, etc.)        │
│  └─ Session state                                │
└─────────────────────────────────────────────────┘
```

---

## Tunnel system (provider management)

Chamber gestiona túneles vía `openchamber tunnel` CLI.

### Providers soportados

| Provider | Modos | Built-in |
|---|---|---|
| **Cloudflare** | quick, managed-remote, managed-local | ✅ |
| **ngrok** | quick | ✅ |
| **Private Relay** | cifrado E2E, sin port abierto | ✅ |

### CLI commands

```bash
openchamber tunnel start --provider ngrok --mode quick   # QR code
openchamber tunnel start --provider cloudflare --mode quick
openchamber tunnel start --provider cloudflare --mode managed-remote --token <TOKEN> --hostname app.example.com
openchamber tunnel status                                  # ver URL publica
openchamber tunnel stop --port 3000
openchamber tunnel providers                                # ver providers
```

### URLs generadas (formato)

- **Cloudflare quick**: `https://<random>.trycloudflare.com`
- **ngrok free**: `https://<random>.ngrok-free.dev`
- **ngrok paid**: `https://<your-domain>.ngrok.app` (URL estable)

**Limitaciones free tier:**
- URL cambia cada restart
- Bandwidth limitada
- Solo 1 tunnel activo por sesión

---

## Workflows principales

| Categoría | Features |
|---|---|
| **Workflows** | Projects, Context, Notes/Todos/Plans, Scheduled Tasks, Agent Control Tool, Session Goals, Project Actions, Preview/Dev Servers, Worktree Sessions, Multi-run, Git/GitHub, Magic Prompts, Git Identities |
| **OpenCode setup** | Providers/Models/Agents, MCP Servers, Skills, Skills Catalog, Commands/Snippets, Usage/Quotas |
| **Remote access** | Connect Device, Private Relay, Tunnels, Reverse Proxy, Mobile Apps/PWA, Security |
| **Customize** | Themes, Notifications, Voice Mode, Project Icons |
| **Desktop** | Remote Instances, Desktop Browser, Desktop Tunnels, SSH Hosts/Proxying, Updates |

---

## Integración con opencode

Chamber usa **ACP (Agent-Client Protocol)** para comunicarse con opencode.

```bash
# Chamber conecta a opencode:
openchamber connect <opencode-server-url:4096>
```

Una vez conectado, Chamber provee:
- UI visual sobre las sesiones de opencode
- Gestión de providers/models desde la UI
- Skills catalog
- Commands/snippets

---

## Variables clave

| Variable | Significado |
|---|---|
| `OPENCHAMBER_PORT` | Puerto del server (default 3000) |
| `OPENCHAMBER_HOST` | Hostname (default 127.0.0.1) |
| `NGROK_AUTHTOKEN` | Token de ngrok (almacenado en `~/.config/ngrok/ngrok.yml`) |
| `CLOUDFLARE_TOKEN` | Token de Cloudflare (managed-remote mode) |

---

## Config file locations

| Path | Propósito |
|---|---|
| `~/.config/opencode/opencode.jsonc` | opencode config global |
| `~/.local/share/opencode/auth.json` | credenciales de providers |
| `~/.config/ngrok/ngrok.yml` | ngrok config y tunnels |
| `~/openchamber/` (fork local) | código fuente fork del usuario |
| `%ProgramData%\opencode` | Managed settings (Windows) |

---

## Estado actual del fork local

Componentes verificados:
- ✅ Chamber Electron进程 corriendo en :57123
- ✅ ngrok 3.39.10 instalado (Winget actualizado)
- ✅ Tunnel dual activo: `https://unthread-spent-hut.ngrok-free.dev` → :4096 (opencode) Y :57123 (Chamber)
- ⚠️ Upstream tiene 32+ commits divergentes vs fork local (no sincronizado)

---

## Files relacionados
- `https://docs.openchamber.dev/` — docs oficial
- `https://github.com/openchamber/openchamber` — upstream
- `C:\Users\jlemo\OneDrive\Desktop\openchamber` — fork local
- `doc/refs/opencode-schema.md` — schema opencode (necesario para Chamber)
- `doc/refs/integration-patterns.md` — patrones integración seguros
