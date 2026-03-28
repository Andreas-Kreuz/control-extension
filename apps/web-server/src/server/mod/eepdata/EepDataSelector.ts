import { RuntimeLuaDto } from '../../ce/dto/runtime/RuntimeLuaDto';
import { ModuleLuaDto } from '../../ce/dto/modules/ModuleLuaDto';
import { DataSlotLuaDto } from '../../ce/dto/data-slots/DataSlotLuaDto';
import { SignalLuaDto } from '../../ce/dto/signals/SignalLuaDto';
import { WaitingOnSignalLuaDto } from '../../ce/dto/signals/WaitingOnSignalLuaDto';
import { SwitchLuaDto } from '../../ce/dto/switches/SwitchLuaDto';
import { StructureLuaDto } from '../../ce/dto/structures/StructureLuaDto';
import { TrackLuaDto } from '../../ce/dto/tracks/TrackLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  RuntimeDto,
  ModuleDto,
  DataSlotDto,
  SignalDto,
  WaitingOnSignalDto,
  SwitchDto,
  StructureDto,
  TrackDto,
  trackTypeForCeType,
} from '@ak/web-shared';

export default class EepDataSelector {
  private lastState: fromEepData.State = undefined;
  private runtime: Record<string, RuntimeDto> = {};
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

  getRuntime = (): Record<string, RuntimeDto> => this.runtime;
  getModules = (): Record<string, ModuleDto> => this.modules;
  getSaveSlots = (): Record<string, DataSlotDto> => this.saveSlots;
  getFreeSlots = (): Record<string, DataSlotDto> => this.freeSlots;
  getSignals = (): Record<string, SignalDto> => this.signals;
  getWaitingOnSignals = (): Record<string, WaitingOnSignalDto> => this.waitingOnSignals;
  getSwitches = (): Record<string, SwitchDto> => this.switches;
  getStructures = (): Record<string, StructureDto> => this.structures;
  getTracksForRoom = (trackType: string): Record<string, TrackDto> => this.tracks[trackType] ?? {};
  getTrackRoomNames = (): string[] => Object.keys(this.tracks);
}
