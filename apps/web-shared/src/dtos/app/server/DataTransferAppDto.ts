// App contract populated by:
// apps/web-server/src/server/mod/eepdata/DataTransferSelector.ts
export interface DataTransferCeTypeSummaryAppDto {
  ceType: string;
  totalUpdateCount: number;
  initialUpdateCount: number;
  lastUpdateCount: number;
  totalFieldUpdateCount: number;
  lastFieldUpdateCount: number;
}

export interface DataTransferFieldAppDto {
  field: string;
  totalUpdateCount: number;
  lastUpdateCount: number;
}

export interface DataTransferSummaryAppDto {
  eventCounter: number;
  lastEventCounter?: number;
  lastEventType?: string;
  ceTypes: DataTransferCeTypeSummaryAppDto[];
}

export interface DataTransferFieldsAppDto {
  ceType: string;
  fields: DataTransferFieldAppDto[];
}
