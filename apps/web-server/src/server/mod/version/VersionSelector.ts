import { VersionLuaDto } from '../../ce/dto/version/VersionLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { VersionDto } from '@ak/web-shared';

export default class VersionSelector {
  private lastState: fromEepData.State = undefined;
  private versions: Record<string, VersionDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.rooms['eep-version']) {
      return;
    }
    this.lastState = state;
    const dict = state.rooms['eep-version'] as unknown as Record<string, VersionLuaDto>;
    this.versions = {};
    Object.values(dict).forEach((dto: VersionLuaDto) => {
      this.versions[dto.id] = {
        id: dto.id,
        name: dto.name,
        eepVersion: dto.eepVersion,
        luaVersion: dto.luaVersion,
        singleVersion: dto.singleVersion,
      };
    });
  }

  getVersions = (): Record<string, VersionDto> => this.versions;
}
