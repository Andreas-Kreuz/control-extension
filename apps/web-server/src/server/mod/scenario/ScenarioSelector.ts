import { ScenarioLuaDto } from '../../ce/dto/scenario/ScenarioLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import { CeTypes, ScenarioAppDto } from '@ce/web-shared';

// Maps Lua scenario DTOs into ScenarioAppDto.
// Lua input: ce.hub.Scenario.
export default class ScenarioSelector {
  private lastState?: fromEepData.State;
  private scenarios: Record<string, ScenarioAppDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;
    if (!state.ceTypes[CeTypes.HubScenario]) {
      this.scenarios = {};
      return;
    }
    const dict = state.ceTypes[CeTypes.HubScenario] as unknown as Record<string, ScenarioLuaDto>;
    this.scenarios = {};
    Object.values(dict).forEach((dto: ScenarioLuaDto) => {
      this.scenarios[dto.id] = {
        id: dto.id,
        name: dto.name,
        ...optionalProperty('scenarioName', dto.scenarioName),
        ...optionalProperty('scenarioPath', dto.scenarioPath),
        ...optionalProperty('savedWithEep', dto.savedWithEep),
        ...optionalProperty('scenarioLanguage', dto.scenarioLanguage),
        ...optionalProperty('eepLanguage', dto.eepLanguage),
        ...optionalProperty('activeTrain', dto.activeTrain),
        ...optionalProperty('activeRollingStock', dto.activeRollingStock),
        ...optionalProperty('timeLapse', dto.timeLapse),
        staticCameras: dto.staticCameras ?? [],
        dynamicCameras: dto.dynamicCameras ?? [],
      };
    });
  }

  getScenarios = (): Record<string, ScenarioAppDto> => this.scenarios;
}
