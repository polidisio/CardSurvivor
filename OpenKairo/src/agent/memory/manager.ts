import * as fs from 'fs/promises';
import * as path from 'path';
import { homedir } from 'os';

export interface WorkspacePaths {
  workspace: string;
  agents: string;
  memory: string;
  context: string;
  sessions: string;
}

export class MemoryManager {
  private paths: WorkspacePaths;
  private sessionHistoryDays = 30;
  private facts: Map<string, string> = new Map();
  private preferences: Map<string, string> = new Map();

  constructor(workspacePath?: string) {
    const workspace = workspacePath || path.join(homedir(), '.openkairo', 'workspace');
    this.paths = {
      workspace,
      agents: path.join(workspace, 'AGENTS.md'),
      memory: path.join(workspace, 'MEMORY.md'),
      context: path.join(workspace, 'CONTEXT.md'),
      sessions: path.join(workspace, 'sessions'),
    };
  }

  async initialize(): Promise<void> {
    await fs.mkdir(this.paths.sessions, { recursive: true });

    try {
      await fs.access(this.paths.agents);
    } catch {
      await this.copyDefaultFiles();
    }

    await this.loadMemory();
  }

  private async copyDefaultFiles(): Promise<void> {
    const defaultPath = path.join(process.cwd(), 'src', 'agent', 'memory');
    try {
      await fs.copyFile(path.join(defaultPath, 'AGENTS.md'), this.paths.agents);
      await fs.copyFile(path.join(defaultPath, 'MEMORY.md'), this.paths.memory);
      await fs.copyFile(path.join(defaultPath, 'CONTEXT.md'), this.paths.context);
    } catch {
      // Archivos por defecto ya existen o no se encontraron
    }
  }

  async loadMemory(): Promise<void> {
    try {
      const memoryContent = await fs.readFile(this.paths.memory, 'utf-8');
      this.parseMemoryFile(memoryContent);
    } catch {
      // No hay archivo de memoria aún
    }
  }

  private parseMemoryFile(content: string): void {
    const factsMatch = content.match(/## Hechos aprendidos([\s\S]*?)(?=##|$)/);
    if (factsMatch) {
      const facts = factsMatch[1].split('\n').filter(line => line.startsWith('- '));
      for (const fact of facts) {
        const [key, ...valueParts] = fact.replace('- ', '').split(': ');
        if (key && valueParts.length) {
          this.facts.set(key.trim(), valueParts.join(': ').trim());
        }
      }
    }

    const prefsMatch = content.match(/## Preferencias([\s\S]*?)(?=##|$)/);
    if (prefsMatch) {
      const prefs = prefsMatch[1].split('\n').filter(line => line.startsWith('- '));
      for (const pref of prefs) {
        const [key, ...valueParts] = pref.replace('- ', '').split(': ');
        if (key && valueParts.length) {
          this.preferences.set(key.trim(), valueParts.join(': ').trim());
        }
      }
    }
  }

  async getPersonality(): Promise<string> {
    try {
      return await fs.readFile(this.paths.agents, 'utf-8');
    } catch {
      return 'Eres OpenKairo, un asistente de IA útil.';
    }
  }

  async getContext(): Promise<string> {
    try {
      return await fs.readFile(this.paths.context, 'utf-8');
    } catch {
      return '';
    }
  }

  async getMemory(): Promise<string> {
    try {
      return await fs.readFile(this.paths.memory, 'utf-8');
    } catch {
      return '';
    }
  }

  getFacts(): Map<string, string> {
    return this.facts;
  }

  getPreferences(): Map<string, string> {
    return this.preferences;
  }

  async learnFact(key: string, value: string): Promise<void> {
    this.facts.set(key, value);
    await this.saveMemory();
  }

  async setPreference(key: string, value: string): Promise<void> {
    this.preferences.set(key, value);
    await this.saveMemory();
  }

  private async saveMemory(): Promise<void> {
    const factsLines = Array.from(this.facts.entries())
      .map(([key, value]) => `- ${key}: ${value}`)
      .join('\n');

    const prefsLines = Array.from(this.preferences.entries())
      .map(([key, value]) => `- ${key}: ${value}`)
      .join('\n');

    const content = `# Memoria - Conocimiento sobre el usuario

## Hechos aprendidos
${factsLines || '<!-- Aquí se guardan automáticamente hechos importantes sobre el usuario -->'}

## Preferencias
${prefsLines || '<!-- Preferencias y estilos de comunicación -->'}

## Intereses
<!-- Temas de interés del usuario -->

## Nota importante
Esta memoria se actualiza automáticamente cuando el agente aprende información nueva sobre el usuario.
`;

    await fs.writeFile(this.paths.memory, content, 'utf-8');
  }

  getSessionsPath(): string {
    return this.paths.sessions;
  }

  getSessionHistoryDays(): number {
    return this.sessionHistoryDays;
  }
}
