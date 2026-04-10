// Produced by: apps/web-server/src/server/mod/scenario/ScenarioSelector.ts
export interface ScenarioDto {
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
