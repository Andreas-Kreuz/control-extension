import * as net from 'node:net';

export class PipeEventReceiver {
  private server: net.Server | undefined;
  private buffers = new Map<net.Socket, string>();

  constructor(
    private readonly pipeName: string,
    private readonly onEventLine: (line: string) => void,
    private readonly debug = false,
  ) {}

  start(): void {
    this.stop();
    this.server = net.createServer((socket) => this.attachSocket(socket));
    this.server.on('error', (error) => {
      console.error('PipeEventReceiver error: ' + error.message);
    });
    this.server.listen(this.pipeName, () => {
      if (this.debug) console.log('PipeEventReceiver listening on ' + this.pipeName);
    });
  }

  stop(): void {
    for (const socket of this.buffers.keys()) {
      socket.destroy();
    }
    this.buffers.clear();
    this.server?.close();
    this.server = undefined;
  }

  private attachSocket(socket: net.Socket): void {
    socket.setEncoding('latin1');
    this.buffers.set(socket, '');

    socket.on('data', (chunk: string) => this.onData(socket, chunk));
    socket.on('close', () => this.flushAndForget(socket));
    socket.on('error', (error) => {
      if (this.debug) console.error('PipeEventReceiver socket error: ' + error.message);
      this.flushAndForget(socket);
    });
  }

  private onData(socket: net.Socket, chunk: string): void {
    const text = (this.buffers.get(socket) ?? '') + chunk;
    const lines = text.split(/\r?\n/);
    this.buffers.set(socket, lines.pop() ?? '');
    for (const line of lines) {
      if (line.length > 0) {
        this.onEventLine(line);
      }
    }
  }

  private flushAndForget(socket: net.Socket): void {
    const remaining = this.buffers.get(socket);
    if (remaining && remaining.length > 0) {
      this.onEventLine(remaining);
    }
    this.buffers.delete(socket);
  }
}
