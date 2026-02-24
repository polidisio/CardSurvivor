# OpenKairo

Asistente de IA autoalojado tipo OpenClaw con soporte multi-provider y gestión avanzada de tokens.

## Características

- **Multi-provider**: Anthropic, OpenAI, Google Gemini, Ollama (local)
- **Gestión avanzada de tokens**: Cache, compresión de contexto, alertas de presupuesto
- **Canales**: Telegram, Discord
- **Tools**: Shell, archivos, HTTP fetch
- **Arquitectura**: Gateway WebSocket con sesiones persistentes

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
# Iniciar el Gateway
npm run dev -- start

# Ver stats
curl http://localhost:18789/stats
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
