import { Command } from 'commander';
import { configStore } from '../config/store.js';
import { Gateway } from './gateway/server.js';

const program = new Command();

program
  .name('openkairo')
  .description('AI Assistant - Multi-provider con gestión avanzada de tokens')
  .version('1.0.0');

program
  .command('start')
  .description('Inicia el Gateway')
  .action(async () => {
    const gateway = new Gateway();
    await gateway.start();

    process.on('SIGINT', async () => {
      await gateway.stop();
      process.exit(0);
    });
  });

program
  .command('config')
  .description('Gestiona la configuración')
  .addCommand(
    new Command('set')
      .description('Establece un valor de configuración')
      .argument('<key>', 'Clave de configuración')
      .argument('<value>', 'Valor de configuración')
      .action((key, value) => {
        const keys = key.split('.');
        if (keys.length < 2) {
          console.error('Clave inválida. Usa formato: providers.anthropic.apiKey');
          process.exit(1);
        }
        try {
          const parsed = JSON.parse(value);
          const current = configStore.getAll();
          let target: Record<string, unknown> = current;
          for (let i = 0; i < keys.length - 1; i++) {
            target = target[keys[i]] as Record<string, unknown>;
          }
          target[keys[keys.length - 1]] = parsed;
          configStore.update(current);
          console.log(`Configuración actualizada: ${key} = ${value}`);
        } catch (e) {
          console.error('Error al parsear el valor:', e);
          process.exit(1);
        }
      })
  )
  .addCommand(
    new Command('get')
      .description('Obtiene un valor de configuración')
      .argument('<key>', 'Clave de configuración')
      .action((key) => {
        const keys = key.split('.');
        const current = configStore.getAll();
        let value: unknown = current;
        for (const k of keys) {
          value = (value as Record<string, unknown>)?.[k];
        }
        console.log(JSON.stringify(value, null, 2));
      })
  )
  .addCommand(
    new Command('show')
      .description('Muestra toda la configuración')
      .action(() => {
        console.log(JSON.stringify(configStore.getAll(), null, 2));
      })
  );

program
  .command('onboard')
  .description('Configuración inicial interactiva')
  .action(async () => {
    console.log('=== OpenKairo Onboarding ===\n');

    console.log('Configurando proveedor principal...');
    const apiKey = await question('API Key de Anthropic (o Enter para omitir): ');
    if (apiKey) {
      configStore.update({
        providers: {
          anthropic: { apiKey, model: 'claude-sonnet-4-20250514' },
        },
        defaultProvider: 'anthropic',
      });
    }

    const addOpenAI = await question('¿Agregar OpenAI? (s/n): ');
    if (addOpenAI.toLowerCase() === 's') {
      const openaiKey = await question('API Key de OpenAI: ');
      configStore.update({
        providers: {
          ...configStore.getAll().providers,
          openai: { apiKey: openaiKey, model: 'gpt-4o' },
        },
      });
    }

    const addTelegram = await question('¿Conectar Telegram? (s/n): ');
    if (addTelegram.toLowerCase() === 's') {
      const token = await question('Token del bot de Telegram: ');
      configStore.update({
        channels: {
          ...configStore.getAll().channels,
          telegram: { token },
        },
      });
    }

    const addDiscord = await question('¿Conectar Discord? (s/n): ');
    if (addDiscord.toLowerCase() === 's') {
      const token = await question('Token del bot de Discord: ');
      configStore.update({
        channels: {
          ...configStore.getAll().channels,
          discord: { token },
        },
      });
    }

    console.log('\n¡Configuración completada!');
    console.log('Ejecuta: openkairo start');
  });

function question(prompt: string): Promise<string> {
  return new Promise((resolve) => {
    process.stdout.write(prompt);
    process.stdin.once('data', (data) => {
      resolve(data.toString().trim());
    });
  });
}

program.parse();
