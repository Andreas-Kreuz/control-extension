// Lua DtoFactory: lua/LUA/ce/hub/data/weather/WeatherDtoFactory.lua
// Room: weather
export interface WeatherLuaDto {
  id: string;
  name: string;
  season?: number;
  cloudsIntensity?: number;
  cloudsMode?: number;
  windIntensity?: number;
  rainIntensity?: number;
  snowIntensity?: number;
  hailIntensity?: number;
  fogIntensity?: number;
}
