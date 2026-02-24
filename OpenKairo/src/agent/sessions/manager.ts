import * as fs from 'fs/promises';
import * as path from 'path';
import type { Message, Session } from '../../types.js';

export interface SessionData {
  id: string;
  channelId: string;
  userId: string;
  messages: Message[];
  createdAt: number;
  updatedAt: number;
}

export class SessionManager {
  private sessionsDir: string;
  private memoryCache = new Map<string, Session>();
  private maxDays = 30;
  private saveDebounce = new Map<string, NodeJS.Timeout>();

  constructor(sessionsDir: string, maxDays = 30) {
    this.sessionsDir = sessionsDir;
    this.maxDays = maxDays;
  }

  async initialize(): Promise<void> {
    await fs.mkdir(this.sessionsDir, { recursive: true });
    await this.cleanupOldSessions();
    await this.loadRecentSessions();
  }

  private async cleanupOldSessions(): Promise<void> {
    const cutoff = Date.now() - this.maxDays * 24 * 60 * 60 * 1000;
    try {
      const files = await fs.readdir(this.sessionsDir);
      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        const filePath = path.join(this.sessionsDir, file);
        const content = await fs.readFile(filePath, 'utf-8');
        const session: SessionData = JSON.parse(content);
        if (session.updatedAt < cutoff) {
          await fs.unlink(filePath);
          console.log(`Deleted old session: ${file}`);
        }
      }
    } catch {
      // Directorio vacío o no existe
    }
  }

  private async loadRecentSessions(): Promise<void> {
    try {
      const files = await fs.readdir(this.sessionsDir);
      const cutoff = Date.now() - this.maxDays * 24 * 60 * 60 * 1000;
      
      for (const file of files) {
        if (!file.endsWith('.json')) continue;
        const filePath = path.join(this.sessionsDir, file);
        try {
          const content = await fs.readFile(filePath, 'utf-8');
          const session: SessionData = JSON.parse(content);
          if (session.updatedAt >= cutoff) {
            this.memoryCache.set(session.id, session);
          }
        } catch {
          // Skip invalid files
        }
      }
      console.log(`Loaded ${this.memoryCache.size} sessions from disk`);
    } catch {
      // Directorio no existe
    }
  }

  private getSessionFilePath(sessionId: string): string {
    const date = new Date().toISOString().split('T')[0];
    return path.join(this.sessionsDir, `${date}-${sessionId.replace(/[:/]/g, '-')}.json`);
  }

  getSession(sessionId: string): Session | undefined {
    return this.memoryCache.get(sessionId);
  }

  createSession(channelId: string, userId: string): Session {
    const sessionId = `${channelId}:${userId}`;
    const existing = this.memoryCache.get(sessionId);
    if (existing) {
      return existing;
    }

    const session: Session = {
      id: sessionId,
      channelId,
      userId,
      messages: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    this.memoryCache.set(sessionId, session);
    this.scheduleSave(sessionId);
    return session;
  }

  addMessage(sessionId: string, message: Message): void {
    const session = this.memoryCache.get(sessionId);
    if (!session) return;

    session.messages.push(message);
    session.updatedAt = Date.now();
    this.scheduleSave(sessionId);
  }

  getMessages(sessionId: string): Message[] {
    const session = this.memoryCache.get(sessionId);
    return session?.messages || [];
  }

  private scheduleSave(sessionId: string): void {
    const existing = this.saveDebounce.get(sessionId);
    if (existing) {
      clearTimeout(existing);
    }

    const timeout = setTimeout(() => {
      this.saveSession(sessionId);
      this.saveDebounce.delete(sessionId);
    }, 5000);

    this.saveDebounce.set(sessionId, timeout);
  }

  private async saveSession(sessionId: string): Promise<void> {
    const session = this.memoryCache.get(sessionId);
    if (!session) return;

    const filePath = this.getSessionFilePath(sessionId);
    const data: SessionData = {
      id: session.id,
      channelId: session.channelId,
      userId: session.userId,
      messages: session.messages,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    };

    await fs.writeFile(filePath, JSON.stringify(data, null, 2), 'utf-8');
  }

  async saveAll(): Promise<void> {
    for (const sessionId of this.memoryCache.keys()) {
      await this.saveSession(sessionId);
    }
  }

  getAllSessions(): Session[] {
    return Array.from(this.memoryCache.values());
  }

  getSessionCount(): number {
    return this.memoryCache.size;
  }

  searchSessions(query: string): Session[] {
    const lowerQuery = query.toLowerCase();
    return Array.from(this.memoryCache.values()).filter(session =>
      session.messages.some(m => m.content.toLowerCase().includes(lowerQuery))
    );
  }
}
