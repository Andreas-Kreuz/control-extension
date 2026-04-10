import { TrackType } from '@ce/web-shared';
import { useTrainDispatch } from '../providers/TrainProvider';

function setTrackType(): (trackType: TrackType) => void {
  const trainDispatch = useTrainDispatch();

  return (trackType: TrackType) => {
    trainDispatch && trainDispatch({ type: 'set track type', trackType: trackType });
  };
}

export default setTrackType;
