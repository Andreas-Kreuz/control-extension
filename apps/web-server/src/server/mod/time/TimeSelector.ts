import { TimeLuaDto } from '../../ce/dto/time/TimeLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { TimeDto } from '@ak/web-shared';

export default class TimeSelector {
  private lastState: fromEepData.State = undefined;
  private times: Record<string, TimeDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState || !state.rooms['times']) {
      return;
    }
    this.lastState = state;
    const dict = state.rooms['times'] as unknown as Record<string, TimeLuaDto>;
    this.times = {};
    Object.values(dict).forEach((dto: TimeLuaDto) => {
      this.times[dto.id] = {
        id: dto.id,
        name: dto.name,
        timeComplete: dto.timeComplete,
        timeH: dto.timeH,
        timeM: dto.timeM,
        timeS: dto.timeS,
      };
    });
  }

  getTimes = (): Record<string, TimeDto> => this.times;
}
