// Lua DtoFactory: lua/LUA/ce/hub/data/version/VersionDtoFactory.lua
// Room: eep-version
export interface VersionLuaDto {
  id: string;
  name: string;
  eepVersion: string;
  luaVersion: string;
  singleVersion: string;
  eepLanguage?: string;
  layoutVersion?: number;
  layoutLanguage?: string;
  layoutName?: string;
  layoutPath?: string;
}
