import { BaseProvider } from './base.js';
import type { Message, ChatOptions } from '../types.js';

export class AnthropicProvider extends BaseProvider {
  name = 'anthropic';

  protected getDefaultBaseUrl(): string {
    return 'https://api.anthropic.com';
  }

  async *chat(messages: Message[], options: ChatOptions): AsyncIterable<string> {
    const systemMessage = messages.find(m => m.role === 'system');
    const conversationMessages = messages.filter(m => m.role !== 'system');

    const body: Record<string, unknown> = {
      model: options.model || 'claude-sonnet-4-20250514',
      max_tokens: options.maxTokens || 4096,
      temperature: options.temperature || 1.0,
      messages: conversationMessages.map(m => ({
        role: m.role,
        content: m.content,
      })),
      stream: true,
    };

    if (systemMessage) {
      body.system = systemMessage.content;
    }

    if (options.tools && options.tools.length > 0) {
      body.tools = options.tools.map(t => ({
        name: t.name,
        description: t.description,
        input_schema: t.parameters,
      }));
    }

    const response = await fetch(`${this.baseUrl}/v1/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Anthropic API error (${response.status}): ${error}`);
    }

    if (!response.body) {
      throw new Error('No response body');
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed || !trimmed.startsWith('data: ')) continue;

          const data = trimmed.slice(6);
          if (data === '[DONE]') return;

          try {
            const parsed = JSON.parse(data);
            if (parsed.type === 'content_block_delta') {
              if (parsed.delta?.type === 'text_delta') {
                yield parsed.delta.text;
              }
            }
          } catch {
            // Skip invalid JSON
          }
        }
      }
    } finally {
      reader.releaseLock();
    }
  }

  async getTokenCount(text: string): Promise<number> {
    const response = await fetch(`${this.baseUrl}/v1/count_tokens`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({ model: 'claude-sonnet-4-20250514', text }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Anthropic API error (${response.status}): ${error}`);
    }

    const data = await response.json() as { count: number };
    return data.count;
  }
}
