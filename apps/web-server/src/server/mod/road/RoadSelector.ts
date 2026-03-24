import { IntersectionLuaDto } from '../../ce/dto/roads/IntersectionLuaDto';
import { IntersectionLaneLuaDto } from '../../ce/dto/roads/IntersectionLaneLuaDto';
import { IntersectionSwitchingLuaDto } from '../../ce/dto/roads/IntersectionSwitchingLuaDto';
import { IntersectionTrafficLightLuaDto } from '../../ce/dto/roads/IntersectionTrafficLightLuaDto';
import { TrafficLightModelLuaDto } from '../../ce/dto/traffic-light-models/TrafficLightModelLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  IntersectionDto,
  IntersectionLaneDto,
  IntersectionSwitchingDto,
  IntersectionTrafficLightDto,
  TrafficLightModelDto,
} from '@ak/web-shared';

export default class RoadSelector {
  private lastState: fromEepData.State = undefined;
  private intersections: Record<string, IntersectionDto> = {};
  private intersectionLanes: Record<string, IntersectionLaneDto> = {};
  private intersectionSwitchings: Record<string, IntersectionSwitchingDto> = {};
  private intersectionTrafficLights: Record<string, IntersectionTrafficLightDto> = {};
  private trafficLightModels: Record<string, TrafficLightModelDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    this.intersections = this.mapRoom<IntersectionLuaDto, IntersectionDto>(state, 'intersections', (dto) => ({
      id: dto.id,
      name: dto.name,
      currentSwitching: dto.currentSwitching,
      manualSwitching: dto.manualSwitching,
      nextSwitching: dto.nextSwitching,
      ready: dto.ready,
      timeForGreen: dto.timeForGreen,
      staticCams: dto.staticCams,
    }));

    this.intersectionLanes = this.mapRoom<IntersectionLaneLuaDto, IntersectionLaneDto>(
      state,
      'intersection-lanes',
      (dto) => ({
        id: dto.id,
        intersectionId: dto.intersectionId,
        name: dto.name,
        phase: dto.phase,
        vehicleMultiplier: dto.vehicleMultiplier,
        eepSaveId: dto.eepSaveId,
        type: dto.type,
        countType: dto.countType,
        waitingTrains: dto.waitingTrains,
        waitingForGreenCyclesCount: dto.waitingForGreenCyclesCount,
        directions: dto.directions,
        switchings: dto.switchings,
        tracks: dto.tracks,
      }),
    );

    this.intersectionSwitchings = this.mapRoom<IntersectionSwitchingLuaDto, IntersectionSwitchingDto>(
      state,
      'intersection-switchings',
      (dto) => ({
        id: dto.id,
        intersectionId: dto.intersectionId,
        name: dto.name,
        prio: dto.prio,
      }),
    );

    this.intersectionTrafficLights = this.mapRoom<IntersectionTrafficLightLuaDto, IntersectionTrafficLightDto>(
      state,
      'intersection-traffic-lights',
      (dto) => ({
        id: dto.id,
        signalId: dto.signalId,
        modelId: dto.modelId,
        currentPhase: dto.currentPhase,
        intersectionId: dto.intersectionId,
        lightStructures: dto.lightStructures,
        axisStructures: dto.axisStructures,
      }),
    );

    this.trafficLightModels = this.mapRoom<TrafficLightModelLuaDto, TrafficLightModelDto>(
      state,
      'signal-type-definitions',
      (dto) => ({
        id: dto.id,
        name: dto.name,
        type: dto.type,
        positionRed: dto.positionRed,
        positionGreen: dto.positionGreen,
        positionYellow: dto.positionYellow,
        positionRedYellow: dto.positionRedYellow,
        positionPedestrians: dto.positionPedestrians,
        positionOff: dto.positionOff,
        positionOffBlinking: dto.positionOffBlinking,
      }),
    );
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

  getIntersections = (): Record<string, IntersectionDto> => this.intersections;
  getIntersectionLanes = (): Record<string, IntersectionLaneDto> => this.intersectionLanes;
  getIntersectionSwitchings = (): Record<string, IntersectionSwitchingDto> => this.intersectionSwitchings;
  getIntersectionTrafficLights = (): Record<string, IntersectionTrafficLightDto> => this.intersectionTrafficLights;
  getTrafficLightModels = (): Record<string, TrafficLightModelDto> => this.trafficLightModels;
}
