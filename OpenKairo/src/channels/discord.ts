import { Client, GatewayIntentBits, TextChannel, Events } from 'discord.js';
import { BaseChannel } from './base.js';
import type { IncomingMessage } from '../types.js';

export interface DiscordConfig {
  token: string;
  allowedChannels?: string[];
  allowedUsers?: string[];
}

export class DiscordChannel extends BaseChannel {
  id = 'discord';
  name = 'Discord';
  private client?: Client;
  private config: DiscordConfig;

  constructor(config: DiscordConfig) {
    super();
    this.config = config;
  }

  async start(): Promise<void> {
    this.client = new Client({
      intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.DirectMessages,
      ],
    });

    this.client.on(Events.MessageCreate, async message => {
      if (message.author.bot) return;
      if (message.guild) {
        const mention = message.mentions.has(this.client!.user!);
        if (!mention && !message.mentions.has(this.client!.user!, { ignoreEveryone: true })) {
          return;
        }
      }

      const channelId = message.channelId;
      if (this.config.allowedChannels?.length && !this.config.allowedChannels.includes(channelId)) {
        return;
      }

      if (this.config.allowedUsers?.length && !this.config.allowedUsers.includes(message.author.id)) {
        return;
      }

      const content = message.content.replace(/<@\d+>/g, '').trim();

      const incomingMessage: IncomingMessage = {
        id: this.generateId(),
        channelId: this.id,
        from: message.author.id,
        content,
        timestamp: message.createdTimestamp,
        metadata: {
          username: message.author.username,
          channel: message.channelId,
          isDM: !message.guild,
        },
      };

      this.emitMessage(incomingMessage);
    });

    this.client.on(Events.Error, error => {
      console.error('Discord client error:', error);
    });

    await this.client.login(this.config.token);
    console.log('Discord channel started');
  }

  async stop(): Promise<void> {
    if (this.client) {
      this.client.destroy();
      this.client = undefined;
    }
    console.log('Discord channel stopped');
  }

  async sendMessage(to: string, message: string): Promise<void> {
    if (!this.client) {
      throw new Error('Discord client not initialized');
    }

    const channel = await this.client.channels.fetch(to);
    if (!channel || !(channel instanceof TextChannel)) {
      throw new Error(`Channel not found or not a text channel: ${to}`);
    }

    await channel.send(message);
  }
}
