import { VersionLuaDto } from '../../ce/dto/version/VersionLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import { CeTypes, VersionDto } from '@ce/web-shared';

export default class VersionSelector {
  private lastState?: fromEepData.State;
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
        ...optionalProperty('eepLanguage', dto.eepLanguage),
        ...optionalProperty('layoutVersion', dto.layoutVersion),
        ...optionalProperty('layoutLanguage', dto.layoutLanguage),
        ...optionalProperty('layoutName', dto.layoutName),
        ...optionalProperty('layoutPath', dto.layoutPath),
      };
    });
  }

  getVersions = (): Record<string, VersionDto> => this.versions;
}

