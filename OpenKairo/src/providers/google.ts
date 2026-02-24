import { BaseProvider } from './base.js';
import type { Message, ChatOptions } from '../types.js';

export class GoogleProvider extends BaseProvider {
  name = 'google';

  protected getDefaultBaseUrl(): string {
    return 'https://generativelanguage.googleapis.com/v1beta';
  }

  async *chat(messages: Message[], options: ChatOptions): AsyncIterable<string> {
    const model = options.model || 'gemini-2.0-flash';
    const contents = messages.map(m => ({
      role: m.role === 'user' ? 'user' : 'model',
      parts: [{ text: m.content }],
    }));

    const response = await fetch(
      `${this.baseUrl}/models/${model}:streamGenerateContent?alt=sse&key=${this.apiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents,
          generationConfig: {
            temperature: options.temperature || 0.7,
            maxOutputTokens: options.maxTokens || 4096,
          },
        }),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Google API error (${response.status}): ${error}`);
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
            if (parsed.candidates?.[0]?.content?.parts?.[0]?.text) {
              yield parsed.candidates[0].content.parts[0].text;
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
    return Math.ceil(text.length / 4);
  }
}
