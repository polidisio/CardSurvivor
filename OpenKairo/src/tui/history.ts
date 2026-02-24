import * as fs from 'fs/promises';
import * as path from 'path';
import { homedir } from 'os';
import blessed from 'blessed';

interface SessionMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: number;
}

interface SessionData {
  id: string;
  channelId: string;
  userId: string;
  messages: SessionMessage[];
  createdAt: number;
  updatedAt: number;
}

export class HistoryScreen {
  private box: blessed.Widgets.BoxElement;
  private list: blessed.Widgets.ListElement;
  private detailBox: blessed.Widgets.BoxElement;
  private sessions: SessionData[] = [];
  private selectedSession?: SessionData;

  constructor(screen: blessed.Widgets.Screen) {
    this.list = blessed.list({
      top: 0,
      left: 0,
      width: '30%',
      height: '100%',
      label: ' Conversaciones ',
      border: { type: 'line', fg: 'yellow' },
      style: {
        border: { fg: 'yellow' },
        selected: { bg: 'blue', fg: 'white' },
      },
      items: ['Cargando...'],
    });

    this.list.on('select', (item, index) => {
      if (this.sessions[index]) {
        this.selectedSession = this.sessions[index];
        this.showSessionDetail(this.sessions[index]);
      }
    });

    this.detailBox = blessed.box({
      top: 0,
      left: '30%+1',
      width: '70%-1',
      height: '100%',
      label: ' Detalles ',
      border: { type: 'line', fg: 'yellow' },
      style: {
        border: { fg: 'yellow' },
      },
      scrollable: true,
    });

    this.box = blessed.box({
      width: '100%-4',
      height: '100%-4',
    });

    this.box.append(this.list);
    this.box.append(this.detailBox);
    screen.append(this.box);
  }

  async loadSessions(): Promise<void> {
    const sessionsDir = path.join(homedir(), '.openkairo', 'workspace', 'sessions');
    
    try {
      await fs.access(sessionsDir);
      const files = await fs.readdir(sessionsDir);
      const jsonFiles = files.filter(f => f.endsWith('.json'));

      this.sessions = [];
      for (const file of jsonFiles) {
        try {
          const content = await fs.readFile(path.join(sessionsDir, file), 'utf-8');
          const session = JSON.parse(content) as SessionData;
          this.sessions.push(session);
        } catch {
          // Skip invalid files
        }
      }

      this.sessions.sort((a, b) => b.updatedAt - a.updatedAt);
      this.renderList();
    } catch {
      this.list.setItems(['No hay conversaciones']);
      this.box.screen.render();
    }
  }

  private renderList(): void {
    const items = this.sessions.map(s => {
      const date = new Date(s.updatedAt).toLocaleString('es-ES', {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      });
      const preview = s.messages[s.messages.length - 1]?.content?.slice(0, 30) || '...';
      return `${date} - ${preview}`;
    });

    this.list.setItems(items.length > 0 ? items : ['No hay conversaciones']);
    this.box.screen.render();
  }

  private showSessionDetail(session: SessionData): void {
    const lines = [
      `{bold}Sesión:{/bold} ${session.id}`,
      `{bold}Canal:{/bold} ${session.channelId}`,
      `{bold}Usuario:{/bold} ${session.userId}`,
      `{bold}Creada:{/bold} ${new Date(session.createdAt).toLocaleString('es-ES')}`,
      `{bold}Última actualización:{/bold} ${new Date(session.updatedAt).toLocaleString('es-ES')}`,
      '',
      '{bold}Mensajes:{/bold}',
      '',
    ];

    for (const msg of session.messages.slice(-20)) {
      const prefix = msg.role === 'user' ? '👤' : '🤖';
      const content = msg.content.length > 100 
        ? msg.content.slice(0, 100) + '...' 
        : msg.content;
      lines.push(`${prefix} ${msg.role}: ${content}`);
      lines.push('');
    }

    this.detailBox.setContent(lines.join('\n'));
    this.detailBox.setScrollPerc(100);
    this.box.screen.render();
  }

  refresh(): void {
    this.loadSessions();
  }

  focus(): void {
    this.list.focus();
  }
}
