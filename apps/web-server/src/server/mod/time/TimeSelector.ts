import { TimeLuaDto } from '../../ce/dto/time/TimeLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import { CeTypes, TimeDto } from '@ak/web-shared';

export default class TimeSelector {
  private lastState?: fromEepData.State;
  private times: Record<string, TimeDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.ceTypes[CeTypes.HubTime]) {
      return;
    }
    this.lastState = state;
    const dict = state.ceTypes[CeTypes.HubTime] as unknown as Record<string, TimeLuaDto>;
    this.times = {};
    Object.values(dict).forEach((dto: TimeLuaDto) => {
      this.times[dto.id] = {
        id: dto.id,
        name: dto.name,
        timeComplete: dto.timeComplete,
        timeH: dto.timeH,
        timeM: dto.timeM,
        timeS: dto.timeS,
        ...optionalProperty('timeLapse', dto.timeLapse),
      };
    });
  }

  getTimes = (): Record<string, TimeDto> => this.times;
}
