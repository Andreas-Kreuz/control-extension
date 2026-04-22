import { VersionLuaDto } from '../../ce/dto/version/VersionLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, VersionAppDto } from '@ce/web-shared';

// Maps Lua version DTOs into VersionAppDto.
// Lua input: ce.hub.EepVersion.
export default class VersionSelector {
  private lastState?: fromEepData.State;
  private versions: Record<string, VersionAppDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.ceTypes[CeTypes.HubEepVersion]) {
      return;
    }
    this.lastState = state;
    const dict = state.ceTypes[CeTypes.HubEepVersion] as unknown as Record<string, VersionLuaDto>;
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

  getVersions = (): Record<string, VersionAppDto> => this.versions;
}
