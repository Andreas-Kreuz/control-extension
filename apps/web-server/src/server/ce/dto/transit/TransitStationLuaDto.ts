import { TransitStationDto } from '@ce/web-shared';

export interface TransitStationLuaDto {
  id: string;
  name?: TransitStationDto['name'];
  platforms?: TransitStationDto['platforms'];
  queue?: TransitStationDto['queue'];
}
