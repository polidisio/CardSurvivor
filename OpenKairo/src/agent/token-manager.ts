import type { Message, UsageStats, TokenManagementConfig, LLMProvider } from '../types.js';
import { providerRegistry } from '../providers/index.js';

export class TokenManager {
  private usage = new Map<string, UsageStats[]>();
  private cache = new Map<string, string>();
  private config: TokenManagementConfig;
  private alerts: Array<{ provider: string; message: string; timestamp: number }> = [];

  constructor(config: TokenManagementConfig) {
    this.config = config;
  }

  updateConfig(config: TokenManagementConfig): void {
    this.config = config;
  }

  async trackUsage(
    provider: string,
    inputTokens: number,
    outputTokens: number,
    cost: number
  ): Promise<void> {
    const now = Date.now();
    const stats: UsageStats = {
      provider,
      inputTokens,
      outputTokens,
      totalCost: cost,
      timestamp: now,
    };

    const existing = this.usage.get(provider) || [];
    existing.push(stats);

    const dayAgo = now - 24 * 60 * 60 * 1000;
    const filtered = existing.filter(s => s.timestamp > dayAgo);
    this.usage.set(provider, filtered);

    this.checkBudgetAlerts(provider);
  }

  private checkBudgetAlerts(provider: string): void {
    const budget = this.config.budgets[provider];
    if (!budget) return;

    const todayUsage = this.getTodayUsage(provider);
    const ratio = todayUsage / budget;

    if (ratio >= this.config.alertThreshold && ratio < 1) {
      this.alerts.push({
        provider,
        message: `Alerta: Has usado el ${Math.round(ratio * 100)}% del presupuesto de ${provider}`,
        timestamp: Date.now(),
      });
    } else if (ratio >= 1) {
      this.alerts.push({
        provider,
        message: `CRÍTICO: Has excedido el presupuesto de ${provider}`,
        timestamp: Date.now(),
      });
    }
  }

  getTodayUsage(provider: string): number {
    const stats = this.usage.get(provider) || [];
    const dayAgo = Date.now() - 24 * 60 * 60 * 1000;
    return stats
      .filter(s => s.timestamp > dayAgo)
      .reduce((sum, s) => sum + s.totalCost, 0);
  }

  getUsageStats(provider: string): UsageStats[] {
    return this.usage.get(provider) || [];
  }

  getAlerts(): Array<{ provider: string; message: string; timestamp: number }> {
    const now = Date.now();
    const oneHourAgo = now - 60 * 60 * 1000;
    return this.alerts.filter(a => a.timestamp > oneHourAgo);
  }

  clearAlerts(): void {
    this.alerts = [];
  }

  getCacheKey(messages: Message[], options: { model: string }): string {
    const content = messages.map(m => `${m.role}:${m.content}`).join('|');
    return `${options.model}:${this.hashString(content)}`;
  }

  private hashString(str: string): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(36);
  }

  getFromCache(key: string): string | null {
    if (!this.config.cacheEnabled) return null;

    const cached = this.cache.get(key);
    if (!cached) return null;

    return cached;
  }

  setCache(key: string, value: string, ttlSeconds = 3600): void {
    if (!this.config.cacheEnabled) return;

    const expiresAt = Date.now() + ttlSeconds * 1000;
    this.cache.set(key, value);

    setTimeout(() => {
      this.cache.delete(key);
    }, ttlSeconds * 1000);
  }

  clearCache(): void {
    this.cache.clear();
  }

  async compressContext(
    messages: Message[],
    provider: LLMProvider
  ): Promise<Message[]> {
    if (!this.config.contextCompression) return messages;

    const maxTokens = this.config.maxContextTokens;
    let totalTokens = 0;

    const withTokenCounts = await Promise.all(
      messages.map(async m => ({
        message: m,
        tokens: await provider.getTokenCount(m.content),
      }))
    );

    const reversed = withTokenCounts.reverse();
    const selected: typeof withTokenCounts = [];

    for (const item of reversed) {
      if (totalTokens + item.tokens > maxTokens) {
        if (item.message.role === 'user' && selected.length > 0) {
          const lastUser = selected.find(s => s.message.role === 'user');
          if (lastUser) {
            const summary = `[Resumen de ${selected.length} mensajes anteriores]`;
            selected.length = 0;
            selected.push({
              message: {
                ...lastUser.message,
                content: summary + '\n\n' + lastUser.message.content,
              },
              tokens: await provider.getTokenCount(summary),
            });
          }
        }
        break;
      }
      totalTokens += item.tokens;
      selected.push(item);
    }

    return selected.reverse().map(s => s.message);
  }

  async getProviderWithFailover(primary: string): Promise<LLMProvider | null> {
    const providers = [primary, 'openai', 'google', 'ollama'];
    const tried = new Set<string>();

    for (const name of providers) {
      if (tried.has(name)) continue;
      tried.add(name);

      const provider = providerRegistry.get(name);
      if (!provider) continue;

      const budget = this.config.budgets[name];
      if (budget && this.getTodayUsage(name) >= budget) {
        continue;
      }

      return provider;
    }

    return null;
  }
}
