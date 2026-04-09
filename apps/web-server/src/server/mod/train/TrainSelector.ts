import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { TrainLuaDto } from '../../ce/dto/trains/TrainLuaDto';
import { TransitTrainLuaDto } from '../../ce/dto/transit/TransitTrainLuaDto';
import { RollingStockSelector } from './RollingStockSelector';
import { calcTrainType, CeTypes, TrackType, TrainDto, TrainListDto, TrainType } from '@ce/web-shared';

export class TrainSelector {
  private lastState: Record<string, unknown> | undefined;
  private rollingStockState: Record<string, unknown> | undefined;
  private transitTrainState: Record<string, unknown> | undefined;
  private trainMap = new Map<string, TrainDto>();
  private trainListMap = new Map<string, TrainListDto>();

  constructor(private rollingStockSelector: RollingStockSelector) {}

  updateFromState = (state: Readonly<fromJsonData.State>): void => {
    const nextTrainState = state.ceTypes[CeTypes.HubTrain] as Record<string, unknown> | undefined;
    const nextRollingStockState = state.ceTypes[CeTypes.HubRollingStock] as Record<string, unknown> | undefined;
    const nextTransitTrainState = state.ceTypes[CeTypes.TransitTrain] as Record<string, unknown> | undefined;
    if (
      this.lastState === nextTrainState &&
      this.rollingStockState === nextRollingStockState &&
      this.transitTrainState === nextTransitTrainState
    ) {
      return;
    }

    this.rollingStockSelector.updateFromState(state);
    this.trainMap.clear();
    this.trainListMap.clear();

    if (!nextTrainState) {
      this.lastState = nextTrainState;
      this.rollingStockState = nextRollingStockState;
      return;
    }

    const trainDict = nextTrainState as Record<string, TrainLuaDto>;
    const transitTrainDict = (nextTransitTrainState ?? {}) as Record<string, TransitTrainLuaDto>;
    Object.values(trainDict).forEach((trainDto) => {
      const transitTrainDto = transitTrainDict[trainDto.id];
      const rollingStock = this.rollingStockSelector.rollingStockListOfTrain(trainDto.id);
      const trainType: TrainType = this.getTrainType(trainDto);
      const movesForward = trainDto.movesForward ?? true;
      const firstRollingStock = rollingStock[movesForward ? 0 : rollingStock.length - 1];
      const lastRollingStock = rollingStock[movesForward ? rollingStock.length - 1 : 0];
      const trackType = this.getTrackType(trainDto, firstRollingStock, lastRollingStock);
      const trainListDto: TrainListDto = {
        id: trainDto.id,
        name: trainDto.name ?? trainDto.id,
        route: trainDto.route ?? '',
        firstRollingStockName: firstRollingStock?.name ?? trainDto.name ?? trainDto.id,
        lastRollingStockName: lastRollingStock?.name ?? trainDto.name ?? trainDto.id,
        trainType,
        rollingStockCount: trainDto.rollingStockCount ?? 0,
        movesForward,
        ...(transitTrainDto?.line !== undefined ? { line: transitTrainDto.line } : {}),
        ...(transitTrainDto?.destination !== undefined ? { destination: transitTrainDto.destination } : {}),
        ...(trackType !== undefined ? { trackType } : {}),
      };
      this.trainListMap.set(trainListDto.id, trainListDto);

      const train: TrainDto = {
        id: trainDto.id,
        name: trainDto.name ?? trainDto.id,
        route: trainDto.route ?? '',
        rollingStockCount: trainDto.rollingStockCount ?? 0,
        length: trainDto.length ?? 0,
        speed: trainDto.speed ?? 0,
        targetSpeed: trainDto.targetSpeed ?? 0,
        couplingFront: trainDto.couplingFront ?? 0,
        couplingRear: trainDto.couplingRear ?? 0,
        active: trainDto.active ?? false,
        inTrainyard: trainDto.inTrainyard ?? false,
        movesForward,
        ...(transitTrainDto?.line !== undefined ? { line: transitTrainDto.line } : {}),
        ...(transitTrainDto?.destination !== undefined ? { destination: transitTrainDto.destination } : {}),
        ...(transitTrainDto?.direction !== undefined ? { direction: transitTrainDto.direction } : {}),
        ...(trackType !== undefined ? { trackType } : {}),
        ...(trainDto.trainyardId !== undefined && trainDto.trainyardId !== ''
          ? { trainyardId: Number(trainDto.trainyardId) }
          : {}),
      };
      this.trainMap.set(train.id, train);
    });

    this.lastState = nextTrainState;
    this.rollingStockState = nextRollingStockState;
    this.transitTrainState = nextTransitTrainState;
  };

  getTrainList(trackType: string): TrainListDto[] {
    return Array.from(this.trainListMap.values())
      .filter((train) => train.trackType === trackType)
      .sort((left, right) => left.id.localeCompare(right.id, 'de'));
  }

  getTrain(id: string): TrainDto | undefined {
    return this.trainMap.get(id);
  }

  getAllTrains(): Record<string, TrainDto> {
    return Object.fromEntries(this.trainMap.entries());
  }

  private getTrainType(train: TrainLuaDto): TrainType {
    const firstRollingStock = this.rollingStockSelector.rollingStockInTrain(train.id, 0);
    if (firstRollingStock) {
      return calcTrainType(firstRollingStock.modelType, train.rollingStockCount ?? 0);
    }

    return TrainType.TrainElectric;
  }

  private getTrackType(
    train: TrainLuaDto,
    firstRollingStock?: { trackType?: string; trackSystem?: number },
    lastRollingStock?: { trackType?: string; trackSystem?: number },
  ): string | undefined {
    return (
      train.trackType ??
      firstRollingStock?.trackType ??
      lastRollingStock?.trackType ??
      this.trackTypeFromTrackSystem(firstRollingStock?.trackSystem) ??
      this.trackTypeFromTrackSystem(lastRollingStock?.trackSystem)
    );
  }

  private trackTypeFromTrackSystem(trackSystem?: number): TrackType | undefined {
    switch (trackSystem) {
      case 1:
        return TrackType.Rail;
      case 2:
        return TrackType.Tram;
      case 3:
        return TrackType.Road;
      case 4:
        return TrackType.Auxiliary;
      case 5:
        return TrackType.Control;
      default:
        return undefined;
    }
  }
}
