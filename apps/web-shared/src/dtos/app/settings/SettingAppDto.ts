// App contract populated by:
// apps/web-server/src/server/mod/transit/TransitSettingsSelector.ts
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface SettingAppDto<T> {
  category: string;
  name: string;
  description: string;
  type: string;
  value: T;
  eepFunction: string;
}
