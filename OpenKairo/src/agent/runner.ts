import type { Message, Tool, ToolResult, ChatOptions, LLMProvider } from '../types.js';
import { TokenManager } from './token-manager.js';

export interface AgentConfig {
  name: string;
  model: string;
  provider: LLMProvider;
  systemPrompt?: string;
  tools?: Tool[];
}

export class AgentRunner {
  private config: AgentConfig;
  private tokenManager: TokenManager;
  private maxIterations = 10;

  constructor(config: AgentConfig, tokenManager: TokenManager) {
    this.config = config;
    this.tokenManager = tokenManager;
  }

  async *run(messages: Message[]): AsyncGenerator<string, void, unknown> {
    const systemMessages: Message[] = this.config.systemPrompt
      ? [{ id: 'system', role: 'system', content: this.config.systemPrompt, timestamp: Date.now() }]
      : [];

    let contextMessages = [...systemMessages, ...messages];
    
    if (this.tokenManager) {
      contextMessages = await this.tokenManager.compressContext(
        contextMessages,
        this.config.provider
      );
    }

    let iterations = 0;
    const toolResults: ToolResult[] = [];

    while (iterations < this.maxIterations) {
      iterations++;

      const cacheKey = this.tokenManager.getCacheKey(
        contextMessages,
        { model: this.config.model }
      );
      const cached = this.tokenManager.getFromCache(cacheKey);
      
      if (cached && iterations === 1) {
        yield cached;
        return;
      }

      const options: ChatOptions = {
        model: this.config.model,
        temperature: 0.7,
        tools: this.config.tools,
      };

      const fullMessages = [...contextMessages];
      for (const result of toolResults) {
        fullMessages.push({
          id: `tool-${result.toolCallId}`,
          role: 'tool',
          content: result.error || result.result,
          toolCallId: result.toolCallId,
          timestamp: Date.now(),
        });
      }

      let responseContent = '';
      const chatStream = this.config.provider.chat(fullMessages, options);

      for await (const chunk of chatStream) {
        responseContent += chunk;
        yield chunk;
      }

      if (!responseContent) break;

      this.tokenManager.setCache(cacheKey, responseContent);

      const assistantMessage: Message = {
        id: `assistant-${Date.now()}`,
        role: 'assistant',
        content: responseContent,
        timestamp: Date.now(),
      };

      contextMessages.push(assistantMessage);
      toolResults.length = 0;
    }
  }

  updateConfig(config: Partial<AgentConfig>): void {
    this.config = { ...this.config, ...config };
  }
}
