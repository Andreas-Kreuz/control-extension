import { TrackType } from '@ce/web-shared';
import { useTrain } from '../providers/TrainProvider';

function useTrackType(): TrackType {
  const trainStore = useTrain();
  return trainStore?.trackType || TrackType.Auxiliary;
}

export default useTrackType;
