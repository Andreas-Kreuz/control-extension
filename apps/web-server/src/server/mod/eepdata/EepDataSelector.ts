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
  RuntimeDto,
  ModuleDto,
  DataSlotDto,
  SignalDto,
  WaitingOnSignalDto,
  SwitchDto,
  StructureDto,
  TrackDto,
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

    this.runtime = this.mapRoom<RuntimeLuaDto, RuntimeDto>(state, 'runtime', (dto) => ({
      id: dto.id,
      count: dto.count,
      time: dto.time,
      lastTime: dto.lastTime,
    }));

    this.modules = this.mapRoom<ModuleLuaDto, ModuleDto>(state, 'modules', (dto) => ({
      id: dto.id,
      name: dto.name,
      enabled: dto.enabled,
    }));

    this.saveSlots = this.mapRoom<DataSlotLuaDto, DataSlotDto>(state, 'save-slots', (dto) => ({
      id: dto.id,
      name: dto.name,
      data: dto.data,
    }));

    this.freeSlots = this.mapRoom<DataSlotLuaDto, DataSlotDto>(state, 'free-slots', (dto) => ({
      id: dto.id,
      name: dto.name,
      data: dto.data,
    }));

    this.signals = this.mapRoom<SignalLuaDto, SignalDto>(state, 'signals', (dto) => ({
      id: dto.id,
      position: dto.position,
      tag: dto.tag,
      waitingVehiclesCount: dto.waitingVehiclesCount,
    }));

    this.waitingOnSignals = this.mapRoom<WaitingOnSignalLuaDto, WaitingOnSignalDto>(
      state,
      'waiting-on-signals',
      (dto) => ({
        id: dto.id,
        signalId: dto.signalId,
        waitingPosition: dto.waitingPosition,
        vehicleName: dto.vehicleName,
        waitingCount: dto.waitingCount,
      }),
    );

    this.switches = this.mapRoom<SwitchLuaDto, SwitchDto>(state, 'switches', (dto) => ({
      id: dto.id,
      position: dto.position,
      tag: dto.tag,
    }));

    this.structures = this.mapRoom<StructureLuaDto, StructureDto>(state, 'structures', (dto) => ({
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

    // Tracks: dynamic room names like "rail-tracks", "road-tracks", etc.
    this.tracks = {};
    for (const roomName of Object.keys(state.rooms)) {
      if (roomName.endsWith('-tracks')) {
        this.tracks[roomName] = this.mapRoom<TrackLuaDto, TrackDto>(state, roomName, (dto) => ({
          id: dto.id,
        }));
      }
    }
  }

  private mapRoom<TLua, TDto>(
    state: fromEepData.State,
    roomName: string,
    mapper: (dto: TLua) => TDto,
  ): Record<string, TDto> {
    if (!state.rooms[roomName]) return {};
    const dict = state.rooms[roomName] as unknown as Record<string, TLua>;
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
  getTracksForRoom = (roomName: string): Record<string, TrackDto> => this.tracks[roomName] ?? {};
  getTrackRoomNames = (): string[] => Object.keys(this.tracks);
}
