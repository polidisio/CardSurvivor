import { Command } from 'commander';
import { homedir } from 'os';
import * as path from 'path';
import * as fs from 'fs/promises';
import { configStore } from '../config/store.js';
import { Gateway } from '../gateway/server.js';
import { MemoryManager } from '../agent/memory/index.js';

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

program
  .command('personality')
  .description('Gestiona la personalidad del agente')
  .addCommand(
    new Command('show')
      .description('Muestra la personalidad actual')
      .action(async () => {
        const mm = new MemoryManager();
        const personality = await mm.getPersonality();
        console.log(personality);
      })
  )
  .addCommand(
    new Command('edit')
      .description('Abre el archivo de personalidad en el editor')
      .action(async () => {
        const workspace = path.join(homedir(), '.openkairo', 'workspace', 'AGENTS.md');
        console.log(`Edita el archivo: ${workspace}`);
        console.log('Luego reinicia el Gateway para aplicar cambios.');
      })
  );

program
  .command('memory')
  .description('Gestiona la memoria del agente')
  .addCommand(
    new Command('show')
      .description('Muestra la memoria actual')
      .action(async () => {
        const mm = new MemoryManager();
        const [memory, context] = await Promise.all([
          mm.getMemory(),
          mm.getContext(),
        ]);
        console.log('## Memoria');
        console.log(memory);
        console.log('\n## Contexto');
        console.log(context);
      })
  )
  .addCommand(
    new Command('facts')
      .description('Muestra los hechos aprendidos')
      .action(async () => {
        const mm = new MemoryManager();
        console.log('Hechos aprendidos:');
        for (const [key, value] of mm.getFacts()) {
          console.log(`  - ${key}: ${value}`);
        }
        console.log('\nPreferencias:');
        for (const [key, value] of mm.getPreferences()) {
          console.log(`  - ${key}: ${value}`);
        }
      })
  )
  .addCommand(
    new Command('clear')
      .description('Limpia toda la memoria')
      .action(async () => {
        const mm = new MemoryManager();
        await mm.learnFact('nombre', '');
        console.log('Memoria limpiada.');
      })
  );

program
  .command('workspace')
  .description('Muestra la ubicación del workspace')
  .action(() => {
    const workspace = path.join(homedir(), '.openkairo', 'workspace');
    console.log(`Workspace: ${workspace}`);
    console.log('\nArchivos:');
    console.log('  - AGENTS.md   : Personalidad del agente');
    console.log('  - MEMORY.md   : Hechos y preferencias');
    console.log('  - CONTEXT.md  : Contexto adicional');
    console.log('  - sessions/   : Historial de conversaciones');
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
