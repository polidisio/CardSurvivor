export interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  timestamp: number;
  toolCalls?: ToolCall[];
  toolCallId?: string;
}

export interface ToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

export interface Tool {
  name: string;
  description: string;
  parameters: Record<string, unknown>;
}

export interface ToolResult {
  toolCallId: string;
  result: string;
  error?: string;
}

export interface ChatOptions {
  model: string;
  temperature?: number;
  maxTokens?: number;
  tools?: Tool[];
  systemPrompt?: string;
}

export interface LLMProvider {
  name: string;
  chat(messages: Message[], options: ChatOptions): AsyncIterable<string>;
  getTokenCount(text: string): Promise<number>;
}

export interface ChannelAdapter {
  id: string;
  name: string;
  start(): Promise<void>;
  stop(): Promise<void>;
  sendMessage(to: string, message: string): Promise<void>;
  onMessage(handler: (message: IncomingMessage) => void): void;
}

export interface IncomingMessage {
  id: string;
  channelId: string;
  from: string;
  content: string;
  timestamp: number;
  metadata?: Record<string, unknown>;
}

export interface Session {
  id: string;
  channelId: string;
  userId: string;
  messages: Message[];
  createdAt: number;
  updatedAt: number;
}

export interface Config {
  gateway: {
    port: number;
    host: string;
  };
  providers: {
    anthropic?: { apiKey: string; model?: string };
    openai?: { apiKey: string; model?: string };
    google?: { apiKey: string; model?: string };
    ollama?: { baseUrl: string; model?: string };
  };
  defaultProvider: string;
  channels: Record<string, Record<string, unknown>>;
  tokenManagement: TokenManagementConfig;
}

export interface TokenManagementConfig {
  enabled: boolean;
  cacheEnabled: boolean;
  contextCompression: boolean;
  maxContextTokens: number;
  alertThreshold: number;
  budgets: Record<string, number>;
}

export interface UsageStats {
  provider: string;
  inputTokens: number;
  outputTokens: number;
  totalCost: number;
  timestamp: number;
}

export interface CacheEntry {
  key: string;
  value: string;
  expiresAt: number;
}
