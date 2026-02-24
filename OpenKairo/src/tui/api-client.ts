import axios, { AxiosInstance } from 'axios';
import WebSocket from 'ws';

export interface GatewayStats {
  sessions: number;
  clients: number;
  usage: UsageStats[];
  memory: {
    facts: number;
    preferences: number;
  };
}

export interface UsageStats {
  provider: string;
  inputTokens: number;
  outputTokens: number;
  totalCost: number;
  timestamp: number;
}

export interface MemoryData {
  facts: Record<string, string>;
  preferences: Record<string, string>;
}

export interface ChatMessage {
  type: 'chunk' | 'done' | 'error';
  content?: string;
  sessionId?: string;
  error?: string;
}

export class GatewayClient {
  private http: AxiosInstance;
  private ws?: WebSocket;
  private sessionId?: string;
  private messageHandler?: (msg: ChatMessage) => void;
  private connectedHandler?: () => void;

  constructor(
    private httpPort = 18789,
    private wsPort = 18790,
    private host = '127.0.0.1'
  ) {
    this.http = axios.create({
      baseURL: `http://${host}:${httpPort}`,
      timeout: 30000,
    });
  }

  async connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.ws = new WebSocket(`ws://${this.host}:${this.wsPort}`);

      this.ws.on('open', () => {
        console.log('Connected to Gateway');
        if (this.connectedHandler) this.connectedHandler();
        resolve();
      });

      this.ws.on('message', (data) => {
        try {
          const msg = JSON.parse(data.toString()) as ChatMessage;
          if (msg.type === 'connected') {
            this.createSession();
          } else if (this.messageHandler) {
            this.messageHandler(msg);
          }
        } catch (e) {
          console.error('Failed to parse message:', e);
        }
      });

      this.ws.on('error', (err) => {
        reject(err);
      });

      this.ws.on('close', () => {
        console.log('Disconnected from Gateway');
      });
    });
  }

  private send(data: unknown): void {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(data));
    }
  }

  private createSession(): void {
    this.send({
      type: 'create-session',
      channelId: 'tui',
      userId: 'local-user',
    });
  }

  onMessage(handler: (msg: ChatMessage) => void): void {
    this.messageHandler = handler;
  }

  onConnected(handler: () => void): void {
    this.connectedHandler = handler;
  }

  setSessionId(sessionId: string): void {
    this.sessionId = sessionId;
  }

  sendMessage(content: string): void {
    this.send({
      type: 'chat',
      content,
    });
  }

  disconnect(): void {
    if (this.ws) {
      this.ws.close();
      this.ws = undefined;
    }
  }

  async getHealth(): Promise<{ status: string; channels: string[] }> {
    const res = await this.http.get('/health');
    return res.data;
  }

  async getStats(): Promise<GatewayStats> {
    const res = await this.http.get('/stats');
    return res.data;
  }

  async getMemory(): Promise<MemoryData> {
    const res = await this.http.get('/memory');
    return res.data;
  }

  isConnected(): boolean {
    return this.ws !== undefined && this.ws.readyState === WebSocket.OPEN;
  }
}

export const createGatewayClient = (
  httpPort = 18789,
  wsPort = 18790,
  host = '127.0.0.1'
): GatewayClient => {
  return new GatewayClient(httpPort, wsPort, host);
};
