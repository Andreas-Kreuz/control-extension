// Legacy combined structure DTO retained for compatibility with older event fixtures.
export interface StructureLuaDto {
  id: string;
  name: string;
  pos_x: number;
  pos_y: number;
  pos_z: number;
  rot_x: number;
  rot_y: number;
  rot_z: number;
  modelType: number;
  modelTypeText: string;
  tag: string;
  light: boolean;
  smoke: boolean;
  fire: boolean;
}
