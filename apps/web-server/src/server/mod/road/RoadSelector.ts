import { IntersectionLuaDto } from '../../ce/dto/roads/IntersectionLuaDto';
import { IntersectionLaneLuaDto } from '../../ce/dto/roads/IntersectionLaneLuaDto';
import { IntersectionSwitchingLuaDto } from '../../ce/dto/roads/IntersectionSwitchingLuaDto';
import { IntersectionTrafficLightLuaDto } from '../../ce/dto/roads/IntersectionTrafficLightLuaDto';
import { SettingLuaDto } from '../../ce/dto/settings/SettingLuaDto';
import { TrafficLightModelLuaDto } from '../../ce/dto/traffic-light-models/TrafficLightModelLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  IntersectionDto,
  IntersectionLaneDto,
  IntersectionSwitchingDto,
  IntersectionTrafficLightDto,
  SettingDto,
  TrafficLightModelDto,
} from '@ce/web-shared';

export default class RoadSelector {
  private lastState?: fromEepData.State;
  private intersections: Record<string, IntersectionDto> = {};
  private intersectionLanes: Record<string, IntersectionLaneDto> = {};
  private intersectionSwitchings: Record<string, IntersectionSwitchingDto> = {};
  private intersectionTrafficLights: Record<string, IntersectionTrafficLightDto> = {};
  private trafficLightModels: Record<string, TrafficLightModelDto> = {};
  private moduleSettings: Record<string, SettingDto<unknown>> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    this.intersections = this.mapCeType<IntersectionLuaDto, IntersectionDto>(
      state,
      CeTypes.RoadIntersection,
      (dto) => ({
        id: dto.id,
        name: dto.name,
        currentSwitching: dto.currentSwitching,
        manualSwitching: dto.manualSwitching,
        nextSwitching: dto.nextSwitching,
        ready: dto.ready,
        timeForGreen: dto.timeForGreen,
        staticCams: dto.staticCams ?? [],
      }),
    );

    this.intersectionLanes = this.mapCeType<IntersectionLaneLuaDto, IntersectionLaneDto>(
      state,
      CeTypes.RoadIntersectionLane,
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

    this.intersectionSwitchings = this.mapCeType<IntersectionSwitchingLuaDto, IntersectionSwitchingDto>(
      state,
      CeTypes.RoadIntersectionSwitching,
      (dto) => ({
        id: dto.id,
        intersectionId: dto.intersectionId,
        name: dto.name,
        prio: dto.prio,
      }),
    );

    this.intersectionTrafficLights = this.mapCeType<IntersectionTrafficLightLuaDto, IntersectionTrafficLightDto>(
      state,
      CeTypes.RoadIntersectionTrafficLight,
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

    this.trafficLightModels = this.mapCeType<TrafficLightModelLuaDto, TrafficLightModelDto>(
      state,
      CeTypes.RoadSignalTypeDefinition,
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

    this.moduleSettings = {};
    if (state.ceTypes[CeTypes.RoadModuleSetting]) {
      const dict = state.ceTypes[CeTypes.RoadModuleSetting] as unknown as Record<string, SettingLuaDto<unknown>>;
      Object.values(dict).forEach((dto) => {
        this.moduleSettings[dto.name] = {
          name: dto.name,
          category: dto.category,
          description: dto.description,
          eepFunction: dto.eepFunction,
          type: dto.type,
          value: dto.value,
        };
      });
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
      result[String((mapped as { id: string | number }).id)] = mapped;
    });
    return result;
  }

  getIntersections = (): Record<string, IntersectionDto> => this.intersections;
  getIntersectionLanes = (): Record<string, IntersectionLaneDto> => this.intersectionLanes;
  getIntersectionSwitchings = (): Record<string, IntersectionSwitchingDto> => this.intersectionSwitchings;
  getIntersectionSwitching = (id: string): IntersectionSwitchingDto | undefined => this.intersectionSwitchings[id];
  getIntersectionTrafficLights = (): Record<string, IntersectionTrafficLightDto> => this.intersectionTrafficLights;
  getIntersectionTrafficLight = (id: string): IntersectionTrafficLightDto | undefined => this.intersectionTrafficLights[id];
  getIntersection = (id: string): IntersectionDto | undefined => this.intersections[id];
  getIntersectionLane = (id: string): IntersectionLaneDto | undefined => this.intersectionLanes[id];
  getTrafficLightModels = (): Record<string, TrafficLightModelDto> => this.trafficLightModels;
  getTrafficLightModel = (id: string): TrafficLightModelDto | undefined => this.trafficLightModels[id];
  getModuleSettings = (): Record<string, SettingDto<unknown>> => this.moduleSettings;
  getModuleSetting = (id: string): SettingDto<unknown> | undefined => this.moduleSettings[id];
}
