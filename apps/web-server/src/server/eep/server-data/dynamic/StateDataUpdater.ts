import * as fromJsonData from '../EepDataStore';

export interface StateDataUpdater {
  updateFromState: (state: Readonly<fromJsonData.State>) => void;
}
