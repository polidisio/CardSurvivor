import { BaseProvider } from './base.js';
import type { Message, ChatOptions } from '../types.js';

export class OpenAIProvider extends BaseProvider {
  name = 'openai';

  protected getDefaultBaseUrl(): string {
    return 'https://api.openai.com/v1';
  }

  async *chat(messages: Message[], options: ChatOptions): AsyncIterable<string> {
    const body: Record<string, unknown> = {
      model: options.model || 'gpt-4o',
      messages: messages.map(m => ({
        role: m.role,
        content: m.content,
        tool_calls: m.toolCalls?.map(tc => ({
          id: tc.id,
          type: 'function',
          function: {
            name: tc.name,
            arguments: JSON.stringify(tc.arguments),
          },
        })),
      })),
      stream: true,
      temperature: options.temperature || 1.0,
      max_tokens: options.maxTokens || 4096,
    };

    if (options.tools && options.tools.length > 0) {
      body.tools = options.tools.map(t => ({
        type: 'function',
        function: {
          name: t.name,
          description: t.description,
          parameters: t.parameters,
        },
      }));
    }

    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error (${response.status}): ${error}`);
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
            if (parsed.choices?.[0]?.delta?.content) {
              yield parsed.choices[0].delta.content;
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
    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [{ role: 'user', content: text }],
        max_tokens: 1,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`OpenAI API error (${response.status}): ${error}`);
    }

    const data = await response.json() as {
      usage?: { prompt_tokens: number; completion_tokens: number };
    };
    const usage = data.usage || { prompt_tokens: 0, completion_tokens: 0 };
    return usage.prompt_tokens + usage.completion_tokens;
  }
}
