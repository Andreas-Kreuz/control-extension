import { useTrain } from './TrainProvider';
import { TrackType } from '@ce/web-shared';

function useTrackType(): TrackType {
  const trainStore = useTrain();
  return trainStore?.trackType || TrackType.Auxiliary;
}

export default useTrackType;

