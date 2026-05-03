// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSettingsSelector.ts
// apps/web-server/src/server/mod/road/RoadSelector.ts
import { SettingAppDto } from './SettingAppDto';

export interface SettingsAppDto {
  moduleName: string;
  settings: SettingAppDto<unknown>[];
}
