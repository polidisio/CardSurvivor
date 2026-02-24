import Fastify from 'fastify';
import websocket from '@fastify/websocket';
import { WebSocketServer, WebSocket } from 'ws';
import { configStore } from '../config/store.js';
import type { Config, IncomingMessage, Message, Session } from '../types.js';
import { AgentRunner } from '../agent/runner.js';
import { TokenManager } from '../agent/token-manager.js';
import { builtinTools, executeTool } from '../agent/tools.js';
import {
  AnthropicProvider,
  OpenAIProvider,
  OllamaProvider,
  GoogleProvider,
  providerRegistry,
} from '../providers/index.js';
import { DiscordChannel, TelegramChannel } from '../channels/index.js';

interface WSClient {
  id: string;
  socket: WebSocket;
  sessionId?: string;
}

export class Gateway {
  private fastify = Fastify({ logger: true });
  private wss?: WebSocketServer;
  private clients = new Map<string, WSClient>();
  private sessions = new Map<string, Session>();
  private channels: Array<DiscordChannel | TelegramChannel> = [];
  private agent?: AgentRunner;
  private tokenManager?: TokenManager;
  private config: Config;

  constructor() {
    this.config = configStore.getAll();
  }

  async start(): Promise<void> {
    this.setupProviders();
    this.setupTokenManager();
    await this.setupChannels();
    this.setupAgent();
    await this.startServer();
    this.setupWebSocket();
    console.log(`Gateway started on port ${this.config.gateway.port}`);
  }

  private setupProviders(): void {
    if (this.config.providers.anthropic?.apiKey) {
      providerRegistry.register(
        new AnthropicProvider(this.config.providers.anthropic.apiKey)
      );
    }

    if (this.config.providers.openai?.apiKey) {
      providerRegistry.register(
        new OpenAIProvider(this.config.providers.openai.apiKey)
      );
    }

    if (this.config.providers.ollama?.baseUrl) {
      providerRegistry.register(
        new OllamaProvider('', this.config.providers.ollama.baseUrl)
      );
    }

    if (this.config.providers.google?.apiKey) {
      providerRegistry.register(
        new GoogleProvider(this.config.providers.google.apiKey)
      );
    }
  }

  private setupTokenManager(): void {
    this.tokenManager = new TokenManager(this.config.tokenManagement);
  }

  private setupAgent(): void {
    const provider = providerRegistry.get(this.config.defaultProvider);
    if (!provider) {
      throw new Error(`Provider ${this.config.defaultProvider} not registered`);
    }

    this.agent = new AgentRunner(
      {
        name: 'default',
        model: this.config.providers.anthropic?.model || 'claude-sonnet-4-20250514',
        provider,
        systemPrompt: `Eres OpenKairo, un asistente de IA personal. 
Respondes de manera útil y amigable.
Tienes acceso a herramientas para ejecutar comandos, leer/escribir archivos, y más.`,
        tools: builtinTools,
      },
      this.tokenManager!
    );
  }

  private async setupChannels(): Promise<void> {
    if (this.config.channels.discord) {
      const discord = new DiscordChannel(
        this.config.channels.discord as { token: string }
      );
      discord.onMessage(this.handleIncomingMessage.bind(this));
      await discord.start();
      this.channels.push(discord);
    }

    if (this.config.channels.telegram) {
      const telegram = new TelegramChannel(
        this.config.channels.telegram as { token: string }
      );
      telegram.onMessage(this.handleIncomingMessage.bind(this));
      await telegram.start();
      this.channels.push(telegram);
    }
  }

  private async startServer(): Promise<void> {
    await this.fastify.register(websocket);

    this.fastify.get('/health', async () => {
      return { status: 'ok', channels: this.channels.map(c => c.id) };
    });

    this.fastify.get('/stats', async () => {
      return {
        sessions: this.sessions.size,
        clients: this.clients.size,
        usage: this.tokenManager?.getUsageStats('anthropic') || [],
      };
    });

    this.fastify.register(async (fastify) => {
      fastify.get('/ws', { websocket: true }, (socket, req) => {
        const clientId = `ws-${Date.now()}`;
        const client: WSClient = { id: clientId, socket };
        this.clients.set(clientId, client);

        socket.on('close', () => {
          this.clients.delete(clientId);
        });

        socket.on('message', (data) => {
          try {
            const message = JSON.parse(data.toString());
            this.handleWSMessage(client, message);
          } catch (e) {
            socket.send(JSON.stringify({ error: 'Invalid message format' }));
          }
        });

        socket.send(JSON.stringify({ type: 'connected', clientId }));
      });
    });

    await this.fastify.listen({
      port: this.config.gateway.port,
      host: this.config.gateway.host,
    });
  }

  private setupWebSocket(): void {
    const wsPort = this.config.gateway.port + 1;
    this.wss = new WebSocketServer({ port: wsPort });

    this.wss.on('connection', (socket) => {
      const clientId = `ws-${Date.now()}`;
      const client: WSClient = { id: clientId, socket };
      this.clients.set(clientId, client);

      socket.on('close', () => {
        this.clients.delete(clientId);
      });

      socket.on('message', (data) => {
        try {
          const message = JSON.parse(data.toString());
          this.handleWSMessage(client, message);
        } catch (e) {
          socket.send(JSON.stringify({ error: 'Invalid message format' }));
        }
      });

      socket.send(JSON.stringify({ type: 'connected', clientId }));
    });

    console.log(`WebSocket server on port ${wsPort}`);
  }

  private handleWSMessage(client: WSClient, message: unknown): void {
    const msg = message as { type: string; [key: string]: unknown };

    switch (msg.type) {
      case 'chat':
        this.handleChat(client, msg.content as string);
        break;
      case 'create-session':
        client.sessionId = this.createSession(msg.channelId as string, msg.userId as string);
        client.socket.send(JSON.stringify({ type: 'session-created', sessionId: client.sessionId }));
        break;
      default:
        client.socket.send(JSON.stringify({ error: `Unknown message type: ${msg.type}` }));
    }
  }

  private createSession(channelId: string, userId: string): string {
    const sessionId = `${channelId}:${userId}`;
    const session: Session = {
      id: sessionId,
      channelId,
      userId,
      messages: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };
    this.sessions.set(sessionId, session);
    return sessionId;
  }

  private async handleChat(client: WSClient, content: string): Promise<void> {
    if (!client.sessionId) {
      client.socket.send(JSON.stringify({ error: 'No session created' }));
      return;
    }

    const session = this.sessions.get(client.sessionId);
    if (!session) {
      client.socket.send(JSON.stringify({ error: 'Session not found' }));
      return;
    }

    const userMessage: Message = {
      id: `user-${Date.now()}`,
      role: 'user',
      content,
      timestamp: Date.now(),
    };
    session.messages.push(userMessage);
    session.updatedAt = Date.now();

    if (!this.agent) {
      client.socket.send(JSON.stringify({ error: 'Agent not initialized' }));
      return;
    }

    const stream = this.agent.run(session.messages);

    let fullResponse = '';
    for await (const chunk of stream) {
      fullResponse += chunk;
      client.socket.send(JSON.stringify({
        type: 'chunk',
        content: chunk,
        sessionId: session.id,
      }));
    }

    const assistantMessage: Message = {
      id: `assistant-${Date.now()}`,
      role: 'assistant',
      content: fullResponse,
      timestamp: Date.now(),
    };
    session.messages.push(assistantMessage);

    client.socket.send(JSON.stringify({
      type: 'done',
      sessionId: session.id,
    }));
  }

  private async handleIncomingMessage(message: IncomingMessage): Promise<void> {
    const sessionId = `${message.channelId}:${message.from}`;
    let session = this.sessions.get(sessionId);

    if (!session) {
      session = this.createSession(message.channelId, message.from);
    }

    const userMessage: Message = {
      id: message.id,
      role: 'user',
      content: message.content,
      timestamp: message.timestamp,
    };
    session.messages.push(userMessage);

    if (!this.agent) return;

    const stream = this.agent.run(session.messages);
    let response = '';

    for await (const chunk of stream) {
      response += chunk;
    }

    const channel = this.channels.find(c => c.id === message.channelId);
    if (channel) {
      await channel.sendMessage(message.from, response);
    }

    const assistantMessage: Message = {
      id: `assistant-${Date.now()}`,
      role: 'assistant',
      content: response,
      timestamp: Date.now(),
    };
    session.messages.push(assistantMessage);
  }

  async stop(): Promise<void> {
    for (const channel of this.channels) {
      await channel.stop();
    }

    if (this.wss) {
      this.wss.close();
    }

    await this.fastify.close();
    console.log('Gateway stopped');
  }
}
