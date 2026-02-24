import type { LLMProvider, Message, ChatOptions } from '../types.js';

export abstract class BaseProvider implements LLMProvider {
  abstract name: string;
  protected apiKey: string;
  protected baseUrl: string;

  constructor(apiKey: string, baseUrl?: string) {
    this.apiKey = apiKey;
    this.baseUrl = baseUrl || this.getDefaultBaseUrl();
  }

  protected abstract getDefaultBaseUrl(): string;

  abstract chat(messages: Message[], options: ChatOptions): AsyncIterable<string>;

  abstract getTokenCount(text: string): Promise<number>;

  protected async request<T>(endpoint: string, body: unknown): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Provider error (${response.status}): ${error}`);
    }

    return response.json();
  }
}

export class ProviderRegistry {
  private providers = new Map<string, LLMProvider>();

  register(provider: LLMProvider): void {
    this.providers.set(provider.name, provider);
  }

  get(name: string): LLMProvider | undefined {
    return this.providers.get(name);
  }

  has(name: string): boolean {
    return this.providers.has(name);
  }

  list(): string[] {
    return Array.from(this.providers.keys());
  }

  unregister(name: string): boolean {
    return this.providers.delete(name);
  }
}

export const providerRegistry = new ProviderRegistry();
