// App contract populated by:
// apps/web-server/src/server/mod/eepdata/EepDataSelector.ts
export interface SignalAppDto {
  id: string;
  position: number;
  tag: string;
  waitingVehiclesCount: number;
  stopDistance?: number;
  itemName?: string;
  itemNameWithModelPath?: string;
  signalFunctions?: string[];
  activeFunction?: string;
}
