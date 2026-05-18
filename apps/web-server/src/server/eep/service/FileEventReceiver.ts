import { FileNames } from './FileNames';
import { ServerStatisticsService } from './ServerStatisticsService';
import * as fs from 'fs';
import * as path from 'path';
import { performance } from 'perf_hooks';

export class FileEventReceiver {
  private watcher: fs.FSWatcher | undefined;

  constructor(
    private readonly dir: string,
    private readonly onEventLine: (line: string) => void,
  ) {}

  attach(): void {
    const jsonFile = path.resolve(this.dir, FileNames.eventsFromCe);
    const jsonReadyFile = path.resolve(this.dir, FileNames.eventsFromCePending);

    performance.mark('eep:start-wait-for-json');
    if (fs.existsSync(jsonReadyFile)) {
      this.readJsonFile(jsonFile, jsonReadyFile);
    }

    this.watcher = fs.watch(this.dir, (_eventType: string, filename: string | null) => {
      if (filename === FileNames.eventsFromCePending && fs.existsSync(jsonReadyFile)) {
        this.readJsonFile(jsonFile, jsonReadyFile);
      }
    });
    this.watcher.unref?.();
  }

  detach(): void {
    this.watcher?.close();
    this.watcher = undefined;
  }

  private readJsonFile(jsonFile: string, jsonReadyFile: string) {
    try {
      const data: string = fs.readFileSync(jsonFile, { encoding: 'latin1' });
      const eventLines: string[] = data.split('\n');
      for (const line of eventLines) {
        if (line.length > 0) {
          this.onEventLine(line);
        }
      }

      performance.mark('eep:stop-wait-for-json');
      performance.measure(
        ServerStatisticsService.TimeForEepJsonFile,
        'eep:start-wait-for-json',
        'eep:stop-wait-for-json',
      );

      try {
        fs.unlinkSync(jsonReadyFile);
      } catch (_err) {
        // ignored
      }
      performance.mark('eep:start-wait-for-json');
    } catch (err) {
      console.log(err);
    }
  }
}
