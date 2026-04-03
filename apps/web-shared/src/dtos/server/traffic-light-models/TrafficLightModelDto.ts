// Produced by: apps/web-server/src/server/mod/road/RoadSelector.ts
export interface TrafficLightModelDto {
  id: string;
  name: string;
  type: string;
  positionRed: number;
  positionGreen: number;
  positionYellow: number;
  positionRedYellow: number;
  positionPedestrians: number;
  positionOff: number;
  positionOffBlinking: number;
}
