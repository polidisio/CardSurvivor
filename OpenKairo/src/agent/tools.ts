import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs/promises';
import * as path from 'path';
import * as https from 'https';
import type { Tool } from '../types.js';

const execAsync = promisify(exec);

export const builtinTools: Tool[] = [
  {
    name: 'execute_bash',
    description: 'Ejecuta comandos en la terminal',
    parameters: {
      type: 'object',
      properties: {
        command: { type: 'string', description: 'Comando a ejecutar' },
        cwd: { type: 'string', description: 'Directorio de trabajo' },
      },
      required: ['command'],
    },
  },
  {
    name: 'read_file',
    description: 'Lee el contenido de un archivo',
    parameters: {
      type: 'object',
      properties: {
        path: { type: 'string', description: 'Ruta del archivo' },
        encoding: { type: 'string', description: 'Codificación (utf-8 por defecto)' },
      },
      required: ['path'],
    },
  },
  {
    name: 'write_file',
    description: 'Escribe contenido en un archivo',
    parameters: {
      type: 'object',
      properties: {
        path: { type: 'string', description: 'Ruta del archivo' },
        content: { type: 'string', description: 'Contenido a escribir' },
      },
      required: ['path', 'content'],
    },
  },
  {
    name: 'list_directory',
    description: 'Lista archivos en un directorio',
    parameters: {
      type: 'object',
      properties: {
        path: { type: 'string', description: 'Ruta del directorio' },
      },
      required: ['path'],
    },
  },
  {
    name: 'fetch_url',
    description: 'Obtiene el contenido de una URL',
    parameters: {
      type: 'object',
      properties: {
        url: { type: 'string', description: 'URL a obtener' },
      },
      required: ['url'],
    },
  },
];

export async function executeTool(
  toolName: string,
  params: Record<string, unknown>
): Promise<string> {
  switch (toolName) {
    case 'execute_bash': {
      const { command, cwd } = params as { command: string; cwd?: string };
      try {
        const { stdout, stderr } = await execAsync(command, {
          cwd: cwd || process.cwd(),
          timeout: 30000,
        });
        return stdout || stderr || 'Comando ejecutado sin salida';
      } catch (error) {
        return `Error: ${error instanceof Error ? error.message : String(error)}`;
      }
    }

    case 'read_file': {
      const { path: filePath, encoding = 'utf-8' } = params as { path: string; encoding?: string };
      try {
        const content = await fs.readFile(filePath, encoding);
        return content.slice(0, 50000);
      } catch (error) {
        return `Error: ${error instanceof Error ? error.message : String(error)}`;
      }
    }

    case 'write_file': {
      const { path: filePath, content } = params as { path: string; content: string };
      try {
        await fs.writeFile(filePath, content);
        return `Archivo escrito: ${filePath}`;
      } catch (error) {
        return `Error: ${error instanceof Error ? error.message : String(error)}`;
      }
    }

    case 'list_directory': {
      const { path: dirPath } = params as { path: string };
      try {
        const entries = await fs.readdir(dirPath, { withFileTypes: true });
        const result = entries
          .map(e => `${e.isDirectory() ? '📁' : '📄'} ${e.name}`)
          .join('\n');
        return result || 'Directorio vacío';
      } catch (error) {
        return `Error: ${error instanceof Error ? error.message : String(error)}`;
      }
    }

    case 'fetch_url': {
      const { url } = params as { url: string };
      try {
        const content = await fetchUrl(url);
        return content.slice(0, 50000);
      } catch (error) {
        return `Error: ${error instanceof Error ? error.message : String(error)}`;
      }
    }

    default:
      return `Tool desconocido: ${toolName}`;
  }
}

function fetchUrl(url: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const req = protocol.get(url, { timeout: 10000 }, res => {
      let data = '';
      res.on('data', chunk => (data += chunk));
      res.on('end', () => resolve(data));
    });
    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

import * as http from 'http';
