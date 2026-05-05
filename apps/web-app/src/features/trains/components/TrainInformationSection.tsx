import { TrainListAppDto } from '@ce/web-shared';
import useTrainDynamic from '../hooks/useTrainDynamic';
import TrainInformationPanel from './panels/TrainInformationPanel';

function TrainInformationSection({ train }: { train: TrainListAppDto }) {
  const trainDynamic = useTrainDynamic(train.id);
  return (
    <TrainInformationPanel
      train={train}
      {...(trainDynamic?.targetSpeed !== undefined ? { targetSpeed: trainDynamic.targetSpeed } : {})}
    />
  );
}

export default TrainInformationSection;
