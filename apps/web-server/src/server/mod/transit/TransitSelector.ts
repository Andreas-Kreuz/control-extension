import { TransitLineLuaDto } from '../../ce/dto/transit/TransitLineLuaDto';
import { TransitStationLuaDto } from '../../ce/dto/transit/TransitStationLuaDto';
import * as fromEepData from '../../eep/server-data/EepDataStore';
import { CeTypes, TransitLineDto, TransitStationDto } from '@ak/web-shared';

export default class TransitSelector {
  private lastState: fromEepData.State = undefined;
  private transitLines: Record<string, TransitLineDto> = {};
  private transitStations: Record<string, TransitStationDto> = {};

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    if (state.ceTypes[CeTypes.TransitLine]) {
      const dict = state.ceTypes[CeTypes.TransitLine] as unknown as Record<string, TransitLineLuaDto>;
      this.transitLines = {};
      Object.values(dict).forEach((dto: TransitLineLuaDto) => {
        this.transitLines[dto.id] = {
          id: dto.id,
          nr: dto.nr,
          trafficType: dto.trafficType,
          lineSegments: (dto.lineSegments ?? []).map((seg) => ({
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
      });
    }

    if (state.ceTypes[CeTypes.TransitStation]) {
      const dict = state.ceTypes[CeTypes.TransitStation] as unknown as Record<string, TransitStationLuaDto>;
      this.transitStations = {};
      Object.values(dict).forEach((dto: TransitStationLuaDto) => {
        this.transitStations[dto.id] = { id: dto.id };
      });
    }
  }

  getTransitLines = (): Record<string, TransitLineDto> => this.transitLines;
  getTransitStations = (): Record<string, TransitStationDto> => this.transitStations;
}
