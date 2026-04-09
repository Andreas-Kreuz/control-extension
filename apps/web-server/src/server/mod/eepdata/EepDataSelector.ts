import { RuntimeLuaDto } from '../../ce/dto/runtime/RuntimeLuaDto';
import { ModuleLuaDto } from '../../ce/dto/modules/ModuleLuaDto';
import { DataSlotLuaDto } from '../../ce/dto/data-slots/DataSlotLuaDto';
import { SignalLuaDto } from '../../ce/dto/signals/SignalLuaDto';
import { WaitingOnSignalLuaDto } from '../../ce/dto/signals/WaitingOnSignalLuaDto';
import { SwitchLuaDto } from '../../ce/dto/switches/SwitchLuaDto';
import { StructureLuaDto } from '../../ce/dto/structures/StructureLuaDto';
import { TrackLuaDto } from '../../ce/dto/tracks/TrackLuaDto';
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
  trackTypeForCeType,
} from '@ce/web-shared';

interface RuntimeStatisticsCollector {
  label: string;
  runtimeKeys: string[];
}

const legacyPublisherCollectors = [
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

const legacyCeModules = ['ce.hub.CeHubModule', 'ce.mods.road.CeRoadModule', 'ce.mods.transit.CeTransitModule'] as const;
const groupedPublisherCollectors: RuntimeStatisticsCollector[] = [
  { label: 'Update/ce.hub.DataSlots', runtimeKeys: ['Update/ce.hub.DataSlot', 'Update/ce.hub.DataSlots'] },
  { label: 'Update/ce.hub.FrameData', runtimeKeys: ['Update/ce.hub.Frame', 'Update/ce.hub.FrameData'] },
  { label: 'Update/ce.hub.Module', runtimeKeys: ['Update/ce.hub.Module'] },
  { label: 'Update/ce.hub.RollingStock', runtimeKeys: ['Update/ce.hub.RollingStock'] },
  { label: 'Update/ce.hub.Runtime', runtimeKeys: ['Update/ce.hub.Runtime'] },
  { label: 'Update/ce.hub.Signal', runtimeKeys: ['Update/ce.hub.Signal'] },
  { label: 'Update/ce.hub.Scenario', runtimeKeys: ['Update/ce.hub.Scenario'] },
  { label: 'Update/ce.hub.Structure', runtimeKeys: ['Update/ce.hub.Structure'] },
  { label: 'Update/ce.hub.Switch', runtimeKeys: ['Update/ce.hub.Switch'] },
  { label: 'Update/ce.hub.Time', runtimeKeys: ['Update/ce.hub.Time'] },
  { label: 'Update/ce.hub.Train', runtimeKeys: ['Update/ce.hub.Train'] },
  { label: 'Update/ce.hub.Version', runtimeKeys: ['Update/ce.hub.Version'] },
  { label: 'Update/ce.hub.Weather', runtimeKeys: ['Update/ce.hub.Weather'] },
];
const groupedModuleCollectors: RuntimeStatisticsCollector[] = [
  { label: 'Discovery/ce.hub.Signal', runtimeKeys: ['Discovery/ce.hub.Signal'] },
  { label: 'Discovery/ce.hub.Switch', runtimeKeys: ['Discovery/ce.hub.Switch'] },
  { label: 'Discovery/ce.hub.Structure', runtimeKeys: ['Discovery/ce.hub.Structure'] },
  { label: 'Discovery/ce.hub.Train', runtimeKeys: ['Discovery/ce.hub.Train'] },
];
const groupedPublisherInitCollectors: RuntimeStatisticsCollector[] = [
  {
    label: 'Update-init/ce.hub.DataSlot',
    runtimeKeys: ['Update-init/ce.hub.DataSlot', 'Update-init/ce.hub.DataSlots'],
  },
  { label: 'Update-init/ce.hub.Frame', runtimeKeys: ['Update-init/ce.hub.Frame', 'Update-init/ce.hub.FrameData'] },
  { label: 'Update-init/ce.hub.Module', runtimeKeys: ['Update-init/ce.hub.Module'] },
  { label: 'Update-init/ce.hub.RollingStock', runtimeKeys: ['Update-init/ce.hub.RollingStock'] },
  { label: 'Update-init/ce.hub.Runtime', runtimeKeys: ['Update-init/ce.hub.Runtime'] },
  { label: 'Update-init/ce.hub.Signal', runtimeKeys: ['Update-init/ce.hub.Signal'] },
  { label: 'Update-init/ce.hub.Scenario', runtimeKeys: ['Update-init/ce.hub.Scenario'] },
  { label: 'Update-init/ce.hub.Structure', runtimeKeys: ['Update-init/ce.hub.Structure'] },
  { label: 'Update-init/ce.hub.Switch', runtimeKeys: ['Update-init/ce.hub.Switch'] },
  { label: 'Update-init/ce.hub.Time', runtimeKeys: ['Update-init/ce.hub.Time'] },
  { label: 'Update-init/ce.hub.Train', runtimeKeys: ['Update-init/ce.hub.Train'] },
  { label: 'Update-init/ce.hub.Version', runtimeKeys: ['Update-init/ce.hub.Version'] },
  { label: 'Update-init/ce.hub.Weather', runtimeKeys: ['Update-init/ce.hub.Weather'] },
];
const groupedModuleInitCollectors: RuntimeStatisticsCollector[] = [
  { label: 'Discovery-init/ce.hub.Signal', runtimeKeys: ['Discovery-init/ce.hub.Signal'] },
  { label: 'Discovery-init/ce.hub.Switch', runtimeKeys: ['Discovery-init/ce.hub.Switch'] },
  { label: 'Discovery-init/ce.hub.Structure', runtimeKeys: ['Discovery-init/ce.hub.Structure'] },
  { label: 'Discovery-init/ce.hub.Train', runtimeKeys: ['Discovery-init/ce.hub.Train'] },
];
const runtimeStatisticsHistoryLimit = 10;

interface RuntimeStatisticsSample {
  eventCounter: number;
  publisherSyncTimes: RuntimeStatisticsTimeDto[];
  moduleRunTimes: RuntimeStatisticsTimeDto[];
  updateTimes: RuntimeStatisticsTimeDto[];
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

    this.structures = this.mapCeType<StructureLuaDto, StructureDto>(state, CeTypes.HubStructure, (dto) => ({
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

  private updateRuntimeStatistics(eventCounter: number, runtime: Record<string, RuntimeDto>): void {
    if (Object.keys(runtime).length === 0) {
      this.runtimeStatisticsHistory = [];
      this.runtimeStatisticsInitialization = { publisherInitTimes: [], moduleInitTimes: [] };
      return;
    }

    const usesGroupedRuntimeStatistics = groupedPublisherCollectors.some((collector) =>
      collector.runtimeKeys.some((runtimeKey) => runtime[runtimeKey] !== undefined),
    );

    this.runtimeStatisticsInitialization = usesGroupedRuntimeStatistics
      ? {
          publisherInitTimes: groupedPublisherInitCollectors.map((collector) =>
            this.toRuntimeStatisticsTime(runtime, collector.runtimeKeys, collector.label),
          ),
          moduleInitTimes: groupedModuleInitCollectors.map((collector) =>
            this.toRuntimeStatisticsTime(runtime, collector.runtimeKeys, collector.label),
          ),
        }
      : {
          publisherInitTimes: legacyPublisherCollectors.map((collector) =>
            this.toRuntimeStatisticsTime(runtime, ['StatePublisher.' + collector + '.initialize'], collector),
          ),
          moduleInitTimes: legacyCeModules.map((moduleName) =>
            this.toRuntimeStatisticsTime(runtime, ['CeModule.' + moduleName + '.init'], moduleName),
          ),
        };

    const nextSample: RuntimeStatisticsSample = {
      eventCounter,
      publisherSyncTimes: legacyPublisherCollectors.map((collector) =>
        this.toRuntimeStatisticsTime(runtime, ['StatePublisher.' + collector + '.syncState'], collector),
      ),
      moduleRunTimes: usesGroupedRuntimeStatistics
        ? groupedModuleCollectors.map((collector) =>
            this.toRuntimeStatisticsTime(runtime, collector.runtimeKeys, collector.label),
          )
        : legacyCeModules.map((moduleName) =>
            this.toRuntimeStatisticsTime(runtime, ['CeModule.' + moduleName + '.run'], moduleName),
          ),
      updateTimes: usesGroupedRuntimeStatistics
        ? groupedPublisherCollectors.map((collector) =>
            this.toRuntimeStatisticsTime(runtime, collector.runtimeKeys, collector.label),
          )
        : [],
      controllerUpdateTimes: [
        this.toRuntimeStatisticsTime(
          runtime,
          ['MainLoopRunner.runCycle-6-waitForServer'],
          'Wait for server to be ready',
        ),
        this.toRuntimeStatisticsTime(runtime, ['MainLoopRunner.runCycle-5-commands'], 'Command execution'),
        this.toRuntimeStatisticsTime(runtime, ['MainLoopRunner.runCycle-7-serverOutput'], 'Server output'),
        this.toRuntimeStatisticsTime(runtime, ['MainLoopRunner.runCycle-8-dataStoreWrite'], 'DataStore write'),
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
    runtimeKeys: string[],
    label: string,
  ): RuntimeStatisticsTimeDto {
    const runtimeEntry = runtimeKeys.map((runtimeKey) => runtime[runtimeKey]).find((entry) => entry !== undefined);
    return {
      id: label,
      ms: runtimeEntry?.time ?? 0,
    };
  }

  private runtimeStatisticsSampleEquals(left: RuntimeStatisticsSample, right: RuntimeStatisticsSample): boolean {
    return (
      this.runtimeStatisticsTimeListsEqual(left.publisherSyncTimes, right.publisherSyncTimes) &&
      this.runtimeStatisticsTimeListsEqual(left.moduleRunTimes, right.moduleRunTimes) &&
      this.runtimeStatisticsTimeListsEqual(left.updateTimes, right.updateTimes) &&
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
      updateTimes: this.runtimeStatisticsHistory.map((sample) =>
        this.cloneRuntimeStatisticsTimeList(sample.updateTimes),
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
  getStructure = (id: string): StructureDto | undefined => this.structures[id];
  getTracksForRoom = (trackType: string): Record<string, TrackDto> => this.tracks[trackType] ?? {};
  getTrackRoomNames = (): string[] => Object.keys(this.tracks);
}
