import { FileNames } from './FileNames';
import * as fs from 'fs';
import * as path from 'path';

export interface ServerTransportDescriptor {
  eventTransport: 'pipe';
  pipeName: string;
  sessionId: string;
}

export class ServerTransportDescriptorWriter {
  constructor(private readonly dir: string) {}

  write(descriptor: ServerTransportDescriptor): void {
    fs.writeFileSync(this.fileName(), JSON.stringify(descriptor), { encoding: 'latin1' });
  }

  remove(): void {
    try {
      fs.unlinkSync(this.fileName());
    } catch (_error) {
      // ignored
    }
  }

  private fileName(): string {
    return path.resolve(this.dir, FileNames.serverTransport);
  }
}
