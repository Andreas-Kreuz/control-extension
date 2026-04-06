import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { TrainLuaDto } from '../../ce/dto/trains/TrainLuaDto';
import { RollingStockSelector } from './RollingStockSelector';
import { calcTrainType, CeTypes, TrainDynamicDto, TrainListDto, TrainStaticDto, TrainType } from '@ce/web-shared';

export class TrainSelector {
  private lastState: Record<string, unknown> | undefined;
  private rollingStockState: Record<string, unknown> | undefined;
  private trainMap = new Map<string, TrainStaticDto>();
  private trainListMap = new Map<string, TrainListDto>();
  private trainDynamicMap = new Map<string, TrainDynamicDto>();

  constructor(private rollingStockSelector: RollingStockSelector) {}

  updateFromState = (state: Readonly<fromJsonData.State>): void => {
    const nextTrainState = state.ceTypes[CeTypes.HubTrain] as Record<string, unknown> | undefined;
    const nextRollingStockState = state.ceTypes[CeTypes.HubRollingStock] as Record<string, unknown> | undefined;
    if (this.lastState === nextTrainState && this.rollingStockState === nextRollingStockState) {
      return;
    }

    this.rollingStockSelector.updateFromState(state);
    this.trainMap.clear();
    this.trainListMap.clear();
    this.trainDynamicMap.clear();

    if (!nextTrainState) {
      this.lastState = nextTrainState;
      this.rollingStockState = nextRollingStockState;
      return;
    }

    const trainDict = nextTrainState as Record<string, TrainLuaDto>;
    Object.values(trainDict).forEach((trainDto) => {
      const rollingStock = this.rollingStockSelector.rollingStockListOfTrain(trainDto.id);
      const trainType: TrainType = this.getTrainType(trainDto);
      const movesForward = trainDto.movesForward ?? true;
      const firstRollingStock = rollingStock[movesForward ? 0 : rollingStock.length - 1];
      const lastRollingStock = rollingStock[movesForward ? rollingStock.length - 1 : 0];
      const trainListDto: TrainListDto = {
        id: trainDto.id,
        name: trainDto.name ?? trainDto.id,
        route: trainDto.route ?? '',
        firstRollingStockName: firstRollingStock?.name ?? trainDto.name ?? trainDto.id,
        lastRollingStockName: lastRollingStock?.name ?? trainDto.name ?? trainDto.id,
        trainType,
        rollingStockCount: trainDto.rollingStockCount ?? 0,
        movesForward,
        ...(trainDto.line !== undefined ? { line: trainDto.line } : {}),
        ...(trainDto.destination !== undefined ? { destination: trainDto.destination } : {}),
        ...(trainDto.trackType !== undefined ? { trackType: trainDto.trackType } : {}),
      };
      this.trainListMap.set(trainListDto.id, trainListDto);

      const train: TrainStaticDto = {
        ...trainListDto,
        length: trainDto.length ?? 0,
        ...(trainDto.direction !== undefined ? { direction: trainDto.direction } : {}),
      };
      this.trainMap.set(train.id, train);

      this.trainDynamicMap.set(trainDto.id, {
        id: trainDto.id,
        speed: trainDto.speed ?? 0,
        targetSpeed: trainDto.targetSpeed ?? 0,
        couplingFront: trainDto.couplingFront ?? 0,
        couplingRear: trainDto.couplingRear ?? 0,
        active: trainDto.active ?? false,
        inTrainyard: trainDto.inTrainyard ?? false,
        ...(trainDto.trainyardId !== undefined && trainDto.trainyardId !== '' ? { trainyardId: Number(trainDto.trainyardId) } : {}),
      });
    });

    this.lastState = nextTrainState;
    this.rollingStockState = nextRollingStockState;
  };

  getTrainList(trackType: string): TrainListDto[] {
    return Array.from(this.trainListMap.values())
      .filter((train) => train.trackType === trackType)
      .sort((left, right) => left.id.localeCompare(right.id, 'de'));
  }

  getTrain(id: string): TrainStaticDto | undefined {
    return this.trainMap.get(id);
  }

  getTrainDynamic(id: string): TrainDynamicDto | undefined {
    return this.trainDynamicMap.get(id);
  }

  getAllTrains(): Record<string, TrainStaticDto> {
    return Object.fromEntries(this.trainMap.entries());
  }

  private getTrainType(train: TrainLuaDto): TrainType {
    const firstRollingStock = this.rollingStockSelector.rollingStockInTrain(train.id, 0);
    if (firstRollingStock) {
      return calcTrainType(firstRollingStock.modelType, train.rollingStockCount ?? 0);
    }

    return TrainType.TrainElectric;
  }
}
