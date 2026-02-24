import { Bot, webhookCallback } from 'grammy';
import { BaseChannel } from './base.js';
import type { IncomingMessage } from '../types.js';

export interface TelegramConfig {
  token: string;
  allowedUsers?: string[];
}

export class TelegramChannel extends BaseChannel {
  id = 'telegram';
  name = 'Telegram';
  private bot?: Bot;
  private config: TelegramConfig;

  constructor(config: TelegramConfig) {
    super();
    this.config = config;
  }

  async start(): Promise<void> {
    this.bot = new Bot(this.config.token);

    this.bot.on('message', async ctx => {
      const message = ctx.message;
      if (!message) return;

      const userId = String(message.from?.id);
      if (this.config.allowedUsers?.length && !this.config.allowedUsers.includes(userId)) {
        return;
      }

      const content = message.text || message.caption || '';

      const incomingMessage: IncomingMessage = {
        id: this.generateId(),
        channelId: this.id,
        from: userId,
        content,
        timestamp: message.date * 1000,
        metadata: {
          username: message.from?.username,
          firstName: message.from?.first_name,
          chatId: String(ctx.chat.id),
        },
      };

      this.emitMessage(incomingMessage);
    });

    await this.bot.init();
    this.bot.start();
    console.log('Telegram channel started');
  }

  async stop(): Promise<void> {
    if (this.bot) {
      await this.bot.stop();
      this.bot = undefined;
    }
    console.log('Telegram channel stopped');
  }

  async sendMessage(to: string, message: string): Promise<void> {
    if (!this.bot) {
      throw new Error('Telegram bot not initialized');
    }

    await this.bot.api.sendMessage(Number(to), message);
  }
}
