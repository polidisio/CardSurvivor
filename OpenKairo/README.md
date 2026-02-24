# OpenKairo

Asistente de IA autoalojado tipo OpenClaw con soporte multi-provider y gestión avanzada de tokens.

## Características

- **Multi-provider**: Anthropic, OpenAI, Google Gemini, Ollama (local)
- **Gestión avanzada de tokens**: Cache, compresión de contexto, alertas de presupuesto
- **Persistencia**: Personalidad, memoria y conversaciones (30 días)
- **Canales**: Telegram, Discord
- **Tools**: Shell, archivos, HTTP fetch
- **Arquitectura**: Gateway WebSocket con sesiones persistentes

## Estructura del Workspace

```
~/.openkairo/workspace/
├── AGENTS.md      # Personalidad del agente (system prompt)
├── MEMORY.md     # Hechos aprendidos y preferencias
├── CONTEXT.md    # Contexto adicional persistente
└── sessions/     # Historial de conversaciones (30 días)
    └── 2026-02-24-telegram-123456.json
```

## Instalación

```bash
npm install
```

## Configuración

```bash
# Iniciar onboarding interactivo
npm run dev -- onboard

# O editar config manualmente
openkairo config set providers.anthropic.apiKey "sk-ant-..."
```

## Uso

```bash
# Iniciar el Gateway (en una terminal)
npm run dev -- start

# Iniciar la TUI (en otra terminal)
npm run dev -- tui
```

### Navegación TUI

- `[1]` Chat - Chatear con el agente
- `[2]` Historial - Ver conversaciones pasadas
- `[3]` Admin - Stats y memoria
- `[4]` Settings - Cambiar provider/modelo
- `[r]` Actualizar - Refresh en Admin
- `[h]` Ayuda - Mostrar ayuda
- `[q]` Salir - Cerrar TUI

### Otros comandos

```bash
# Ver workspace
openkairo workspace

# Editar personalidad
openkairo personality edit

# Ver memoria
openkairo memory show
openkairo memory facts

# Ver stats
curl http://localhost:18789/stats

# Ver memoria via API
curl http://localhost:18789/memory
```

## Configuración Manual

Editar `~/.openkairo/config.json`:

```json
{
  "gateway": {
    "port": 18789,
    "host": "127.0.0.1"
  },
  "providers": {
    "anthropic": {
      "apiKey": "sk-ant-...",
      "model": "claude-sonnet-4-20250514"
    },
    "openai": {
      "apiKey": "sk-...",
      "model": "gpt-4o"
    }
  },
  "defaultProvider": "anthropic",
  "channels": {
    "telegram": {
      "token": "..."
    },
    "discord": {
      "token": "..."
    }
  },
  "tokenManagement": {
    "enabled": true,
    "cacheEnabled": true,
    "contextCompression": true,
    "maxContextTokens": 100000,
    "alertThreshold": 0.8,
    "budgets": {
      "anthropic": 10,
      "openai": 10
    }
  }
}
```

## API

### HTTP

- `GET /health` - Estado del servidor
- `GET /stats` - Estadísticas de uso

### WebSocket

Conectar a `ws://localhost:18790` y enviar mensajes JSON:

```json
{
  "type": "create-session",
  "channelId": "telegram",
  "userId": "123456"
}
```

```json
{
  "type": "chat",
  "content": "Hola!"
}
```

## Desarrollo

```bash
npm run dev     # Modo desarrollo
npm run build   # Compilar
npm run test   # Tests
```
