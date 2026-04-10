// Lua DtoFactory: lua/LUA/ce/hub/data/scenario/ScenarioDtoFactory.lua
// Room: scenario
export interface ScenarioLuaDto {
  id: string;
  name: string;
  scenarioName?: string;
  scenarioPath?: string;
  savedWithEep?: number;
  scenarioLanguage?: string;
  eepLanguage?: string;
  activeTrain?: string;
  activeRollingStock?: string;
  timeLapse?: number;
}
