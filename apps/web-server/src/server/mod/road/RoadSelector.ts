import { IntersectionLuaDto } from '../../ce/dto/roads/IntersectionLuaDto';
import { IntersectionLaneLuaDto } from '../../ce/dto/roads/IntersectionLaneLuaDto';
import { IntersectionPhaseLuaDto } from '../../ce/dto/roads/IntersectionPhaseLuaDto';
import { IntersectionTrafficLightLuaDto } from '../../ce/dto/roads/IntersectionTrafficLightLuaDto';
import { SettingLuaDto } from '../../ce/dto/settings/SettingLuaDto';
import { TrafficLightModelLuaDto } from '../../ce/dto/traffic-light-models/TrafficLightModelLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  CeTypes,
  IntersectionAppDto,
  IntersectionLaneAppDto,
  IntersectionPhaseAppDto,
  IntersectionTrafficLightAppDto,
  SettingAppDto,
  SettingsAppDto,
  TrafficLightModelAppDto,
} from '@ce/web-shared';

const knownTrafficLightModelConstants: Record<string, string> = {
  MA1_STRAB_4er_2_gruen: 'MA1_STRAB_4er_2_gruen',
  MA1_STRAB_4er_3_gruen: 'MA1_STRAB_4er_3_gruen',
  MA1_STRAB_3er_2_gruen: 'MA1_STRAB_3er_2_gruen',
  Ampel_NP1_mit_FG: 'NP1_3er_mit_FG',
  Ampel_NP1_ohne_FG: 'NP1_3er_ohne_FG',
  Ak_Ampel_2er_nur_FG: 'JS2_2er_nur_FG',
  'Ampel_2er_Aus_Gelb-Grün': 'JS2_2er_gelb_gruen_aus',
  Ampel_2er_Aus_Gelb_Gruen: 'JS2_2er_gelb_gruen_aus',
  Ampel_2er_Aus_Gelb_Grun: 'JS2_2er_gelb_gruen_aus',
  Ampel_2er_Rot_Gelb_Aus: 'JS2_2er_rot_gelb_aus',
  Ampel_2er_Rot_Gruen: 'JS2_2er_rot_gruen',
  Ampel_1er_Gruen: 'JS2_1er_gruen',
  Ampel_3er_XXX_mit_FG: 'JS2_3er_mit_FG',
  Ampel_3er_XXX_ohne_FG: 'JS2_3er_ohne_FG',
  'JS2 3er-Ampel mit Fußgängern': 'JS2_3er_mit_FG',
  'JS2 3er-Ampel mit Fussgängern': 'JS2_3er_mit_FG',
  'JS2 3er-Ampel mit Fussgaengern': 'JS2_3er_mit_FG',
  'JS2 3er-Ampel ohne Fußgänger': 'JS2_3er_ohne_FG',
  'JS2 3er-Ampel ohne Fussgänger': 'JS2_3er_ohne_FG',
  'JS2 3er-Ampel ohne Fussgaenger': 'JS2_3er_ohne_FG',
  'Unsichtbares Signal': 'Unsichtbar_2er',
  Unsichtbares_Signal: 'Unsichtbar_2er',
  'NO SIGNAL MODEL': 'NONE',
  NO_SIGNAL_MODEL: 'NONE',
};

const oppositeApproach: Record<string, string> = {
  NORTH: 'SOUTH',
  NORTH_EAST: 'SOUTH_WEST',
  EAST: 'WEST',
  SOUTH_EAST: 'NORTH_WEST',
  SOUTH: 'NORTH',
  SOUTH_WEST: 'NORTH_EAST',
  WEST: 'EAST',
  NORTH_WEST: 'SOUTH_EAST',
};

function approachFromDto(approach: string | undefined, legacyHeading?: string): string | undefined {
  if (approach !== undefined) return approach;
  return legacyHeading !== undefined ? oppositeApproach[legacyHeading] : undefined;
}

export function trafficLightModelConstantForName(modelName: string | undefined): string | undefined {
  if (!modelName) return undefined;
  if (knownTrafficLightModelConstants[modelName]) return knownTrafficLightModelConstants[modelName];
  const found = Object.entries(knownTrafficLightModelConstants).find(([name]) =>
    modelName.toLocaleLowerCase().includes(name.toLocaleLowerCase()),
  );
  return found?.[1];
}

// Maps Lua road DTOs into road AppDtos and road setting AppDtos.
// Lua inputs: ce.mods.road.Intersection, lanes, phases, signal heads, settings.
export default class RoadSelector {
  private lastState?: fromEepData.State;
  private intersections: Record<string, IntersectionAppDto> = {};
  private intersectionLanes: Record<string, IntersectionLaneAppDto> = {};
  private intersectionPhases: Record<string, IntersectionPhaseAppDto> = {};
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
        eepSaveId: dto.eepSaveId ?? -1,
        ...(dto.scriptVariableName !== undefined ? { scriptVariableName: dto.scriptVariableName } : {}),
        switchInStrictOrder: dto.switchInStrictOrder ?? false,
        currentPhase: dto.currentPhase ?? '',
        manualPhase: dto.manualPhase ?? '',
        nextPhase: dto.nextPhase ?? '',
        ready: dto.ready ?? false,
        greenTimeSeconds: dto.greenTimeSeconds ?? 0,
        ...(dto.tippStructure !== undefined ? { tippStructure: dto.tippStructure } : {}),
        staticCams: dto.staticCams ?? [],
        phases: (dto.phases ?? []).map((phase) => ({
          ...phase,
          signalGroups: phase.signalGroups ?? [],
        })),
        signalGroupDefinitions: dto.signalGroupDefinitions ?? [],
        ...(dto.pedestrianCrossings !== undefined
          ? {
              pedestrianCrossings: dto.pedestrianCrossings.map((crossing) => ({
                ...crossing,
                approach: approachFromDto(crossing.approach, crossing.heading) ?? 'SOUTH',
              })),
            }
          : {}),
      }),
    );

    this.intersectionLanes = this.mapCeType<IntersectionLaneLuaDto, IntersectionLaneAppDto>(
      state,
      CeTypes.RoadIntersectionLane,
      (dto) => {
        const approach = approachFromDto(dto.approach, dto.heading);
        return {
          id: dto.id,
          intersectionId: dto.intersectionId,
          name: dto.name,
          ...(dto.kpId !== undefined ? { kpId: dto.kpId } : {}),
          ...(dto.scriptVariableName !== undefined ? { scriptVariableName: dto.scriptVariableName } : {}),
          currentIndication: dto.currentIndication,
          vehicleMultiplier: dto.vehicleMultiplier,
          ...(dto.laneSignalId !== undefined ? { laneSignalId: dto.laneSignalId } : {}),
          type: dto.type,
          countType: dto.countType,
          waitingTrains: dto.waitingTrains,
          waitingForGreenCyclesCount: dto.waitingForGreenCyclesCount,
          ...(approach !== undefined ? { approach } : {}),
          ...(dto.heading !== undefined ? { heading: dto.heading } : {}),
          directions: dto.directions,
          phases: dto.phases,
          defaultSignalGroups: dto.defaultSignalGroups ?? [],
          routeRules: dto.routeRules ?? [],
          defaultRequestSignalGroups: dto.defaultRequestSignalGroups ?? [],
          requestTrackIds: dto.requestTrackIds ?? [],
          highlightTrackIds: dto.highlightTrackIds ?? dto.tracks,
          tracks: dto.tracks,
        };
      },
    );

    this.intersectionPhases = this.mapCeType<IntersectionPhaseLuaDto, IntersectionPhaseAppDto>(
      state,
      CeTypes.RoadIntersectionPhase,
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
        ...(dto.vehicleSignalName !== undefined ? { vehicleSignalName: dto.vehicleSignalName } : {}),
        ...(dto.pedestrianSignalName !== undefined ? { pedestrianSignalName: dto.pedestrianSignalName } : {}),
        use: dto.use,
        modelId: dto.modelId,
        currentIndication: dto.currentIndication,
        intersectionId: dto.intersectionId,
        lightStructures: dto.lightStructures,
        axisStructures: dto.axisStructures,
      }),
    );

    this.trafficLightModels = this.mapCeType<TrafficLightModelLuaDto, TrafficLightModelAppDto>(
      state,
      CeTypes.RoadTrafficLightModel,
      (dto) => {
        return {
          id: dto.id,
          name: dto.name,
          type: dto.type,
          luaConstant: dto.id,
          positionRed: dto.positionRed,
          positionGreen: dto.positionGreen,
          positionYellow: dto.positionYellow,
          positionRedYellow: dto.positionRedYellow,
          positionPedestrians: dto.positionPedestrians,
          positionOff: dto.positionOff,
          positionOffBlinking: dto.positionOffBlinking,
        };
      },
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
  getIntersectionPhases = (): Record<string, IntersectionPhaseAppDto> => this.intersectionPhases;
  getIntersectionPhase = (id: string): IntersectionPhaseAppDto | undefined => this.intersectionPhases[id];
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
