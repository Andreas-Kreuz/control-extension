import { TransitLineLuaDto } from '../../ce/dto/transit/TransitLineLuaDto';
import { TransitStationLuaDto } from '../../ce/dto/transit/TransitStationLuaDto';
import { TransitTrainLuaDto } from '../../ce/dto/transit/TransitTrainLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, TransitLineDto, TransitStationDto } from '@ce/web-shared';

export default class TransitSelector {
  private lastState?: fromEepData.State;
  private transitLines: Record<string, TransitLineDto> = {};
  private transitLineNames: Record<string, TransitLineDto> = {};
  private transitStations: Record<string, TransitStationDto> = {};
  private transitTrains: Record<string, TransitTrainLuaDto> = {};

  private mapLineDto(line: TransitLineLuaDto): TransitLineDto {
    return {
      id: line.id,
      nr: line.nr,
      trafficType: line.trafficType,
      lineSegments: (line.lineSegments ?? []).map((seg) => ({
        id: seg.id,
        destination: seg.destination,
        routeName: seg.routeName,
        lineNr: seg.lineNr,
        stations: (seg.stations ?? []).map((st) => ({
          name: st.name,
          timeToStation: st.timeToStation,
        })),
      })),
    };
  }

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    if (state.ceTypes[CeTypes.TransitLine]) {
      const dict = state.ceTypes[CeTypes.TransitLine] as unknown as Record<string, TransitLineLuaDto>;
      this.transitLines = {};
      Object.values(dict).forEach((dto: TransitLineLuaDto) => {
        this.transitLines[dto.id] = this.mapLineDto(dto);
      });
    }

    if (state.ceTypes[CeTypes.TransitLineName]) {
      const dict = state.ceTypes[CeTypes.TransitLineName] as unknown as Record<string, TransitLineLuaDto>;
      this.transitLineNames = {};
      Object.values(dict).forEach((dto: TransitLineLuaDto) => {
        this.transitLineNames[dto.id] = this.mapLineDto(dto);
      });
    }

    if (state.ceTypes[CeTypes.TransitStation]) {
      const dict = state.ceTypes[CeTypes.TransitStation] as unknown as Record<string, TransitStationLuaDto>;
      this.transitStations = {};
      Object.values(dict).forEach((dto: TransitStationLuaDto) => {
        this.transitStations[dto.id] = {
          id: dto.id,
          ...(dto.name !== undefined ? { name: dto.name } : {}),
          ...(dto.platforms !== undefined
            ? {
                platforms: dto.platforms.map((platform) => ({
                  nr: platform.nr,
                  routes: [...platform.routes],
                })),
              }
            : {}),
          ...(dto.queue !== undefined
            ? {
                queue: dto.queue.map((entry) => ({
                  trainName: entry.trainName,
                  line: entry.line,
                  destination: entry.destination,
                  timeInMinutes: entry.timeInMinutes,
                  platform: entry.platform,
                })),
              }
            : {}),
        };
      });
    }

    if (state.ceTypes[CeTypes.TransitTrain]) {
      const dict = state.ceTypes[CeTypes.TransitTrain] as unknown as Record<string, TransitTrainLuaDto>;
      this.transitTrains = {};
      Object.values(dict).forEach((dto: TransitTrainLuaDto) => {
        this.transitTrains[dto.id] = {
          id: dto.id,
          ...(dto.line !== undefined ? { line: dto.line } : {}),
          ...(dto.destination !== undefined ? { destination: dto.destination } : {}),
          ...(dto.direction !== undefined ? { direction: dto.direction } : {}),
        };
      });
    }
  }

  getTransitLines = (): Record<string, TransitLineDto> => this.transitLines;
  getTransitLine = (id: string): TransitLineDto | undefined => this.transitLines[id];
  getTransitLineNames = (): Record<string, TransitLineDto> => this.transitLineNames;
  getTransitLineName = (id: string): TransitLineDto | undefined => this.transitLineNames[id];
  getTransitStations = (): Record<string, TransitStationDto> => this.transitStations;
  getTransitStation = (id: string): TransitStationDto | undefined => this.transitStations[id];
  getTransitTrains = (): Record<string, TransitTrainLuaDto> => this.transitTrains;
  getTransitTrain = (id: string): TransitTrainLuaDto | undefined => this.transitTrains[id];
}
