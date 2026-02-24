import blessed from 'blessed';
import { GatewayClient, ChatMessage } from './api-client.js';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

export class ChatScreen {
  private box: blessed.Widgets.BoxElement;
  private messages: Message[] = [];
  private input: blessed.Widgets.TextboxElement;
  private client?: GatewayClient;
  private isReceiving = false;
  private currentResponse = '';
  private onExit?: () => void;

  constructor(screen: blessed.Widgets.Screen) {
    this.box = blessed.box({
      top: 0,
      left: 0,
      width: '100%-4',
      height: '100%-4',
      label: ' 💬 Chat ',
      border: { type: 'line', fg: 'green' },
      style: {
        border: { fg: 'green' },
      },
    });

    this.input = blessed.textbox({
      bottom: 0,
      left: 0,
      width: '100%',
      height: 3,
      label: ' Mensaje ',
      border: { type: 'line', fg: 'blue' },
      style: {
        border: { fg: 'blue' },
      },
      inputOnFocus: true,
    });

    this.input.key('enter', () => {
      const content = this.input.getValue().trim();
      if (content && !this.isReceiving) {
        this.sendMessage(content);
        this.input.clearValue();
      }
    });

    screen.append(this.box);
    screen.append(this.input);
  }

  setClient(client: GatewayClient): void {
    this.client = client;
    client.onMessage((msg: ChatMessage) => {
      if (msg.type === 'chunk' && msg.content) {
        this.currentResponse += msg.content;
        this.updateResponse(this.currentResponse);
      } else if (msg.type === 'done') {
        this.isReceiving = false;
        if (this.currentResponse) {
          this.addMessage({
            id: `assistant-${Date.now()}`,
            role: 'assistant',
            content: this.currentResponse,
            timestamp: Date.now(),
          });
        }
        this.currentResponse = '';
        this.input.focus();
      } else if (msg.type === 'error') {
        this.isReceiving = false;
        this.addMessage({
          id: `error-${Date.now()}`,
          role: 'assistant',
          content: `Error: ${msg.error}`,
          timestamp: Date.now(),
        });
      }
    });
  }

  private sendMessage(content: string): void {
    if (!this.client || !this.client.isConnected()) {
      this.addMessage({
        id: `error-${Date.now()}`,
        role: 'assistant',
        content: 'No conectado al Gateway. Ejecuta "openkairo start" primero.',
        timestamp: Date.now(),
      });
      return;
    }

    this.addMessage({
      id: `user-${Date.now()}`,
      role: 'user',
      content,
      timestamp: Date.now(),
    });

    this.isReceiving = true;
    this.currentResponse = '';
    this.client.sendMessage(content);
    this.input.focus();
  }

  private addMessage(message: Message): void {
    this.messages.push(message);
    this.renderMessages();
  }

  private updateResponse(content: string): void {
    const lastMsg = this.messages[this.messages.length - 1];
    if (lastMsg && lastMsg.role === 'assistant' && this.isReceiving) {
      lastMsg.content = content;
    } else {
      this.messages.push({
        id: `assistant-${Date.now()}`,
        role: 'assistant',
        content,
        timestamp: Date.now(),
      });
    }
    this.renderMessages();
  }

  private renderMessages(): void {
    const display = this.messages.slice(-50).map((msg) => {
      const prefix = msg.role === 'user' ? '👤 Tú' : '🤖 OpenKairo';
      const content = msg.content.length > 200 
        ? msg.content.slice(0, 200) + '...' 
        : msg.content;
      return `{bold}${prefix}:{/bold} ${content}`;
    }).join('\n\n');

    this.box.setContent(display || 'Escribe un mensaje para comenzar...');
    this.box.screen.render();
  }

  clear(): void {
    this.messages = [];
    this.box.setContent('Escribe un mensaje para comenzar...');
    this.box.screen.render();
  }

  focus(): void {
    this.input.focus();
  }

  getInput(): blessed.Widgets.TextboxElement {
    return this.input;
  }
}
