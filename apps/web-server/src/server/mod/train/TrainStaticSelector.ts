import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { TrainStaticLuaDto } from '../../ce/dto/trains/TrainStaticLuaDto';
import { RollingStockStaticSelector } from './RollingStockStaticSelector';
import { calcTrainType, CeTypes, TrainListDto, TrainStaticDto, TrainType } from '@ce/web-shared';

export class TrainStaticSelector {
  private trainState: Record<string, unknown> | undefined;
  private rollingStockState: Record<string, unknown> | undefined;
  private trainMap = new Map<string, TrainStaticDto>();
  private trainListMap = new Map<string, TrainListDto>();

  constructor(private rollingStockSelector: RollingStockStaticSelector) {}

  updateFromState = (state: Readonly<fromJsonData.State>): void => {
    const nextTrainState = state.ceTypes[CeTypes.HubTrainStatic] as Record<string, unknown> | undefined;
    const nextRollingStockState = state.ceTypes[CeTypes.HubRollingStockStatic] as Record<string, unknown> | undefined;
    if (this.trainState === nextTrainState && this.rollingStockState === nextRollingStockState) {
      return;
    }

    this.rollingStockSelector.updateFromState(state);
    this.trainMap.clear();
    this.trainListMap.clear();

    if (!nextTrainState) {
      this.trainState = nextTrainState;
      this.rollingStockState = nextRollingStockState;
      return;
    }

    const trainDict = nextTrainState as Record<string, TrainStaticLuaDto>;
    Object.values(trainDict).forEach((trainDto) => {
      const rollingStock = this.rollingStockSelector.rollingStockListOfTrain(trainDto.id);
      const trainType: TrainType = this.getTrainType(trainDto);
      const firstRollingStock = rollingStock[trainDto.movesForward ? 0 : rollingStock.length - 1];
      const lastRollingStock = rollingStock[trainDto.movesForward ? rollingStock.length - 1 : 0];
      const trainListDto: TrainListDto = {
        id: trainDto.id,
        name: trainDto.name,
        route: trainDto.route,
        firstRollingStockName: firstRollingStock?.name ?? trainDto.name,
        lastRollingStockName: lastRollingStock?.name ?? trainDto.name,
        trainType,
        rollingStockCount: trainDto.rollingStockCount,
        movesForward: trainDto.movesForward,
        ...(trainDto.line !== undefined ? { line: trainDto.line } : {}),
        ...(trainDto.destination !== undefined ? { destination: trainDto.destination } : {}),
        ...(trainDto.trackType !== undefined ? { trackType: trainDto.trackType } : {}),
      };
      this.trainListMap.set(trainListDto.id, trainListDto);

      const train: TrainStaticDto = {
        ...trainListDto,
        length: trainDto.length,
        ...(trainDto.direction !== undefined ? { direction: trainDto.direction } : {}),
      };
      this.trainMap.set(train.id, train);
    });

    this.trainState = nextTrainState;
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

  getAllTrains(): Record<string, TrainStaticDto> {
    return Object.fromEntries(this.trainMap.entries());
  }

  private getTrainType(train: TrainStaticLuaDto): TrainType {
    const firstRollingStock = this.rollingStockSelector.rollingStockInTrain(train.id, 0);
    if (firstRollingStock) {
      return calcTrainType(firstRollingStock.modelType, train.rollingStockCount);
    }

    return TrainType.TrainElectric;
  }
}

