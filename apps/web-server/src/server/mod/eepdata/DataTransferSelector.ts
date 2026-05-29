import * as fromEepData from '../../eep/server-data/EepDataStore';
import {
  DataTransferFieldsAppDto,
  DataTransferFieldAppDto,
  DataTransferSummaryAppDto,
  DataTransferCeTypeSummaryAppDto,
} from '@ce/web-shared';

function sumFields(fields: Record<string, number> | undefined): number {
  return Object.values(fields ?? {}).reduce((sum, count) => sum + count, 0);
}

function sortByName<T>(entries: T[], nameOf: (entry: T) => string): T[] {
  return [...entries].sort((left, right) => nameOf(left).localeCompare(nameOf(right)));
}

export default class DataTransferSelector {
  private summary: DataTransferSummaryAppDto = { eventCounter: 0, ceTypes: [] };
  private fieldsByCeType: Record<string, DataTransferFieldsAppDto> = {};
  private lastState?: fromEepData.State;

  updateFromState(state: fromEepData.State): void {
    if (state === this.lastState) {
      return;
    }
    this.lastState = state;

    const dataTransfer = state.dataTransfer ?? { seenCeTypes: {}, totals: {} };
    const lastCeTypes = dataTransfer.last?.ceTypes ?? {};
    const ceTypeNames = sortByName(
      Array.from(new Set([...Object.keys(dataTransfer.totals), ...Object.keys(lastCeTypes)])),
      (ceType) => ceType,
    );

    const ceTypes: DataTransferCeTypeSummaryAppDto[] = ceTypeNames.map((ceType) => {
      const totals = dataTransfer.totals[ceType];
      const last = lastCeTypes[ceType];

      return {
        ceType,
        totalUpdateCount: totals?.updateCount ?? 0,
        initialUpdateCount: totals?.initialUpdateCount ?? 0,
        lastUpdateCount: last?.updateCount ?? 0,
        totalFieldUpdateCount: sumFields(totals?.fields),
        lastFieldUpdateCount: sumFields(last?.fields),
      };
    });

    this.summary = {
      eventCounter: state.eventCounter,
      ...(dataTransfer.last
        ? { lastEventCounter: dataTransfer.last.eventCounter, lastEventType: dataTransfer.last.eventType }
        : {}),
      ceTypes,
    };

    this.fieldsByCeType = {};
    for (const ceType of ceTypeNames) {
      this.fieldsByCeType[ceType] = {
        ceType,
        fields: this.createFields(dataTransfer.totals[ceType]?.fields, lastCeTypes[ceType]?.fields),
      };
    }
  }

  private createFields(
    totalFields: Record<string, number> | undefined,
    lastFields: Record<string, number> | undefined,
  ): DataTransferFieldAppDto[] {
    const fieldNames = sortByName(
      Array.from(new Set([...Object.keys(totalFields ?? {}), ...Object.keys(lastFields ?? {})])),
      (field) => field,
    );

    return fieldNames.map((field) => ({
      field,
      totalUpdateCount: totalFields?.[field] ?? 0,
      lastUpdateCount: lastFields?.[field] ?? 0,
    }));
  }

  getSummary(): DataTransferSummaryAppDto {
    return {
      ...this.summary,
      ceTypes: this.summary.ceTypes.map((entry) => ({ ...entry })),
    };
  }

  getFields(ceType: string): DataTransferFieldsAppDto {
    const entry = this.fieldsByCeType[ceType] ?? { ceType, fields: [] };

    return {
      ceType: entry.ceType,
      fields: entry.fields.map((field) => ({ ...field })),
    };
  }
}
