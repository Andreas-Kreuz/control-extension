import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { RollingStockDynamicLuaDto } from '../../ce/dto/rolling-stocks/RollingStockDynamicLuaDto';
import { CeTypes, RollingStockDynamicDto } from '@ce/web-shared';

export class RollingStockDynamicSelector {
  private lastState: Record<string, unknown> | undefined;
  private dynamicRollingStock = new Map<string, RollingStockDynamicDto>();

  updateFromState(state: fromJsonData.State): void {
    const rollingStockState = state.ceTypes[CeTypes.HubRollingStockDynamic] as Record<string, unknown> | undefined;
    if (rollingStockState === this.lastState) {
      return;
    }

    this.dynamicRollingStock.clear();

    if (!rollingStockState) {
      this.lastState = rollingStockState;
      return;
    }

    const rollingStockDict = rollingStockState as Record<string, RollingStockDynamicLuaDto>;
    Object.values(rollingStockDict).forEach((rsDto) => {
      this.dynamicRollingStock.set(rsDto.id, {
        id: rsDto.id,
        trackSystem: rsDto.trackSystem,
        trackId: rsDto.trackId,
        trackDistance: rsDto.trackDistance,
        trackDirection: rsDto.trackDirection,
        posX: rsDto.posX,
        posY: rsDto.posY,
        posZ: rsDto.posZ,
        mileage: rsDto.mileage,
        orientationForward: rsDto.orientationForward,
        smoke: rsDto.smoke,
        active: rsDto.active,
      });
    });

    this.lastState = rollingStockState;
  }

  getRollingStock(id: string): RollingStockDynamicDto | undefined {
    return this.dynamicRollingStock.get(id);
  }
}

