import { IntersectionLuaDto } from '../../ce/dto/roads/IntersectionLuaDto';
import { IntersectionLaneLuaDto } from '../../ce/dto/roads/IntersectionLaneLuaDto';
import { IntersectionSwitchingLuaDto } from '../../ce/dto/roads/IntersectionSwitchingLuaDto';
import { IntersectionTrafficLightLuaDto } from '../../ce/dto/roads/IntersectionTrafficLightLuaDto';
import { SettingLuaDto } from '../../ce/dto/settings/SettingLuaDto';
import { TrafficLightModelLuaDto } from '../../ce/dto/traffic-light-models/TrafficLightModelLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  IntersectionAppDto,
  IntersectionLaneAppDto,
  IntersectionSwitchingAppDto,
  IntersectionTrafficLightAppDto,
  SettingAppDto,
  SettingsAppDto,
  TrafficLightModelAppDto,
} from '@ce/web-shared';

// Maps Lua road DTOs into road AppDtos and road setting AppDtos.
// Lua inputs: ce.mods.road.Intersection, lanes, switchings, lights, settings.
export default class RoadSelector {
  private lastState?: fromEepData.State;
  private intersections: Record<string, IntersectionAppDto> = {};
  private intersectionLanes: Record<string, IntersectionLaneAppDto> = {};
  private intersectionSwitchings: Record<string, IntersectionSwitchingAppDto> = {};
  private intersectionTrafficLights: Record<string, IntersectionTrafficLightAppDto> = {};
  private trafficLightModels: Record<string, TrafficLightModelAppDto> = {};
  private moduleSettings: SettingsAppDto = { moduleName: 'Einstellungen für Kreuzungen', settings: [] };

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    this.intersections = this.mapCeType<IntersectionLuaDto, IntersectionAppDto>(
      state,
      CeTypes.RoadIntersection,
      (dto) => ({
        id: dto.id,
        name: dto.name ?? '',
        currentSwitching: dto.currentSwitching ?? '',
        manualSwitching: dto.manualSwitching ?? '',
        nextSwitching: dto.nextSwitching ?? '',
        ready: dto.ready ?? false,
        timeForGreen: dto.timeForGreen ?? 0,
        staticCams: dto.staticCams ?? [],
        phases: dto.phases ?? [],
      }),
    );

    this.intersectionLanes = this.mapCeType<IntersectionLaneLuaDto, IntersectionLaneAppDto>(
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

    this.intersectionSwitchings = this.mapCeType<IntersectionSwitchingLuaDto, IntersectionSwitchingAppDto>(
      state,
      CeTypes.RoadIntersectionSwitching,
      (dto) => ({
        id: dto.id,
        intersectionId: dto.intersectionId,
        name: dto.name,
        prio: dto.prio,
      }),
    );

    this.intersectionTrafficLights = this.mapCeType<IntersectionTrafficLightLuaDto, IntersectionTrafficLightAppDto>(
      state,
      CeTypes.RoadIntersectionTrafficLight,
      (dto) => ({
        id: dto.id,
        signalId: dto.signalId,
        ...(dto.trafficSignalName !== undefined ? { trafficSignalName: dto.trafficSignalName } : {}),
        ...(dto.pedestrianSignalName !== undefined ? { pedestrianSignalName: dto.pedestrianSignalName } : {}),
        use: dto.use,
        modelId: dto.modelId,
        currentPhase: dto.currentPhase,
        intersectionId: dto.intersectionId,
        lightStructures: dto.lightStructures,
        axisStructures: dto.axisStructures,
      }),
    );

    this.trafficLightModels = this.mapCeType<TrafficLightModelLuaDto, TrafficLightModelAppDto>(
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

    this.moduleSettings = { moduleName: 'Einstellungen für Kreuzungen', settings: [] };
    if (state.ceTypes[CeTypes.RoadModuleSetting]) {
      const dict = state.ceTypes[CeTypes.RoadModuleSetting] as unknown as Record<string, SettingLuaDto<unknown>>;
      Object.values(dict).forEach((dto) => {
        this.moduleSettings.settings.push({
          name: dto.name,
          category: dto.category,
          description: dto.description,
          eepFunction: dto.eepFunction,
          type: dto.type,
          value: dto.value,
        });
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

  getIntersections = (): Record<string, IntersectionAppDto> => this.intersections;
  getIntersectionLanes = (): Record<string, IntersectionLaneAppDto> => this.intersectionLanes;
  getIntersectionSwitchings = (): Record<string, IntersectionSwitchingAppDto> => this.intersectionSwitchings;
  getIntersectionSwitching = (id: string): IntersectionSwitchingAppDto | undefined => this.intersectionSwitchings[id];
  getIntersectionTrafficLights = (): Record<string, IntersectionTrafficLightAppDto> => this.intersectionTrafficLights;
  getIntersectionTrafficLight = (id: string): IntersectionTrafficLightAppDto | undefined =>
    this.intersectionTrafficLights[id];
  getIntersection = (id: string): IntersectionAppDto | undefined => this.intersections[id];
  getIntersectionLane = (id: string): IntersectionLaneAppDto | undefined => this.intersectionLanes[id];
  getTrafficLightModels = (): Record<string, TrafficLightModelAppDto> => this.trafficLightModels;
  getTrafficLightModel = (id: string): TrafficLightModelAppDto | undefined => this.trafficLightModels[id];
  getModuleSettings = (): SettingsAppDto => this.moduleSettings;
  getModuleSetting = (id: string): SettingAppDto<unknown> | undefined =>
    this.moduleSettings.settings.find((setting) => setting.name === id);
}
