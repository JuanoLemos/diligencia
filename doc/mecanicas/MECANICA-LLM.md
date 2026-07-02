# MECANICA-LLM — Patrón multi-proveedor LLM v1.0

Patrón arquitectónico para integrar múltiples proveedores LLM en un proyecto,
extraído de Crucix-master (`lib/llm/`). Permite cambiar o combinar modelos sin
modificar el código de negocio.

---

## §1 — Por qué multi-proveedor

Cada modelo tiene fortalezas distintas. Un solo proveedor no es óptimo para
todas las tareas:

| Tarea | Modelo recomendado | Razón |
|---|---|---|
| Razonamiento profundo, diseño | DeepSeek V4 Pro, Claude | Mejor calidad de análisis |
| Ejecución rápida, código | DeepSeek V4 Flash, MiniMax M2.7 | Más barato, más rápido |
| Multimodal (imagen, video, voz) | MiniMax M3, GPT-5 | Soporte nativo de modalidades |
| Procesamiento local, privacidad | Ollama (llama.cpp) | Sin datos fuera del dispositivo |
| Prototipado, bajo costo | OpenRouter, OpenCode Zen | Paga por uso sin suscripción |

El benchmark Diligencia (Benchmark MiniMax vs DeepSeek, v2.5.0) confirmó que
DeepSeek V4 Pro (8.88/10) supera a MiniMax M3 (7.50/10) en código y razonamiento,
pero MiniMax gana en multimodal y costo fijo.

---

## §2 — Interfaz base

Clase abstracta que todos los providers implementan:

```js
class LLMProvider {
  constructor(config) {
    this.config = config;
    this.name = 'base';
    this.model = config.model || 'default';
  }

  async complete(systemPrompt, userMessage, opts = {}) {
    throw new Error(`${this.name}: complete() not implemented`);
  }

  get isConfigured() { return false; }
}
```

### Parámetros de `complete()`

| Parámetro | Tipo | Default | Descripción |
|---|---|---|---|
| `systemPrompt` | string | — | Instrucciones del sistema |
| `userMessage` | string | — | Mensaje del usuario |
| `opts.maxTokens` | number | 4096 | Máximo de tokens de output |
| `opts.timeout` | number | 60000 | Timeout en ms |

### Formato de retorno

```js
{
  text: string,               // contenido de la respuesta
  usage: {
    inputTokens: number,       // tokens de entrada
    outputTokens: number       // tokens de salida
  },
  model: string               // modelo que respondió
}
```

---

## §3 — Factory pattern

Un punto central de creación que oculta la complejidad de instanciación:

```js
import { AnthropicProvider } from './anthropic.mjs';
import { OpenAIProvider } from './openai.mjs';
import { MiniMaxProvider } from './minimax.mjs';
// ... más providers

export function createLLMProvider(config) {
  const { provider, apiKey, model } = config;

  switch (provider) {
    case 'anthropic': return new AnthropicProvider({ apiKey, model });
    case 'openai':    return new OpenAIProvider({ apiKey, model });
    case 'minimax':   return new MiniMaxProvider({ apiKey, model });
    case 'deepseek':  return new DeepSeekProvider({ apiKey, model });
    // ... más casos
    default:
      throw new Error(`Unknown LLM provider: ${provider}`);
  }
}
```

### Uso desde el código de negocio

```js
const llm = createLLMProvider({
  provider: 'minimax',
  apiKey: process.env.MINIMAX_API_KEY,
  model: 'MiniMax-M3'
});

const result = await llm.complete(
  'Eres un asistente útil.',
  '¿Cuál es la capital de Francia?'
);

console.log(result.text); // "París"
```

El código de negocio nunca sabe qué proveedor concreto está usando. Cambiar
de proveedor solo requiere cambiar la configuración.

---

## §4 — Config-driven

La configuración se maneja en cascada:

```
.env → config.{js,json,yaml,py} → createLLMProvider(config)
```

### Ejemplo `.env`

```env
# Proveedor activo
LLM_PROVIDER=minimax
LLM_MODEL=MiniMax-M3

# API keys de todos los proveedores (solo se usa el activo)
DEEPSEEK_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
MINIMAX_API_KEY=mx-...
OPENAI_API_KEY=sk-...
```

### Ejemplo `config.yaml`

```yaml
llm:
  default_provider: minimax
  default_model: MiniMax-M3
  providers:
    deepseek:
      api_key: ${DEEPSEEK_API_KEY}
      model: deepseek-v4-pro
    minimax:
      api_key: ${MINIMAX_API_KEY}
      model: MiniMax-M3
```

---

## §5 — Catálogo de providers

Implementaciones de referencia en Crucix-master (`lib/llm/`):

| Provider | Clase | Endpoint API | Autenticación |
|---|---|---|---|
| Anthropic | `AnthropicProvider` | `api.anthropic.com/v1/messages` | `x-api-key` header |
| OpenAI | `OpenAIProvider` | `api.openai.com/v1/chat/completions` | `Bearer` token |
| MiniMax | `MiniMaxProvider` | `api.minimax.io/v1/chat/completions` | `Bearer` token |
| DeepSeek | — | `api.deepseek.com/v1/chat/completions` | `Bearer` token |
| OpenRouter | `OpenRouterProvider` | `openrouter.ai/api/v1/chat/completions` | `Bearer` token |
| Gemini | `GeminiProvider` | `generativelanguage.googleapis.com/v1/models` | API key query param |
| Grok | `GrokProvider` | `api.x.ai/v1/chat/completions` | `Bearer` token |
| Mistral | `MistralProvider` | `api.mistral.ai/v1/chat/completions` | `Bearer` token |
| Ollama (local) | `OllamaProvider` | `localhost:11434/v1/chat/completions` | Ninguna |
| Codex | `CodexProvider` | — | — |

Todos sin SDKs externos — `fetch()` crudo con `AbortSignal.timeout()`.

---

## §6 — Sin dependencias de SDK

Cada provider usa `fetch()` nativo de Node.js. Sin npm install de SDKs de
proveedores. El patrón es siempre el mismo:

```js
async complete(systemPrompt, userMessage, opts = {}) {
  const res = await fetch(API_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.apiKey}`,
    },
    body: JSON.stringify({
      model: this.model,
      max_tokens: opts.maxTokens || 4096,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userMessage },
      ],
    }),
    signal: AbortSignal.timeout(opts.timeout || 60000),
  });

  if (!res.ok) {
    const err = await res.text().catch(() => '');
    throw new Error(`${this.name} API ${res.status}: ${err.substring(0, 200)}`);
  }

  const data = await res.json();
  const text = data.choices?.[0]?.message?.content || '';

  return { text, usage: data.usage, model: data.model || this.model };
}
```

---

## §7 — Estrategia híbrida

Un proyecto puede usar múltiples providers simultáneamente según la tarea:

```js
const razonador = createLLMProvider({ provider: 'deepseek', model: 'deepseek-v4-pro' });
const ejecutor  = createLLMProvider({ provider: 'minimax',  model: 'MiniMax-M2.7' });
const multimodal = createLLMProvider({ provider: 'minimax', model: 'MiniMax-M3' });

// Tarea de diseño → razonador
const diseno = await razonador.complete('Diseña la arquitectura...', '...');

// Tarea de ejecución → ejecutor (más barato)
const codigo = await ejecutor.complete('Implementa el endpoint...', '...');

// Tarea con imágenes → multimodal
const analisis = await multimodal.complete('Analiza esta imagen...', '...');
```

### Matriz de decisión

| Tarea | Provider recomendado | Costo relativo |
|---|---|---|
| Diseño, code review | DeepSeek V4 Pro / Claude | Alto |
| Implementación rápida | DeepSeek V4 Flash / MiniMax M2.7 | Medio |
| Análisis de imágenes | MiniMax M3 / GPT-5 | Medio |
| Generación de video | MiniMax Hailuo 2.3 | Fijo por clip |
| TTS / voz | MiniMax speech-2.8 / ElevenLabs | Bajo-medio |
| Prototipado / debug | Ollama local / OpenCode Zen | Gratis-bajo |

---

## Archivos relacionados
- `MECANICA-MEMORY.md` — persistencia de estado del sistema
- `doc/arch/benchmark-minimax-vs-deepseek.md` — benchmark comparativo
- `Crucix-master/lib/llm/` — implementación de referencia (12 providers)
- `~/.config/opencode/agents/disenador.md` — agente diseñador con MiniMax M3
