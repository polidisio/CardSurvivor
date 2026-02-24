import blessed from 'blessed';
import { GatewayClient } from './api-client.js';

export interface SettingsData {
  provider: string;
  model: string;
}

export class SettingsScreen {
  private box: blessed.Widgets.BoxElement;
  private form: blessed.Widgets.FormElement<unknown>;
  private providerSelect: blessed.Widgets.RadioSetElement;
  private client?: GatewayClient;

  constructor(screen: blessed.Widgets.Screen) {
    this.providerSelect = blessed.radiobutton({
      top: 4,
      left: 2,
      name: 'provider',
      items: ['anthropic', 'openai', 'google', 'ollama'],
    });

    const modelInput = blessed.textbox({
      top: 10,
      left: 2,
      width: '60%',
      height: 3,
      name: 'model',
      label: ' Modelo ',
      border: { type: 'line', fg: 'white' },
      value: 'claude-sonnet-4-20250514',
    });

    const infoBox = blessed.box({
      top: 15,
      left: 2,
      width: '80%',
      height: 10,
      content: `
{bold}Proveedores disponibles:{/bold}

• {bold}anthropic{/bold}: Claude ( Sonnet, Opus, Haiku )
• {bold}openai{/bold}: GPT-4, GPT-4o, GPT-4o-mini
• {bold}google{/bold}: Gemini, Gemini Pro
• {bold}ollama{/bold}: Modelos locales (Llama3, Mistral, etc.)

{bold}Modelos recomendados:{/bold}
  - anthropic: claude-sonnet-4-20250514
  - openai: gpt-4o
  - google: gemini-2.0-flash
  - ollama: llama3
`,
    });

    const saveBtn = blessed.button({
      top: 27,
      left: 2,
      width: 15,
      height: 3,
      content: ' 💾 Guardar ',
      style: {
        bg: 'green',
        fg: 'white',
      },
    });

    saveBtn.on('press', () => {
      const provider = (this.form.get('provider') as blessed.Widgets.RadioSetElement).value;
      const model = this.form.get('model') as string;
      this.saveSettings(provider, model);
    });

    this.form = blessed.form({
      top: 0,
      left: 0,
      width: '100%-4',
      height: '100%-4',
      keys: true,
    });

    this.form.append(blessed.text({
      top: 0,
      left: 2,
      content: '{bold}⚙️ Configuración del Proveedor{/bold}',
    }));

    this.form.append(this.providerSelect);
    this.form.append(modelInput);
    this.form.append(infoBox);
    this.form.append(saveBtn);

    this.box = blessed.box({
      width: '100%-4',
      height: '100%-4',
      label: ' ⚙️ Settings ',
      border: { type: 'line', fg: 'magenta' },
      style: {
        border: { fg: 'magenta' },
      },
    });

    this.box.append(this.form);
    screen.append(this.box);
  }

  setClient(client: GatewayClient): void {
    this.client = client;
  }

  async loadSettings(): Promise<void> {
    // TODO: Load from config
    this.providerSelect.value = 'anthropic';
    this.form.screen.render();
  }

  private saveSettings(provider: string, model: string): void {
    // TODO: Send to gateway to change provider
    this.box.setContent(`
Settings guardadas:

Proveedor: ${provider}
Modelo: ${model}

Nota: Para aplicar cambios, reinicia el Gateway.
`);
    this.box.screen.render();
  }

  focus(): void {
    this.providerSelect.focus();
  }
}
