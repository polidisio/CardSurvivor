import blessed from 'blessed';
import { GatewayClient, createGatewayClient } from './api-client.js';
import { ChatScreen } from './chat.js';
import { AdminScreen } from './admin.js';
import { HistoryScreen } from './history.js';
import { SettingsScreen } from './settings.js';

type ScreenName = 'chat' | 'admin' | 'history' | 'settings';

export class TUI {
  private screen: blessed.Widgets.Screen;
  private client: GatewayClient;
  private currentScreen: ScreenName = 'chat';
  private screens = new Map<ScreenName, blessed.Widgets.BoxElement>();
  private chatScreen!: ChatScreen;
  private adminScreen!: AdminScreen;
  private historyScreen!: HistoryScreen;
  private settingsScreen!: SettingsScreen;
  private statusBar!: blessed.Widgets.BoxElement;
  private menuBox!: blessed.Widgets.BoxElement;

  constructor() {
    this.screen = blessed.screen({
      smartCSR: true,
      title: 'OpenKairo TUI',
    });

    this.client = createGatewayClient();

    this.init();
  }

  private init(): void {
    this.createMenu();
    this.createStatusBar();
    this.createScreens();

    this.screen.key(['q', 'C-c'], () => {
      this.exit();
    });

    this.screen.key(['1'], () => this.showScreen('chat'));
    this.screen.key(['2'], () => this.showScreen('history'));
    this.screen.key(['3'], () => this.showScreen('admin'));
    this.screen.key(['4'], () => this.showScreen('settings'));

    this.screen.key(['r'], () => {
      if (this.adminScreen) {
        this.adminScreen.refresh();
      }
    });

    this.screen.key(['h', '?'], () => {
      this.showHelp();
    });
  }

  private createMenu(): void {
    this.menuBox = blessed.box({
      top: 0,
      left: 0,
      width: '20%',
      height: 'shrink',
      border: { type: 'line', fg: 'white' },
      content: `
{bold}📁 Menú{/bold}

{green}[1]{/green} Chat
{green}[2]{/green} Historial
{green}[3]{/green} Admin
{green}[4]{/green} Settings

---
{gray}[r] Actualizar{/gray}
{gray}[h] Ayuda{/gray}
{gray}[q] Salir{/gray}
`,
    });

    this.screen.append(this.menuBox);
  }

  private createStatusBar(): void {
    this.statusBar = blessed.box({
      bottom: 0,
      left: 0,
      width: '100%',
      height: 3,
      style: {
        bg: 'blue',
        fg: 'white',
      },
      content: ' Conectando al Gateway... ',
    });

    this.screen.append(this.statusBar);
  }

  private createScreens(): void {
    this.chatScreen = new ChatScreen(this.screen);
    this.adminScreen = new AdminScreen(this.screen);
    this.historyScreen = new HistoryScreen(this.screen);
    this.settingsScreen = new SettingsScreen(this.screen);

    this.screens.set('chat', this.chatScreen.getInput().parent || this.chatScreen as unknown as blessed.Widgets.BoxElement);
  }

  private async showScreen(name: ScreenName): Promise<void> {
    for (const [, screen] of this.screens) {
      this.screen.remove(screen);
    }

    this.currentScreen = name;

    switch (name) {
      case 'chat':
        const chatBox = this.chatScreen['box'];
        this.chatScreen.focus();
        break;
      case 'admin':
        await this.adminScreen.refresh();
        this.adminScreen.startAutoRefresh();
        break;
      case 'history':
        await this.historyScreen.loadSessions();
        this.historyScreen.focus();
        break;
      case 'settings':
        this.settingsScreen.focus();
        break;
    }

    this.screen.render();
  }

  async start(): Promise<void> {
    try {
      await this.client.connect();
      this.updateStatus('✅ Conectado al Gateway');
      
      this.chatScreen.setClient(this.client);
      this.adminScreen.setClient(this.client);
      this.settingsScreen.setClient(this.client);

      this.client.onConnected(() => {
        this.updateStatus('✅ Conectado al Gateway');
      });

      await this.showScreen('chat');
      this.screen.render();
    } catch (e) {
      this.updateStatus(`❌ Error: ${e}`);
      this.screen.render();
    }
  }

  private updateStatus(text: string): void {
    this.statusBar.setContent(text);
    this.screen.render();
  }

  private showHelp(): void {
    const helpBox = blessed.box({
      top: 'center',
      left: 'center',
      width: 60,
      height: 'shrink',
      border: { type: 'line', fg: 'white' },
      content: `
{bold}Ayuda - OpenKairo TUI{/bold}

{green}Navegación:{/green}
  [1] Chat         - Chatear con el agente
  [2] Historial    - Ver conversaciones pasadas
  [3] Admin        - Stats y memoria
  [4] Settings     - Cambiar provider/modelo

{green}General:{/green}
  [r] Actualizar   - Refresh en Admin
  [h/?] Ayuda      - Mostrar esta ayuda
  [q] Salir        - Cerrar TUI

{bold}Presiona cualquier tecla para cerrar{/bold}
`,
    });

    this.screen.append(helpBox);
    this.screen.render();

    const closeHelp = () => {
      this.screen.remove(helpBox);
      this.screen.render();
      this.screen.off('keypress', closeHelp);
    };

    this.screen.on('keypress', closeHelp);
  }

  exit(): void {
    this.client.disconnect();
    if (this.adminScreen) {
      this.adminScreen.stopAutoRefresh();
    }
    process.exit(0);
  }
}

export const startTUI = (): void => {
  const tui = new TUI();
  tui.start();
};
