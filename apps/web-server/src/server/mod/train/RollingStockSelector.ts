import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { RollingStockLuaDto } from '../../ce/dto/rolling-stocks/RollingStockLuaDto';
import { CeTypes, RollingStockDto } from '@ak/web-shared';

export class RollingStockSelector {
  private lastState: fromJsonData.State = undefined;
  private allRollingStock = new Map<string, RollingStockDto>();
  private trainRollingStock = new Map<string, Map<number, RollingStockDto>>();

  updateFromState(state: fromJsonData.State): void {
    if (state === this.lastState || !state.ceTypes[CeTypes.HubRollingStock]) {
      return;
    }

    this.allRollingStock.clear();
    this.trainRollingStock.clear();

    const rollingStockDict = state.ceTypes[CeTypes.HubRollingStock] as unknown as Record<string, RollingStockLuaDto>;
    Object.values(rollingStockDict).forEach((rsDto: RollingStockLuaDto) => {
      const rollingStock: RollingStockDto = {
        id: rsDto.id,
        name: rsDto.name,
        couplingFront: rsDto.couplingFront,
        couplingRear: rsDto.couplingRear,
        length: rsDto.length,
        modelType: rsDto.modelType,
        modelTypeText: rsDto.modelTypeText,
        positionInTrain: rsDto.positionInTrain,
        propelled: rsDto.propelled,
        tag: rsDto.tag,
        nr: rsDto.nr,
        trackSystem: rsDto.trackSystem,
        trackType: rsDto.trackType,
        trackId: rsDto.trackId,
        trackDistance: rsDto.trackDistance,
        trackDirection: rsDto.trackDirection,
        trainName: rsDto.trainName,
        posX: rsDto.posX,
        posY: rsDto.posY,
        posZ: rsDto.posZ,
        mileage: rsDto.mileage,
        orientationForward: rsDto.orientationForward,
        smoke: rsDto.smoke,
        hookStatus: rsDto.hookStatus,
        hookGlueMode: rsDto.hookGlueMode,
        active: rsDto.active,
      };
      const trainRs = this.trainRollingStock.get(rollingStock.trainName) || new Map();
      trainRs.set(rollingStock.positionInTrain, rollingStock);
      this.trainRollingStock.set(rollingStock.trainName, trainRs);
      this.allRollingStock.set(rollingStock.id, rollingStock);
    });
    this.lastState = state;
  }

  rollingStockListOfTrain(trainId: string): RollingStockDto[] {
    const rsList: RollingStockDto[] = [];
    const trainRollingStock = this.trainRollingStock.get(trainId) || new Map<number, RollingStockDto>();
    const sortedKeys: number[] = Array.from(trainRollingStock.keys()).sort((a, b) => a - b);
    for (const key of sortedKeys) {
      rsList.push(trainRollingStock.get(key));
    }
    return rsList;
  }

  rollingStockInTrain(trainId: string, positionOfRollingStock: number): RollingStockDto {
    if (this.trainRollingStock && this.trainRollingStock.get(trainId)) {
      return this.trainRollingStock.get(trainId).get(positionOfRollingStock);
    } else {
      return undefined;
    }
  }
}
