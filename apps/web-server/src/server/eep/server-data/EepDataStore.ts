import { DataChangePayload } from './DataChangePayload';
import EepDataEvent from './EepDataEvent';
import { ListChangePayload } from './ListChangePayload';

export interface State {
  eventCounter: number;
  ceTypes: Record<string, Record<string, unknown>>;
}

const initialState: State = {
  eventCounter: 0,
  ceTypes: {},
};

export default class EepDataStore {
  private state: State = initialState;

  constructor() {}

  onNewEvent(event: EepDataEvent) {
    this.state = EepDataStore.updateStateOnEepEvent(event, this.state);
  }

  init(previousState: unknown) {
    const state = previousState as State;
    if (state && state.eventCounter && state.ceTypes) {
      this.state = state;
    } else {
      this.state = initialState;
    }
  }

  private static updateStateOnEepEvent(event: EepDataEvent, state: State): State {
    switch (event.type) {
      case 'CompleteReset':
        console.log('Resetting state');
        return {
          eventCounter: event.eventCounter,
          ceTypes: {},
        };
      case 'DataAdded':
      case 'DataChanged': {
        const payload = event.payload as DataChangePayload<Record<string, unknown>>;
        const ceType = payload.ceType;
        const key = String(payload.element[payload.keyId]);
        return {
          ...state,
          eventCounter: event.eventCounter,
          ceTypes: { ...state.ceTypes, [ceType]: { ...state.ceTypes[ceType], [key]: payload.element } },
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
          ceTypes: { ...state.ceTypes, [ceType]: newEntries },
        };
      }
      default:
        console.warn('NO SUCH event.type: ' + event.type);
        return { ...state, eventCounter: event.eventCounter };
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
