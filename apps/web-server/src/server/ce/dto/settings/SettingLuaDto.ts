// Lua DtoFactory: lua/LUA/ce/mods/road/data/RoadDtoFactory.lua (road-module-settings)
//               : lua/LUA/ce/mods/transit/data/TransitDtoFactory.lua (transit-module-settings)
// Rooms: road-module-settings, transit-module-settings
export interface SettingLuaDto<T> {
  name: string;
  category: string;
  description: string;
  eepFunction: string;
  type: string;
  value: T;
}
