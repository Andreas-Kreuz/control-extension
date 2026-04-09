import { TrackType, TrainListDto, TrainListRoom } from '@ce/web-shared';
import { createContext, Dispatch, ReactNode, useContext, useReducer } from 'react';
import { useDynamicRoomHandler } from '../../../shared/socket/useRoomHandler';
import useDebug from '../../../shared/socket/useDebug';

export interface State {
  trackType: TrackType;
  trainList: TrainListDto[];
}

export const initialState: State = {
  trackType: TrackType.Road,
  trainList: [],
};

export type Action =
  | { type: 'trains updated'; trains: TrainListDto[] }
  | { type: 'set track type'; trackType: TrackType };

const reducer = (state: State, action: Action) => {
  switch (action.type) {
    case 'trains updated': {
      return { ...state, trainList: action.trains };
    }
    case 'set track type': {
      return { ...state, trackType: action.trackType };
    }
    default:
      throw Error();
  }
};

export const TrainContext = createContext<State | null>(null);

export const TrainDispatchContext = createContext<Dispatch<Action> | null>(null);

export const TrainProvider = (props: { children: ReactNode }) => {
  const debug = useDebug();
  const [state, dispatch] = useReducer(reducer, initialState);

  const trainDispatcher = (payload: string) => {
    if (debug) console.log('                 |⚠️ FIRED ---', '🚂 TRAINS UPDATED');
    const data: Record<string, TrainListDto> = JSON.parse(payload);
    const trains = Object.values(data).sort((a, b) => a.id.localeCompare(b.id, 'de'));
    dispatch({ type: 'trains updated', trains: trains });
  };
  useDynamicRoomHandler(TrainListRoom, state.trackType, trainDispatcher);

  return (
    <TrainContext.Provider value={state}>
      <TrainDispatchContext.Provider value={dispatch}>{props.children}</TrainDispatchContext.Provider>
    </TrainContext.Provider>
  );
};

export function useTrain() {
  return useContext(TrainContext);
}

export function useTrainDispatch() {
  return useContext(TrainDispatchContext);
}
