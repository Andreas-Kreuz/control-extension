// App contract populated by:
// apps/web-server/src/server/mod/road/RoadSelector.ts
export interface TrafficLightModelAppDto {
  id: string;
  name: string;
  type: string;
  luaConstant?: string;
  modelNamePatterns: string[];
  modelNameMatchOrder: number;
  positionRed: number;
  positionGreen: number;
  positionYellow: number;
  positionRedYellow: number;
  positionPedestrians: number;
  positionOff: number;
  positionOffBlinking: number;
}
