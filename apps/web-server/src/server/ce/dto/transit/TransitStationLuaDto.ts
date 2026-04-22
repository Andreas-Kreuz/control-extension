import { TransitStationAppDto } from '@ce/web-shared';

export interface TransitStationLuaDto {
  id: string;
  name?: TransitStationAppDto['name'];
  platforms?: TransitStationAppDto['platforms'];
  queue?: TransitStationAppDto['queue'];
}
