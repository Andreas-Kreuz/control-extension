import { TrainListAppDto } from '@ce/web-shared';
import TrainInformationView from './TrainInformationView';
import useTrainDynamic from '../hooks/useTrainDynamic';

function TrainInformationSection({ train }: { train: TrainListAppDto }) {
  const trainDynamic = useTrainDynamic(train.id);
  return (
    <TrainInformationView
      train={train}
      {...(trainDynamic?.targetSpeed !== undefined ? { targetSpeed: trainDynamic.targetSpeed } : {})}
    />
  );
}

export default TrainInformationSection;
