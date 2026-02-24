import { BaseProvider } from './base.js';
import type { Message, ChatOptions } from '../types.js';

export class OllamaProvider extends BaseProvider {
  name = 'ollama';

  protected getDefaultBaseUrl(): string {
    return 'http://localhost:11434';
  }

  async *chat(messages: Message[], options: ChatOptions): AsyncIterable<string> {
    const body = {
      model: options.model || 'llama3',
      messages: messages.map(m => ({
        role: m.role,
        content: m.content,
      })),
      stream: true,
      options: {
        temperature: options.temperature || 0.7,
        num_predict: options.maxTokens || 4096,
      },
    };

    const response = await fetch(`${this.baseUrl}/api/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Ollama API error (${response.status}): ${error}`);
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
          if (!line.trim()) continue;

          try {
            const parsed = JSON.parse(line);
            if (parsed.message?.content) {
              yield parsed.message.content;
            }
            if (parsed.done) return;
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
    return Math.ceil(text.length / 4);
  }
}
