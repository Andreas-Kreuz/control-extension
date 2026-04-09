import { TrainListDto } from '@ce/web-shared';
import TrainInformationView from './TrainInformationView';
import useTrainDynamic from '../hooks/useTrainDynamic';

function TrainInformationSection({ train }: { train: TrainListDto }) {
  const trainDynamic = useTrainDynamic(train.id);
  return (
    <TrainInformationView
      train={train}
      {...(trainDynamic?.targetSpeed !== undefined ? { targetSpeed: trainDynamic.targetSpeed } : {})}
    />
  );
}

export default TrainInformationSection;
