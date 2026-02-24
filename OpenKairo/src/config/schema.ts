import { z } from 'zod';

export const TokenManagementSchema = z.object({
  enabled: z.boolean().default(true),
  cacheEnabled: z.boolean().default(true),
  contextCompression: z.boolean().default(true),
  maxContextTokens: z.number().default(100000),
  alertThreshold: z.number().default(0.8),
  budgets: z.record(z.number()).default({}),
});

export const ProviderSchema = z.object({
  apiKey: z.string().optional(),
  baseUrl: z.string().optional(),
  model: z.string().optional(),
});

export const ConfigSchema = z.object({
  gateway: z.object({
    port: z.number().default(18789),
    host: z.string().default('127.0.0.1'),
  }),
  providers: z.object({
    anthropic: ProviderSchema.optional(),
    openai: ProviderSchema.optional(),
    google: ProviderSchema.optional(),
    ollama: ProviderSchema.optional(),
  }),
  defaultProvider: z.string().default('anthropic'),
  channels: z.record(z.unknown()).default({}),
  tokenManagement: TokenManagementSchema.default({}),
});

export type Config = z.infer<typeof ConfigSchema>;
