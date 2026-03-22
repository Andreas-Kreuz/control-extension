// Produced by: web-server/src/server/mod/transit/TransitSettingsSelector.ts
//            : web-server/src/server/mod/road/RoadSettingsSelector.ts (future)
import { SettingDto } from './SettingDto';

export interface SettingsDto {
  moduleName: string;
  settings: SettingDto<unknown>[];
}
