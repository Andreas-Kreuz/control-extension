import { VersionLuaDto } from '../../ce/dto/version/VersionLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, VersionDto } from '@ak/web-shared';

export default class VersionSelector {
  private lastState: fromEepData.State = undefined;
  private versions: Record<string, VersionDto> = {};

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
        eepLanguage: dto.eepLanguage,
        layoutVersion: dto.layoutVersion,
        layoutLanguage: dto.layoutLanguage,
        layoutName: dto.layoutName,
        layoutPath: dto.layoutPath,
      };
    });
  }

  getVersions = (): Record<string, VersionDto> => this.versions;
}
