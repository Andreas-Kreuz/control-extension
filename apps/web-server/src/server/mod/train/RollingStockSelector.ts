import * as fromJsonData from '../../eep/server-data/EepDataStore';
import { RollingStockLuaDto } from '../../ce/dto/rolling-stocks/RollingStockLuaDto';
import { CeTypes, RollingStockAppDto, RollingStockRotationAppDto, RollingStockTexturesAppDto } from '@ce/web-shared';

// Maps Lua rolling-stock DTOs into rolling-stock AppDtos.
// Lua input: ce.hub.RollingStock.
export class RollingStockSelector {
  private lastState: Record<string, unknown> | undefined;
  private allRollingStock = new Map<string, RollingStockAppDto>();
  private trainRollingStock = new Map<string, Map<number, RollingStockAppDto>>();
  private rollingStockTexturesMap = new Map<string, RollingStockTexturesAppDto>();
  private rollingStockRotationMap = new Map<string, RollingStockRotationAppDto>();

  updateFromState(state: fromJsonData.State): void {
    const rollingStockState = state.ceTypes[CeTypes.HubRollingStock] as Record<string, unknown> | undefined;
    if (rollingStockState === this.lastState) {
      return;
    }

    this.allRollingStock.clear();
    this.trainRollingStock.clear();
    this.rollingStockTexturesMap.clear();
    this.rollingStockRotationMap.clear();

    if (!rollingStockState) {
      this.lastState = rollingStockState;
      return;
    }

    const rollingStockDict = rollingStockState as Record<string, RollingStockLuaDto>;
    Object.values(rollingStockDict).forEach((rsDto) => {
      const rollingStock: RollingStockAppDto = {
        id: rsDto.id,
        name: rsDto.name ?? rsDto.id,
        trainName: rsDto.trainName ?? '',
        positionInTrain: rsDto.positionInTrain ?? 0,
        couplingFront: rsDto.couplingFront ?? 0,
        couplingRear: rsDto.couplingRear ?? 0,
        length: rsDto.length ?? 0,
        propelled: rsDto.propelled ?? false,
        modelType: rsDto.modelType ?? 0,
        modelTypeText: rsDto.modelTypeText ?? '',
        tag: rsDto.tag ?? '',
        hookStatus: rsDto.hookStatus ?? 0,
        hookGlueMode: rsDto.hookGlueMode ?? 0,
        ...(rsDto.licencePlate !== undefined ? { licencePlate: rsDto.licencePlate } : {}),
        ...(rsDto.vehicleNumber !== undefined ? { vehicleNumber: rsDto.vehicleNumber } : {}),
        ...(rsDto.nr !== undefined ? { nr: rsDto.nr } : {}),
        ...(rsDto.trackType !== undefined ? { trackType: rsDto.trackType } : {}),
        trackSystem: rsDto.trackSystem ?? 0,
        trackId: rsDto.trackId ?? 0,
        trackDistance: rsDto.trackDistance ?? 0,
        trackDirection: rsDto.trackDirection ?? 0,
        posX: rsDto.posX ?? 0,
        posY: rsDto.posY ?? 0,
        posZ: rsDto.posZ ?? 0,
        mileage: rsDto.mileage ?? 0,
        orientationForward: rsDto.orientationForward ?? true,
        smoke: rsDto.smoke ?? 0,
        active: rsDto.active ?? false,
        axisNamesKnown: rsDto.axisNamesKnown === true,
        axisNames: normalizeNumberRecord(rsDto.axisNames),
        axisValues: normalizeNumberRecord(rsDto.axisValues),
        surfaceTexts: normalizeNumberRecord(rsDto.surfaceTexts),
        textureNames: normalizeNumberRecord(rsDto.textureNames),
        rotX: rsDto.rotX ?? 0,
        rotY: rsDto.rotY ?? 0,
        rotZ: rsDto.rotZ ?? 0,
        ...(rsDto.xmlModel !== undefined ? { xmlModel: rsDto.xmlModel } : {}),
      };
      const trainRs = this.trainRollingStock.get(rollingStock.trainName) ?? new Map<number, RollingStockAppDto>();
      trainRs.set(rollingStock.positionInTrain, rollingStock);
      this.trainRollingStock.set(rollingStock.trainName, trainRs);
      this.allRollingStock.set(rollingStock.id, rollingStock);

      if (rsDto.surfaceTexts !== undefined) {
        this.rollingStockTexturesMap.set(rsDto.id, {
          id: rsDto.id,
          surfaceTexts: normalizeNumberRecord(rsDto.surfaceTexts),
          textureNames: normalizeNumberRecord(rsDto.textureNames),
        });
      }

      if (rsDto.rotX !== undefined || rsDto.rotY !== undefined || rsDto.rotZ !== undefined) {
        this.rollingStockRotationMap.set(rsDto.id, {
          id: rsDto.id,
          rotX: rsDto.rotX ?? 0,
          rotY: rsDto.rotY ?? 0,
          rotZ: rsDto.rotZ ?? 0,
        });
      }
    });

    this.lastState = rollingStockState;
  }

  getRollingStock(id: string): RollingStockAppDto | undefined {
    return this.allRollingStock.get(id);
  }

  rollingStockListOfTrain(trainId: string): RollingStockAppDto[] {
    const rsList: RollingStockAppDto[] = [];
    const trainRollingStock = this.trainRollingStock.get(trainId) ?? new Map<number, RollingStockAppDto>();
    const sortedKeys = Array.from(trainRollingStock.keys()).sort((a, b) => a - b);
    for (const key of sortedKeys) {
      const rollingStock = trainRollingStock.get(key);
      if (rollingStock) {
        rsList.push(rollingStock);
      }
    }
    return rsList;
  }

  rollingStockInTrain(trainId: string, positionOfRollingStock: number): RollingStockAppDto | undefined {
    return this.trainRollingStock.get(trainId)?.get(positionOfRollingStock);
  }

  getAllRollingStock(): Record<string, RollingStockAppDto> {
    return Object.fromEntries(this.allRollingStock.entries());
  }

  getRollingStockTextures(id: string): RollingStockTexturesAppDto | undefined {
    return this.rollingStockTexturesMap.get(id);
  }

  getAllRollingStockTextures(): Record<string, RollingStockTexturesAppDto> {
    return Object.fromEntries(this.rollingStockTexturesMap.entries());
  }

  getRollingStockRotation(id: string): RollingStockRotationAppDto | undefined {
    return this.rollingStockRotationMap.get(id);
  }

  getAllRollingStockRotation(): Record<string, RollingStockRotationAppDto> {
    return Object.fromEntries(this.rollingStockRotationMap.entries());
  }
}

function normalizeNumberRecord<T>(value: Record<string, T> | T[] | undefined): Record<string, T> {
  if (Array.isArray(value)) {
    return Object.fromEntries(value.map((entry, index) => [String(index + 1), entry]));
  }

  return { ...(value ?? {}) };
}
