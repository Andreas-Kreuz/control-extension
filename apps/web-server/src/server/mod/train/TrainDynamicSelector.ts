import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { TrainDynamicLuaDto } from '../../ce/dto/trains/TrainDynamicLuaDto';
import { CeTypes, TrainDynamicDto } from '@ak/web-shared';

export class TrainDynamicSelector {
  private lastState: Record<string, unknown> | undefined;
  private trainMap = new Map<string, TrainDynamicDto>();

  updateFromState = (state: Readonly<fromJsonData.State>): void => {
    const nextTrainState = state.ceTypes[CeTypes.HubTrainDynamic] as Record<string, unknown> | undefined;
    if (this.lastState === nextTrainState) {
      return;
    }

    this.trainMap.clear();

    if (!nextTrainState) {
      this.lastState = nextTrainState;
      return;
    }

    const trainDict = nextTrainState as Record<string, TrainDynamicLuaDto>;
    Object.values(trainDict).forEach((trainDto) => {
      this.trainMap.set(trainDto.id, {
        id: trainDto.id,
        speed: trainDto.speed,
        targetSpeed: trainDto.targetSpeed,
        couplingFront: trainDto.couplingFront,
        couplingRear: trainDto.couplingRear,
        active: trainDto.active,
        inTrainyard: trainDto.inTrainyard,
        ...(trainDto.trainyardId !== undefined ? { trainyardId: trainDto.trainyardId } : {}),
      });
    });

    this.lastState = nextTrainState;
  };

  getTrain(id: string): TrainDynamicDto | undefined {
    return this.trainMap.get(id);
  }
}
