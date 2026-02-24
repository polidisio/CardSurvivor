import Conf from 'conf';
import { ConfigSchema, type Config } from './schema.js';
import { z } from 'zod';

const schema = {
  config: ConfigSchema,
};

export class ConfigStore {
  private store: Conf<{ config: Config }>;

  constructor(projectName = 'openkairo') {
    this.store = new Conf<{ config: Config }>({
      projectName,
      defaults: {
        config: {
          gateway: {
            port: 18789,
            host: '127.0.0.1',
          },
          defaultProvider: 'anthropic',
          channels: {},
          tokenManagement: {
            enabled: true,
            cacheEnabled: true,
            contextCompression: true,
            maxContextTokens: 100000,
            alertThreshold: 0.8,
            budgets: {},
          },
        },
      },
    });
  }

  get<K extends keyof Config>(key: K): Config[K] {
    return this.store.get(`config.${key}`) as Config[K];
  }

  set<K extends keyof Config>(key: K, value: Config[K]): void {
    this.store.set(`config.${key}`, value);
  }

  getAll(): Config {
    return this.store.get('config') as Config;
  }

  update(partial: Partial<Config>): void {
    const current = this.getAll();
    const merged = this.mergeDeep(current, partial);
    const parsed = ConfigSchema.parse(merged);
    this.store.set('config', parsed);
  }

  private mergeDeep(target: unknown, source: unknown): unknown {
    if (typeof target !== 'object' || typeof source !== 'object') return source;
    const result: Record<string, unknown> = {};
    for (const key of new Set([...Object.keys(target as object), ...Object.keys(source as object)])) {
      const t = (target as Record<string, unknown>)[key];
      const s = (source as Record<string, unknown>)[key];
      if (this.isObject(t) && this.isObject(s)) {
        result[key] = this.mergeDeep(t, s);
      } else if (s !== undefined) {
        result[key] = s;
      } else {
        result[key] = t;
      }
    }
    return result;
  }

  private isObject(val: unknown): val is Record<string, unknown> {
    return typeof val === 'object' && val !== null && !Array.isArray(val);
  }

  validate(): { success: boolean; errors?: z.ZodError } {
    try {
      ConfigSchema.parse(this.getAll());
      return { success: true };
    } catch (e) {
      if (e instanceof z.ZodError) {
        return { success: false, errors: e };
      }
      throw e;
    }
  }
}

export const configStore = new ConfigStore();
