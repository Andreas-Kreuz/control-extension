import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { RollingStockStaticLuaDto } from '../../ce/dto/rolling-stocks/RollingStockStaticLuaDto';
import { CeTypes, RollingStockStaticDto } from '@ak/web-shared';

export class RollingStockStaticSelector {
  private lastState: Record<string, unknown> | undefined;
  private allRollingStock = new Map<string, RollingStockStaticDto>();
  private trainRollingStock = new Map<string, Map<number, RollingStockStaticDto>>();

  updateFromState(state: fromJsonData.State): void {
    const rollingStockState = state.ceTypes[CeTypes.HubRollingStockStatic] as Record<string, unknown> | undefined;
    if (rollingStockState === this.lastState) {
      return;
    }

    this.allRollingStock.clear();
    this.trainRollingStock.clear();

    if (!rollingStockState) {
      this.lastState = rollingStockState;
      return;
    }

    const rollingStockDict = rollingStockState as Record<string, RollingStockStaticLuaDto>;
    Object.values(rollingStockDict).forEach((rsDto) => {
      const rollingStock: RollingStockStaticDto = {
        id: rsDto.id,
        name: rsDto.name,
        trainName: rsDto.trainName,
        positionInTrain: rsDto.positionInTrain,
        couplingFront: rsDto.couplingFront,
        couplingRear: rsDto.couplingRear,
        length: rsDto.length,
        propelled: rsDto.propelled,
        modelType: rsDto.modelType,
        modelTypeText: rsDto.modelTypeText,
        tag: rsDto.tag,
        hookStatus: rsDto.hookStatus,
        hookGlueMode: rsDto.hookGlueMode,
        ...(rsDto.nr !== undefined ? { nr: rsDto.nr } : {}),
        ...(rsDto.trackType !== undefined ? { trackType: rsDto.trackType } : {}),
      };
      const trainRs = this.trainRollingStock.get(rollingStock.trainName) ?? new Map<number, RollingStockStaticDto>();
      trainRs.set(rollingStock.positionInTrain, rollingStock);
      this.trainRollingStock.set(rollingStock.trainName, trainRs);
      this.allRollingStock.set(rollingStock.id, rollingStock);
    });

    this.lastState = rollingStockState;
  }

  getRollingStock(id: string): RollingStockStaticDto | undefined {
    return this.allRollingStock.get(id);
  }

  rollingStockListOfTrain(trainId: string): RollingStockStaticDto[] {
    const rsList: RollingStockStaticDto[] = [];
    const trainRollingStock = this.trainRollingStock.get(trainId) ?? new Map<number, RollingStockStaticDto>();
    const sortedKeys = Array.from(trainRollingStock.keys()).sort((a, b) => a - b);
    for (const key of sortedKeys) {
      const rollingStock = trainRollingStock.get(key);
      if (rollingStock) {
        rsList.push(rollingStock);
      }
    }
    return rsList;
  }

  rollingStockInTrain(trainId: string, positionOfRollingStock: number): RollingStockStaticDto | undefined {
    return this.trainRollingStock.get(trainId)?.get(positionOfRollingStock);
  }

  getAllRollingStock(): Record<string, RollingStockStaticDto> {
    return Object.fromEntries(this.allRollingStock.entries());
  }
}
