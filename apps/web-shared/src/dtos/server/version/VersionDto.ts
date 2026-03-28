// Produced by: apps/web-server/src/server/mod/version/VersionSelector.ts
export interface VersionDto {
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
