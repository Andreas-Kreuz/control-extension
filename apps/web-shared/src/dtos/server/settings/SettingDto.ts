// Produced by: web-server/src/server/mod/transit/TransitSettingsSelector.ts
//            : web-server/src/server/mod/road/RoadSettingsSelector.ts (future)
export interface SettingDto<T> {
  category: string;
  name: string;
  description: string;
  type: string;
  value: T;
  eepFunction: string;
}
