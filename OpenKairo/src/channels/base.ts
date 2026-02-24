import type { ChannelAdapter, IncomingMessage } from '../types.js';

export abstract class BaseChannel implements ChannelAdapter {
  abstract id: string;
  abstract name: string;
  protected messageHandler?: (message: IncomingMessage) => void;

  abstract start(): Promise<void>;
  abstract stop(): Promise<void>;
  abstract sendMessage(to: string, message: string): Promise<void>;

  onMessage(handler: (message: IncomingMessage) => void): void {
    this.messageHandler = handler;
  }

  protected emitMessage(message: IncomingMessage): void {
    if (this.messageHandler) {
      this.messageHandler(message);
    }
  }

  protected generateId(): string {
    return `${this.id}-${Date.now()}-${Math.random().toString(36).slice(2, 11)}`;
  }
}
