import { ScenarioLuaDto } from '../../ce/dto/scenario/ScenarioLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import { CeTypes, ScenarioDto } from '@ce/web-shared';

export default class ScenarioSelector {
  private lastState?: fromEepData.State;
  private scenarios: Record<string, ScenarioDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.ceTypes[CeTypes.HubScenario]) {
      return;
    }
    this.lastState = state;
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
      };
    });
  }

  getScenarios = (): Record<string, ScenarioDto> => this.scenarios;
}
