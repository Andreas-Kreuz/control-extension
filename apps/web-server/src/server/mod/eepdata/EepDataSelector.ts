import { RuntimeLuaDto } from '../../ce/dto/runtime/RuntimeLuaDto';
import { ModuleLuaDto } from '../../ce/dto/modules/ModuleLuaDto';
import { DataSlotLuaDto } from '../../ce/dto/data-slots/DataSlotLuaDto';
import { SignalLuaDto } from '../../ce/dto/signals/SignalLuaDto';
import { WaitingOnSignalLuaDto } from '../../ce/dto/signals/WaitingOnSignalLuaDto';
import { SwitchLuaDto } from '../../ce/dto/switches/SwitchLuaDto';
import { StructureLuaDto } from '../../ce/dto/structures/StructureLuaDto';
import { StructureStaticLuaDto } from '../../ce/dto/structures/StructureStaticLuaDto';
import { StructureDynamicLuaDto } from '../../ce/dto/structures/StructureDynamicLuaDto';
import { TrackLuaDto } from '../../ce/dto/tracks/TrackLuaDto';
import { RollingStockTexturesLuaDto } from '../../ce/dto/rolling-stocks/RollingStockTexturesLuaDto';
import { RollingStockRotationLuaDto } from '../../ce/dto/rolling-stocks/RollingStockRotationLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { optionalProperty } from '../../utils/optionalProperty';
import {
  CeTypes,
  RuntimeDto,
  RuntimeStatisticsDto,
  RuntimeStatisticsTimeDto,
  ModuleDto,
  DataSlotDto,
  SignalDto,
  WaitingOnSignalDto,
  SwitchDto,
  StructureDto,
  TrackDto,
  RollingStockTexturesDto,
  RollingStockRotationDto,
  trackTypeForCeType,
} from '@ce/web-shared';

const publisherCollectors = [
  'ce.hub.ModulesStatePublisher',
  'ce.hub.VersionStatePublisher',
  'ce.hub.data.runtime.RuntimeStatePublisher',
  'ce.hub.data.slots.DataSlotsStatePublisher',
  'ce.hub.data.signals.SignalStatePublisher',
  'ce.hub.data.structures.StructureStatePublisher',
  'ce.hub.data.switches.SwitchStatePublisher',
  'ce.hub.data.time.TimeStatePublisher',
  'ce.hub.data.weather.WeatherStatePublisher',
  'ce.hub.data.trains.TrainsAndTracksStatePublisher',
  'ce.mods.road.data.TrafficLightModelStatePublisher',
  'ce.mods.road.data.RoadStatePublisher',
  'ce.mods.transit.data.TransitStatePublisher',
] as const;

const ceModules = ['ce.hub.CeHubModule', 'ce.mods.road.CeRoadModule', 'ce.mods.transit.CeTransitModule'] as const;
const runtimeStatisticsHistoryLimit = 10;

interface RuntimeStatisticsSample {
  eventCounter: number;
  publisherSyncTimes: RuntimeStatisticsTimeDto[];
  moduleRunTimes: RuntimeStatisticsTimeDto[];
  controllerUpdateTimes: RuntimeStatisticsTimeDto[];
}

export default class EepDataSelector {
  private lastState?: fromEepData.State;
  private runtime: Record<string, RuntimeDto> = {};
  private runtimeStatisticsHistory: RuntimeStatisticsSample[] = [];
  private runtimeStatisticsInitialization: RuntimeStatisticsDto['initialization'] = {
    publisherInitTimes: [],
    moduleInitTimes: [],
  };
  private modules: Record<string, ModuleDto> = {};
  private saveSlots: Record<string, DataSlotDto> = {};
  private freeSlots: Record<string, DataSlotDto> = {};
  private signals: Record<string, SignalDto> = {};
  private waitingOnSignals: Record<string, WaitingOnSignalDto> = {};
  private switches: Record<string, SwitchDto> = {};
  private structures: Record<string, StructureDto> = {};
  private tracks: Record<string, Record<string, TrackDto>> = {};
  private rollingStockTextures: Record<string, RollingStockTexturesDto> = {};
  private rollingStockRotation: Record<string, RollingStockRotationDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    this.runtime = this.mapCeType<RuntimeLuaDto, RuntimeDto>(state, CeTypes.HubRuntime, (dto) => ({
      id: dto.id,
      count: dto.count,
      time: dto.time,
      lastTime: dto.lastTime,
    }));
    this.updateRuntimeStatistics(state.eventCounter, this.runtime);

    this.modules = this.mapCeType<ModuleLuaDto, ModuleDto>(state, CeTypes.HubModule, (dto) => ({
      id: dto.id,
      name: dto.name,
      enabled: dto.enabled,
    }));

    this.saveSlots = this.mapCeType<DataSlotLuaDto, DataSlotDto>(state, CeTypes.HubSaveSlot, (dto) => ({
      id: dto.id,
      name: dto.name,
      data: dto.data,
    }));

    this.freeSlots = this.mapCeType<DataSlotLuaDto, DataSlotDto>(state, CeTypes.HubFreeSlot, (dto) => ({
      id: dto.id,
      name: dto.name,
      data: dto.data,
    }));

    this.signals = this.mapCeType<SignalLuaDto, SignalDto>(state, CeTypes.HubSignal, (dto) => ({
      id: dto.id,
      position: dto.position,
      tag: dto.tag,
      waitingVehiclesCount: dto.waitingVehiclesCount,
      ...optionalProperty('stopDistance', dto.stopDistance),
      ...optionalProperty('itemName', dto.itemName),
      ...optionalProperty('itemNameWithModelPath', dto.itemNameWithModelPath),
      ...optionalProperty('signalFunctions', dto.signalFunctions),
      ...optionalProperty('activeFunction', dto.activeFunction),
    }));

    this.waitingOnSignals = this.mapCeType<WaitingOnSignalLuaDto, WaitingOnSignalDto>(
      state,
      CeTypes.HubWaitingOnSignal,
      (dto) => ({
        id: dto.id,
        signalId: dto.signalId,
        waitingPosition: dto.waitingPosition,
        vehicleName: dto.vehicleName,
        waitingCount: dto.waitingCount,
      }),
    );

    this.switches = this.mapCeType<SwitchLuaDto, SwitchDto>(state, CeTypes.HubSwitch, (dto) => ({
      id: dto.id,
      position: dto.position,
      tag: dto.tag,
    }));

    const legacyStructures = this.mapCeType<StructureLuaDto, StructureDto>(state, CeTypes.HubStructure, (dto) => ({
      id: dto.id,
      name: dto.name,
      pos_x: dto.pos_x,
      pos_y: dto.pos_y,
      pos_z: dto.pos_z,
      rot_x: dto.rot_x,
      rot_y: dto.rot_y,
      rot_z: dto.rot_z,
      modelType: dto.modelType,
      modelTypeText: dto.modelTypeText,
      tag: dto.tag,
      light: dto.light,
      smoke: dto.smoke,
      fire: dto.fire,
    }));
    const structureStatic = this.mapCeType<StructureStaticLuaDto, StructureDto>(
      state,
      CeTypes.HubStructureStatic,
      (dto) => ({
        id: dto.id,
        name: dto.name,
        pos_x: dto.pos_x,
        pos_y: dto.pos_y,
        pos_z: dto.pos_z,
        rot_x: dto.rot_x,
        rot_y: dto.rot_y,
        rot_z: dto.rot_z,
        modelType: dto.modelType,
        modelTypeText: dto.modelTypeText,
        tag: dto.tag,
        light: false,
        smoke: false,
        fire: false,
      }),
    );
    const structureDynamic = this.mapCeType<StructureDynamicLuaDto, Pick<StructureDto, 'id' | 'light' | 'smoke' | 'fire'>>(
      state,
      CeTypes.HubStructureDynamic,
      (dto) => ({
        id: dto.id,
        light: dto.light,
        smoke: dto.smoke,
        fire: dto.fire,
      }),
    );
    this.structures = this.mergeStructureDtos(legacyStructures, structureStatic, structureDynamic);

    this.tracks = {};
    for (const ceType of Object.keys(state.ceTypes)) {
      const trackType = trackTypeForCeType(ceType);
      if (!trackType) continue;
      this.tracks[trackType] = this.mapCeType<TrackLuaDto, TrackDto>(state, ceType, (dto) => ({
        id: dto.id,
        ...optionalProperty('reserved', dto.reserved),
        ...optionalProperty('reservedByTrainName', dto.reservedByTrainName),
      }));
    }

    this.rollingStockTextures = this.mapCeType<RollingStockTexturesLuaDto, RollingStockTexturesDto>(
      state,
      CeTypes.HubRollingStockTextures,
      (dto) => ({
        id: dto.id,
        surfaceTexts: { ...(dto.surfaceTexts || {}) },
      }),
    );

    this.rollingStockRotation = this.mapCeType<RollingStockRotationLuaDto, RollingStockRotationDto>(
      state,
      CeTypes.HubRollingStockRotation,
      (dto) => ({
        id: dto.id,
        rotX: dto.rotX,
        rotY: dto.rotY,
        rotZ: dto.rotZ,
      }),
    );
  }

  private mapCeType<TLua, TDto>(
    state: fromEepData.State,
    ceType: string,
    mapper: (dto: TLua) => TDto,
  ): Record<string, TDto> {
    if (!state.ceTypes[ceType]) return {};
    const dict = state.ceTypes[ceType] as unknown as Record<string, TLua>;
    const result: Record<string, TDto> = {};
    Object.values(dict).forEach((dto: TLua) => {
      const mapped = mapper(dto);
      result[(mapped as { id: string }).id] = mapped;
    });
    return result;
  }

  private mergeStructureDtos(
    legacy: Record<string, StructureDto>,
    staticDtos: Record<string, StructureDto>,
    dynamicDtos: Record<string, Pick<StructureDto, 'id' | 'light' | 'smoke' | 'fire'>>,
  ): Record<string, StructureDto> {
    const structureIds = new Set([...Object.keys(legacy), ...Object.keys(staticDtos), ...Object.keys(dynamicDtos)]);
    const merged: Record<string, StructureDto> = {};

    structureIds.forEach((id) => {
      const legacyDto = legacy[id];
      const staticDto = staticDtos[id];
      const dynamicDto = dynamicDtos[id];
      merged[id] = {
        id,
        name: staticDto?.name ?? legacyDto?.name ?? id,
        pos_x: staticDto?.pos_x ?? legacyDto?.pos_x ?? 0,
        pos_y: staticDto?.pos_y ?? legacyDto?.pos_y ?? 0,
        pos_z: staticDto?.pos_z ?? legacyDto?.pos_z ?? 0,
        rot_x: staticDto?.rot_x ?? legacyDto?.rot_x ?? 0,
        rot_y: staticDto?.rot_y ?? legacyDto?.rot_y ?? 0,
        rot_z: staticDto?.rot_z ?? legacyDto?.rot_z ?? 0,
        modelType: staticDto?.modelType ?? legacyDto?.modelType ?? 0,
        modelTypeText: staticDto?.modelTypeText ?? legacyDto?.modelTypeText ?? '',
        tag: staticDto?.tag ?? legacyDto?.tag ?? '',
        light: dynamicDto?.light ?? legacyDto?.light ?? false,
        smoke: dynamicDto?.smoke ?? legacyDto?.smoke ?? false,
        fire: dynamicDto?.fire ?? legacyDto?.fire ?? false,
      };
    });

    return merged;
  }

  private updateRuntimeStatistics(eventCounter: number, runtime: Record<string, RuntimeDto>): void {
    if (Object.keys(runtime).length === 0) {
      this.runtimeStatisticsHistory = [];
      this.runtimeStatisticsInitialization = { publisherInitTimes: [], moduleInitTimes: [] };
      return;
    }

    this.runtimeStatisticsInitialization = {
      publisherInitTimes: publisherCollectors.map((collector) =>
        this.toRuntimeStatisticsTime(runtime, 'StatePublisher.' + collector + '.initialize', collector),
      ),
      moduleInitTimes: ceModules.map((moduleName) =>
        this.toRuntimeStatisticsTime(runtime, 'CeModule.' + moduleName + '.init', moduleName),
      ),
    };

    const nextSample: RuntimeStatisticsSample = {
      eventCounter,
      publisherSyncTimes: publisherCollectors.map((collector) =>
        this.toRuntimeStatisticsTime(runtime, 'StatePublisher.' + collector + '.syncState', collector),
      ),
      moduleRunTimes: ceModules.map((moduleName) =>
        this.toRuntimeStatisticsTime(runtime, 'CeModule.' + moduleName + '.run', moduleName),
      ),
      controllerUpdateTimes: [
        this.toRuntimeStatisticsTime(runtime, 'MainLoopRunner.runCycle-6-waitForServer', 'Wait for server to be ready'),
        this.toRuntimeStatisticsTime(runtime, 'MainLoopRunner.runCycle-5-commands', 'Command execution'),
        this.toRuntimeStatisticsTime(runtime, 'MainLoopRunner.runCycle-7-serverOutput', 'Server output'),
        this.toRuntimeStatisticsTime(runtime, 'MainLoopRunner.runCycle-8-dataStoreWrite', 'DataStore write'),
      ],
    };

    const lastSample = this.runtimeStatisticsHistory[this.runtimeStatisticsHistory.length - 1];
    if (!lastSample || !this.runtimeStatisticsSampleEquals(lastSample, nextSample)) {
      this.runtimeStatisticsHistory = [...this.runtimeStatisticsHistory, nextSample].slice(
        -runtimeStatisticsHistoryLimit,
      );
    }
  }

  private toRuntimeStatisticsTime(
    runtime: Record<string, RuntimeDto>,
    runtimeKey: string,
    label: string,
  ): RuntimeStatisticsTimeDto {
    return {
      id: label,
      ms: runtime[runtimeKey]?.time ?? 0,
    };
  }

  private runtimeStatisticsSampleEquals(left: RuntimeStatisticsSample, right: RuntimeStatisticsSample): boolean {
    return (
      this.runtimeStatisticsTimeListsEqual(left.publisherSyncTimes, right.publisherSyncTimes) &&
      this.runtimeStatisticsTimeListsEqual(left.moduleRunTimes, right.moduleRunTimes) &&
      this.runtimeStatisticsTimeListsEqual(left.controllerUpdateTimes, right.controllerUpdateTimes)
    );
  }

  private runtimeStatisticsTimeListsEqual(
    left: RuntimeStatisticsTimeDto[],
    right: RuntimeStatisticsTimeDto[],
  ): boolean {
    if (left.length !== right.length) {
      return false;
    }

    for (let i = 0; i < left.length; i += 1) {
      const leftEntry = left[i];
      const rightEntry = right[i];
      if (!leftEntry || !rightEntry || leftEntry.id !== rightEntry.id || leftEntry.ms !== rightEntry.ms) {
        return false;
      }
    }

    return true;
  }

  private cloneRuntimeStatisticsTimeList(list: RuntimeStatisticsTimeDto[]): RuntimeStatisticsTimeDto[] {
    return list.map((entry) => ({ ...entry }));
  }

  getRuntime = (): Record<string, RuntimeDto> => this.runtime;
  getRuntimeStatistics = (): RuntimeStatisticsDto => ({
    history: {
      publisherSyncTimes: this.runtimeStatisticsHistory.map((sample) =>
        this.cloneRuntimeStatisticsTimeList(sample.publisherSyncTimes),
      ),
      moduleRunTimes: this.runtimeStatisticsHistory.map((sample) =>
        this.cloneRuntimeStatisticsTimeList(sample.moduleRunTimes),
      ),
      controllerUpdateTimes: this.runtimeStatisticsHistory.map((sample) =>
        this.cloneRuntimeStatisticsTimeList(sample.controllerUpdateTimes),
      ),
      sampleEventCounters: this.runtimeStatisticsHistory.map((sample) => sample.eventCounter),
    },
    initialization: {
      publisherInitTimes: this.cloneRuntimeStatisticsTimeList(this.runtimeStatisticsInitialization.publisherInitTimes),
      moduleInitTimes: this.cloneRuntimeStatisticsTimeList(this.runtimeStatisticsInitialization.moduleInitTimes),
    },
  });
  getModules = (): Record<string, ModuleDto> => this.modules;
  getSaveSlots = (): Record<string, DataSlotDto> => this.saveSlots;
  getFreeSlots = (): Record<string, DataSlotDto> => this.freeSlots;
  getSignals = (): Record<string, SignalDto> => this.signals;
  getWaitingOnSignals = (): Record<string, WaitingOnSignalDto> => this.waitingOnSignals;
  getSwitches = (): Record<string, SwitchDto> => this.switches;
  getStructures = (): Record<string, StructureDto> => this.structures;
  getTracksForRoom = (trackType: string): Record<string, TrackDto> => this.tracks[trackType] ?? {};
  getTrackRoomNames = (): string[] => Object.keys(this.tracks);
  getRollingStockTextures = (): Record<string, RollingStockTexturesDto> => this.rollingStockTextures;
  getRollingStockRotation = (): Record<string, RollingStockRotationDto> => this.rollingStockRotation;
}
