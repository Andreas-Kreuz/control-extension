import { CacheService } from '../server-data/CacheService';
import { FileEventReceiver } from './FileEventReceiver';
import { FileNames } from './FileNames';
import { LogFileMonitor } from './LogFileMonitor';
import { PipeEventReceiver } from './PipeEventReceiver';
import { ServerPipeNameFactory } from './ServerPipeNameFactory';
import { ServerStatisticsService } from './ServerStatisticsService';
import { ServerTransportDescriptorWriter } from './ServerTransportDescriptorWriter';
import * as fs from 'fs';
import * as path from 'path';
import { performance } from 'perf_hooks';

/**
 * This service is responsible for the communication with EEP.
 */
export default class EepService implements CacheService {
  private static filesToDeleteOnExit = new Set<string>();
  private static processCleanupRegistered = false;
  private static signalCleanupInProgress = false;

  private dir: string | null = null;
  private fileEventReceiver: FileEventReceiver | undefined;
  private pipeEventReceiver: PipeEventReceiver | undefined;
  private descriptorWriter: ServerTransportDescriptorWriter | undefined;
  private readonly logFileMonitor: LogFileMonitor;
  private onJsonUpdate: (jsonText: string, lastUpdate: number) => void = (jsonText: string, lastUpdate: number) => {
    if (this.debug) console.log('Received: ' + jsonText.length + ' bytes of JSON ' + lastUpdate);
  };
  private logLineAppeared: (line: string) => void = (_line: string) => {};
  private eventLineAppeared: (line: string) => void = (_line: string) => {
    if (this.debug) console.log(_line);
  };
  private logWasCleared: () => void = () => {
    if (this.debug) console.log('Log was cleared');
  };

  constructor(private debug = false) {
    this.logFileMonitor = new LogFileMonitor(
      {
        onCleared: () => this.logWasCleared(),
        onLinesAppeared: (lines) => this.logLineAppeared(lines),
      },
      debug,
    );
  }

  reInit(dir: string, callback: (err: string | null, dir: string | null) => void): void {
    this.disconnectFromFiles();

    const resolvedDir = path.resolve(dir);
    this.dir = resolvedDir;
    fs.stat(resolvedDir, (err, stats) => {
      if (!err && stats.isDirectory()) {
        callback(null, resolvedDir);
        this.connectToFiles();
      } else {
        callback('No such directory: ' + resolvedDir, null);
      }
    });
  }

  disconnect(): void {
    this.disconnectFromFiles();
  }

  private connectToFiles(): void {
    this.attachEventsFromCeFile();
    this.attachEventsFromCePipe();
    this.attachLogFromCeFile();
    this.createServerIsRunningFile();
    this.deleteFileOnExit(FileNames.serverEventCounter);
    this.deleteFileOnExit(FileNames.serverTransport);
  }

  private disconnectFromFiles(): void {
    if (this.dir) {
      EepService.deleteFileIfExists(path.resolve(this.dir, FileNames.serverIsRunning));
      EepService.deleteFileIfExists(path.resolve(this.dir, FileNames.serverTransport));
    }

    this.fileEventReceiver?.detach();
    this.fileEventReceiver = undefined;
    this.pipeEventReceiver?.stop();
    this.pipeEventReceiver = undefined;
    this.descriptorWriter?.remove();
    this.descriptorWriter = undefined;
    this.logFileMonitor.detach();
    this.onJsonUpdate = (jsonText: string, lastUpdate: number) => {
      if (this.debug) console.log('Received: ' + jsonText.length + ' bytes of JSON ' + lastUpdate);
    };
    this.eventLineAppeared = (_line: string) => {
      if (this.debug) console.log(_line);
    };
    this.logLineAppeared = (_line: string) => {};
    this.logWasCleared = () => {
      if (this.debug) console.log('Log was cleared');
    };
  }

  public readCache(): unknown {
    try {
      const cacheFile = path.resolve(this.requireDir(), FileNames.serverCache);
      const fileContents = fs.readFileSync(cacheFile);
      const cachedObject = JSON.parse(fileContents.toString());
      if (this.debug) console.log('CACHE FILE READ FROM: ' + FileNames.serverCache);
      return cachedObject;
    } catch (_err) {
      console.log(_err);
      return null;
    }
  }

  public writeCache(data: unknown): void {
    const d = data as { eventCounter?: number };
    performance.mark('eep:start-write-cache-file');
    try {
      if (data) {
        const cacheFile = path.resolve(this.requireDir(), FileNames.serverCache);
        const fileContents = JSON.stringify(data);
        fs.writeFileSync(cacheFile, fileContents);

        if (d.eventCounter) {
          const counterFile = path.resolve(this.requireDir(), FileNames.serverEventCounter);
          fs.writeFileSync(counterFile, d.eventCounter.toString(10));
        }
      }
    } catch (_err) {
      console.log(_err);
    }
    performance.mark('eep:stop-write-cache-file');
    performance.measure(
      ServerStatisticsService.TimeForEepJsonFile,
      'eep:start-write-cache-file',
      'eep:stop-write-cache-file',
    );
  }

  private static deleteFileIfExists(file: string): void {
    try {
      fs.unlinkSync(file);
    } catch (_err) {
      // IGNORED - console.log(err);
    }
  }

  private attachEventsFromCeFile(): void {
    this.fileEventReceiver = new FileEventReceiver(this.requireDir(), (line) => this.eventLineAppeared(line));
    this.fileEventReceiver.attach();
  }

  private attachEventsFromCePipe(): void {
    const pipeIdentity = ServerPipeNameFactory.create();
    this.pipeEventReceiver = new PipeEventReceiver(
      pipeIdentity.pipeName,
      (line) => this.eventLineAppeared(line),
      this.debug,
    );
    this.pipeEventReceiver.start();
    this.descriptorWriter = new ServerTransportDescriptorWriter(this.requireDir());
    this.descriptorWriter.write({
      eventTransport: 'pipe',
      pipeName: pipeIdentity.pipeName,
      sessionId: pipeIdentity.sessionId,
    });
  }

  private attachLogFromCeFile(): void {
    this.logFileMonitor.attach(path.resolve(this.requireDir(), FileNames.logFromCe));
  }

  getCurrentLogLines = (): string => {
    return this.logFileMonitor.readCurrentLogLines();
  };

  public createServerIsRunningFile() {
    const watchFile = path.resolve(this.requireDir(), FileNames.serverIsRunning);
    // Create the server-is-running marker file
    fs.closeSync(fs.openSync(watchFile, 'w'));
    this.deleteFileOnExit(FileNames.serverIsRunning);
  }

  private deleteFileOnExit(fileName: string) {
    const file = path.resolve(this.requireDir(), fileName);
    EepService.filesToDeleteOnExit.add(file);
    EepService.registerProcessCleanup();
  }

  private static registerProcessCleanup(): void {
    if (EepService.processCleanupRegistered) {
      return;
    }

    EepService.processCleanupRegistered = true;
    process.on('exit', () => EepService.deleteRegisteredFiles());
    process.once('SIGINT', () => EepService.exitAfterSignal('SIGINT'));
    process.once('SIGTERM', () => EepService.exitAfterSignal('SIGTERM'));
  }

  private static exitAfterSignal(signal: NodeJS.Signals): void {
    if (EepService.signalCleanupInProgress) {
      return;
    }

    EepService.signalCleanupInProgress = true;
    EepService.deleteRegisteredFiles();
    process.kill(process.pid, signal);
  }

  private static deleteRegisteredFiles(): void {
    for (const file of EepService.filesToDeleteOnExit) {
      EepService.deleteFileIfExists(file);
    }
  }

  public setOnJsonContentChanged(updateFunction: (jsonText: string, lastUpdate: number) => void) {
    this.onJsonUpdate = updateFunction;
  }

  public setOnNewLogLine(logLineFunction: (line: string) => void) {
    this.logLineAppeared = logLineFunction;
  }

  public setOnNewEventLine(eventLineFunction: (line: string) => void) {
    this.eventLineAppeared = eventLineFunction;
  }

  public setOnLogCleared(logClearedFunction: () => void) {
    this.logWasCleared = logClearedFunction;
  }

  queueCommand = (command: string) => {
    const file = path.resolve(this.requireDir(), FileNames.commandsToCe);
    try {
      if (this.debug) console.log('Queuing: ' + command);
      fs.appendFileSync(file, command + '\n', { encoding: 'latin1' });
    } catch (error) {
      console.log(error);
    }
    // tslint:disable-next-line: semicolon
  };

  private requireDir(): string {
    if (!this.dir) {
      throw new Error('EEP directory is not initialized');
    }

    return this.dir;
  }
}
