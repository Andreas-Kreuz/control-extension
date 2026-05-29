import { DataChangePayload } from './DataChangePayload';
import EepDataEvent from './EepDataEvent';
import { ListChangePayload } from './ListChangePayload';

export interface State {
  eventCounter: number;
  ceTypes: Record<string, Record<string, unknown>>;
  dataTransfer?: DataTransferState;
}

export interface DataTransferCeTypeState {
  updateCount: number;
  initialUpdateCount: number;
  fields: Record<string, number>;
}

export interface DataTransferEventState {
  eventCounter: number;
  eventType: EepDataEvent['type'];
  ceTypes: Record<string, DataTransferCeTypeState>;
}

export interface DataTransferState {
  seenCeTypes: Record<string, true>;
  totals: Record<string, DataTransferCeTypeState>;
  last?: DataTransferEventState;
}

export interface EepDataStoreEventOptions {
  appendToLastTransfer?: boolean;
}

const initialState: State = {
  eventCounter: 0,
  ceTypes: {},
  dataTransfer: {
    seenCeTypes: {},
    totals: {},
  },
};

export default class EepDataStore {
  private state: State = initialState;

  constructor() {}

  onNewEvent(event: EepDataEvent, options: EepDataStoreEventOptions = {}) {
    this.state = EepDataStore.updateStateOnEepEvent(event, this.state, options);
  }

  init(previousState: unknown) {
    const state = previousState as State;
    if (state && typeof state.eventCounter === 'number' && state.ceTypes) {
      this.state = EepDataStore.normalizeState(state);
    } else {
      this.state = initialState;
    }
  }

  private static normalizeState(state: State): State {
    return {
      eventCounter: state.eventCounter,
      ceTypes: state.ceTypes,
      dataTransfer: EepDataStore.normalizeDataTransferState(state.dataTransfer),
    };
  }

  private static normalizeDataTransferState(dataTransfer: DataTransferState | undefined): DataTransferState {
    return {
      seenCeTypes: dataTransfer?.seenCeTypes ?? {},
      totals: dataTransfer?.totals ?? {},
      ...(dataTransfer?.last ? { last: dataTransfer.last } : {}),
    };
  }

  private static updateStateOnEepEvent(event: EepDataEvent, state: State, options: EepDataStoreEventOptions): State {
    const dataTransfer = EepDataStore.normalizeDataTransferState(state.dataTransfer);
    switch (event.type) {
      case 'CompleteReset':
        console.log('Resetting state');
        return {
          eventCounter: event.eventCounter,
          ceTypes: {},
          dataTransfer: {
            seenCeTypes: {},
            totals: {},
          },
        };
      case 'DataAdded':
      case 'DataChanged': {
        const payload = event.payload as DataChangePayload<Record<string, unknown>>;
        const ceType = payload.ceType;
        const key = String(payload.element[payload.keyId]);
        const existing = (state.ceTypes[ceType]?.[key] ?? undefined) as Record<string, unknown> | undefined;
        const merged = existing ? { ...existing, ...payload.element } : payload.element;
        return {
          ...state,
          eventCounter: event.eventCounter,
          dataTransfer: EepDataStore.updateDataTransferForDataChange(event, dataTransfer, payload, true, options),
          ceTypes: { ...state.ceTypes, [ceType]: { ...state.ceTypes[ceType], [key]: merged } },
        };
      }
      case 'DataRemoved': {
        const payload = event.payload as DataChangePayload<Record<string, unknown>>;
        const ceType = payload.ceType;
        const key = String(payload.element[payload.keyId]);
        const currentEntries = state.ceTypes[ceType] ?? {};
        const { [key]: _, ...remainingEntries } = currentEntries;
        return {
          ...state,
          eventCounter: event.eventCounter,
          dataTransfer: EepDataStore.updateDataTransferForDataChange(event, dataTransfer, payload, false, options),
          ceTypes: { ...state.ceTypes, [ceType]: remainingEntries },
        };
      }
      case 'ListChanged': {
        const payload = event.payload as ListChangePayload<Record<string, unknown>>;
        const ceType = payload.ceType;
        const newEntries: Record<string, unknown> = {};
        for (const element of Object.values(payload.list)) {
          newEntries[String(element[payload.keyId])] = element;
        }
        return {
          ...state,
          eventCounter: event.eventCounter,
          dataTransfer: EepDataStore.updateDataTransferForListChange(event, dataTransfer, payload, options),
          ceTypes: { ...state.ceTypes, [ceType]: newEntries },
        };
      }
      default:
        console.warn('NO SUCH event.type: ' + event.type);
        return { ...state, eventCounter: event.eventCounter };
    }
  }

  private static updateDataTransferForDataChange(
    event: EepDataEvent,
    dataTransfer: DataTransferState,
    payload: DataChangePayload<Record<string, unknown>>,
    canBeInitial: boolean,
    options: EepDataStoreEventOptions,
  ): DataTransferState {
    return EepDataStore.applyDataTransferDelta(
      event,
      dataTransfer,
      payload.ceType,
      {
        fields: EepDataStore.countFields(payload.element),
        initialUpdateCount: canBeInitial && dataTransfer.seenCeTypes[payload.ceType] !== true ? 1 : 0,
        updateCount: 1,
      },
      options,
    );
  }

  private static updateDataTransferForListChange(
    event: EepDataEvent,
    dataTransfer: DataTransferState,
    payload: ListChangePayload<Record<string, unknown>>,
    options: EepDataStoreEventOptions,
  ): DataTransferState {
    const fields: Record<string, number> = {};
    for (const element of Object.values(payload.list)) {
      EepDataStore.addFieldCounts(fields, EepDataStore.countFields(element));
    }

    return EepDataStore.applyDataTransferDelta(
      event,
      dataTransfer,
      payload.ceType,
      {
        fields,
        initialUpdateCount: dataTransfer.seenCeTypes[payload.ceType] !== true ? 1 : 0,
        updateCount: 1,
      },
      options,
    );
  }

  private static applyDataTransferDelta(
    event: EepDataEvent,
    dataTransfer: DataTransferState,
    ceType: string,
    delta: DataTransferCeTypeState,
    options: EepDataStoreEventOptions,
  ): DataTransferState {
    const previous = dataTransfer.totals[ceType] ?? EepDataStore.emptyCeTypeState();
    const nextCeTypeTotals = EepDataStore.addCeTypeCounts(previous, delta);
    const seenCeTypes =
      delta.initialUpdateCount > 0
        ? { ...dataTransfer.seenCeTypes, [ceType]: true as const }
        : dataTransfer.seenCeTypes;

    const previousLastCeTypes = options.appendToLastTransfer ? (dataTransfer.last?.ceTypes ?? {}) : {};
    const nextLastCeTypes = {
      ...previousLastCeTypes,
      [ceType]: EepDataStore.addCeTypeCounts(previousLastCeTypes[ceType] ?? EepDataStore.emptyCeTypeState(), delta),
    };

    return {
      seenCeTypes,
      totals: {
        ...dataTransfer.totals,
        [ceType]: nextCeTypeTotals,
      },
      last: {
        eventCounter: event.eventCounter,
        eventType: event.type,
        ceTypes: nextLastCeTypes,
      },
    };
  }

  private static emptyCeTypeState(): DataTransferCeTypeState {
    return {
      updateCount: 0,
      initialUpdateCount: 0,
      fields: {},
    };
  }

  private static addCeTypeCounts(
    left: DataTransferCeTypeState,
    right: DataTransferCeTypeState,
  ): DataTransferCeTypeState {
    const fields = { ...left.fields };
    EepDataStore.addFieldCounts(fields, right.fields);

    return {
      updateCount: left.updateCount + right.updateCount,
      initialUpdateCount: left.initialUpdateCount + right.initialUpdateCount,
      fields,
    };
  }

  private static countFields(element: Record<string, unknown>): Record<string, number> {
    const counts: Record<string, number> = {};
    for (const field of Object.keys(element)) {
      counts[field] = (counts[field] ?? 0) + 1;
    }
    return counts;
  }

  private static addFieldCounts(target: Record<string, number>, source: Record<string, number>): void {
    for (const [field, count] of Object.entries(source)) {
      target[field] = (target[field] ?? 0) + count;
    }
  }

  currentState(): Readonly<State> {
    return this.state;
  }

  getEventCounter(): number {
    return this.state.eventCounter;
  }

  hasInitialState(): boolean {
    return this.state === initialState;
  }
}
