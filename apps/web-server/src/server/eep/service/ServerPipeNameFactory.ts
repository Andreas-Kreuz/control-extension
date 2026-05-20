import { randomUUID } from 'node:crypto';

export interface ServerPipeIdentity {
  pipeName: string;
  sessionId: string;
}

export class ServerPipeNameFactory {
  static create(): ServerPipeIdentity {
    const sessionId = randomUUID();
    return {
      pipeName: '\\\\.\\pipe\\control-extension-' + sessionId,
      sessionId,
    };
  }
}
