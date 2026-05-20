import { FileNames } from '../../eep/service/FileNames';
import * as fs from 'fs';
import * as path from 'path';

interface PersistentServerState {
  intersectionWizard?: unknown;
  [key: string]: unknown;
}

export default class PersistentServerStateService<TWizardState> {
  constructor(
    private exchangeDirectoryProvider: () => string,
    private defaultWizardState: () => TWizardState,
  ) {}

  readWizardState(): TWizardState {
    const state = this.readState();
    return (state.intersectionWizard as TWizardState | undefined) ?? this.defaultWizardState();
  }

  writeWizardState(wizardState: TWizardState): void {
    const state = this.readState();
    state.intersectionWizard = wizardState;
    this.writeState(state);
  }

  private fileName(): string {
    return path.resolve(this.exchangeDirectoryProvider(), FileNames.persistentServerState);
  }

  private readState(): PersistentServerState {
    try {
      const text = fs.readFileSync(this.fileName(), { encoding: 'utf8' });
      const parsed = JSON.parse(text);
      return parsed && typeof parsed === 'object' && !Array.isArray(parsed) ? parsed : {};
    } catch (_error) {
      return {};
    }
  }

  private writeState(state: PersistentServerState): void {
    fs.writeFileSync(this.fileName(), JSON.stringify(state, null, 2), { encoding: 'utf8' });
  }
}
