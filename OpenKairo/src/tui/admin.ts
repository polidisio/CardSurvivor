import blessed from 'blessed';
import { GatewayClient, GatewayStats, MemoryData } from './api-client.js';

export class AdminScreen {
  private box: blessed.Widgets.BoxElement;
  private client?: GatewayClient;
  private refreshInterval?: NodeJS.Timeout;

  constructor(screen: blessed.Widgets.Screen) {
    this.box = blessed.box({
      top: 0,
      left: 0,
      width: '100%-4',
      height: '100%-4',
      label: ' 📊 Administración ',
      border: { type: 'line', fg: 'cyan' },
      style: {
        border: { fg: 'cyan' },
      },
      scrollable: true,
    });

    screen.append(this.box);
  }

  setClient(client: GatewayClient): void {
    this.client = client;
  }

  async refresh(): Promise<void> {
    if (!this.client) return;

    try {
      const [stats, memory] = await Promise.all([
        this.client.getStats(),
        this.client.getMemory(),
      ]);

      const content = this.renderStats(stats, memory);
      this.box.setContent(content);
      this.box.screen.render();
    } catch (e) {
      this.box.setContent(`Error al obtener stats: ${e}`);
      this.box.screen.render();
    }
  }

  private renderStats(stats: GatewayStats, memory: MemoryData): string {
    const facts = Object.entries(memory.facts).length;
    const prefs = Object.entries(memory.preferences).length;

    return `
{bold}📊 Estadísticas del Sistema{/bold}

{bold}Sesiones:{/bold} ${stats.sessions}
{bold}Clientes conectados:{/bold} ${stats.clients}

{bold}🧠 Memoria:{/bold}
  - Hechos aprendidos: ${facts}
  - Preferencias: ${prefs}

{bold}💰 Uso de Tokens (últimas 24h):{/bold}
${stats.usage.length === 0 ? '  Sin uso registrado' : ''}
${stats.usage.slice(-5).map(u => `  - ${u.provider}: ${u.inputTokens + u.outputTokens} tokens ($${u.totalCost.toFixed(4)})`).join('\n')}

{bold}📝 Presiona 'r' para actualizar{/bold}
`;
  }

  startAutoRefresh(intervalMs = 5000): void {
    this.refresh();
    this.refreshInterval = setInterval(() => this.refresh(), intervalMs);
  }

  stopAutoRefresh(): void {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = undefined;
    }
  }
}
