import type { Message, Tool, ToolResult, ChatOptions, LLMProvider } from '../types.js';
import { TokenManager } from './token-manager.js';
import { MemoryManager } from './memory/index.js';

export interface AgentConfig {
  name: string;
  model: string;
  provider: LLMProvider;
  tools?: Tool[];
}

export class AgentRunner {
  private config: AgentConfig;
  private tokenManager: TokenManager;
  private memoryManager: MemoryManager;
  private maxIterations = 10;
  private systemPrompt: string = '';

  constructor(config: AgentConfig, tokenManager: TokenManager, memoryManager: MemoryManager) {
    this.config = config;
    this.tokenManager = tokenManager;
    this.memoryManager = memoryManager;
  }

  async initialize(): Promise<void> {
    const [personality, context, memory] = await Promise.all([
      this.memoryManager.getPersonality(),
      this.memoryManager.getContext(),
      this.memoryManager.getMemory(),
    ]);

    const contextSection = context ? `\n\n## Contexto\n${context}` : '';
    const memorySection = memory ? `\n\n## Memoria del usuario\n${memory}` : '';

    this.systemPrompt = `${personality}${contextSection}${memorySection}`;
    console.log('Agent initialized with personality from workspace');
  }

  async *run(messages: Message[]): AsyncGenerator<string, void, unknown> {
    const systemMessages: Message[] = this.systemPrompt
      ? [{ id: 'system', role: 'system', content: this.systemPrompt, timestamp: Date.now() }]
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

  async learnFromConversation(userMessage: string, assistantMessage: string): Promise<void> {
    const patterns = [
      /me llamo (\w+)/i,
      /mi nombre es (\w+)/i,
      /prefiero (.*)/i,
      /me gusta (.*)/i,
      /no me gusta (.*)/i,
      /soy (\w+)/i,
    ];

    for (const pattern of patterns) {
      const match = userMessage.match(pattern);
      if (match) {
        const key = pattern.source.replace(/[\\^$*+?.()|[\]{}]/g, '').replace(/.*me llamo.*|.*mi nombre es.*|.*prefiero.*|.*me gusta.*|.*no me gusta.*|.*soy.*/i, 
          match[0].includes('llamo') ? 'nombre' : 
          match[0].includes('nombre') ? 'nombre' :
          match[0].prefiere ? 'prefiere' :
          match[0].includes('gusta') ? 'gusta' : 'gusta');
        
        await this.memoryManager.learnFact(key, match[1]);
        console.log(`Learned fact: ${key} = ${match[1]}`);
      }
    }
  }

  updateConfig(config: Partial<AgentConfig>): void {
    this.config = { ...this.config, ...config };
  }

  getMemoryManager(): MemoryManager {
    return this.memoryManager;
  }
}
