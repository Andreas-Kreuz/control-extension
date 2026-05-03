import { CacheService } from '../server-data/CacheService';
import { FileNames } from './FileNames';
import { LogFileMonitor } from './LogFileMonitor';
import { ServerStatisticsService } from './ServerStatisticsService';
import * as fs from 'fs';
import * as path from 'path';
import { performance } from 'perf_hooks';
import { Tail } from 'tail';

/**
 * This service is responsible for the communication with EEP.
 */
export default class EepService implements CacheService {
  private static filesToDeleteOnExit = new Set<string>();
  private static processCleanupRegistered = false;
  private static signalCleanupInProgress = false;

  private dir: string | null = null;
  private jsonFileWatcher?: fs.FSWatcher;
  private readonly logFileMonitor: LogFileMonitor;
  private eventTail?: Tail;
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
    this.attachLogFromCeFile();
    this.createServerIsRunningFile();
    this.deleteFileOnExit(FileNames.serverEventCounter);
  }

  private disconnectFromFiles(): void {
    if (this.dir) {
      EepService.deleteFileIfExists(path.resolve(this.dir, FileNames.serverIsRunning));
    }

    this.logFileMonitor.detach();
    if (this.eventTail) {
      this.eventTail.unwatch();
    }
    if (this.jsonFileWatcher) {
      this.jsonFileWatcher.close();
    }
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
    const dir = this.requireDir();
    const jsonFile = path.resolve(dir, FileNames.eventsFromCe);
    const jsonReadyFile = path.resolve(dir, FileNames.eventsFromCePending);

    // First start: only read a payload that EEP explicitly marked as pending.
    if (!this.jsonFileWatcher) {
      performance.mark('eep:start-wait-for-json');
      if (fs.existsSync(jsonReadyFile)) {
        this.readJsonFile(jsonFile, jsonReadyFile);
      }
    }

    // Watch in the directory, if the file is recreated
    this.jsonFileWatcher = fs.watch(dir, (_eventType: string, filename: string | null) => {
      // If events-from-ce.pending exists: read the payload and remove the marker.
      if (filename === FileNames.eventsFromCePending && fs.existsSync(jsonReadyFile)) {
        // console.log('Reading: ', jsonFile);
        this.readJsonFile(jsonFile, jsonReadyFile);
      }
    });
  }

  private readJsonFile(jsonFile: string, jsonReadyFile: string) {
    try {
      // EEP has written the JsonFile for us, so let's read it.
      const data: string = fs.readFileSync(jsonFile, { encoding: 'latin1' });
      const eventLines: string[] = data.split('\n');
      for (const line of eventLines) {
        if (line.length > 0) {
          this.eventLineAppeared(line);
        }
      }

      performance.mark('eep:stop-wait-for-json');
      performance.measure(
        ServerStatisticsService.TimeForEepJsonFile,
        'eep:start-wait-for-json',
        'eep:stop-wait-for-json',
      );

      // Delete events-from-ce.pending, so EEP knows the payload was consumed.
      EepService.deleteFileIfExists(jsonReadyFile);
      performance.mark('eep:start-wait-for-json');
    } catch (err) {
      console.log(err);
    }
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
