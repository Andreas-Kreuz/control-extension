import { TrainListDto } from '@ce/web-shared';
import TrainLineInformationView from './TrainLineInformationView';
import useTrainDynamic from '../hooks/useTrainDynamic';
import useTransitSettings from '../../lines/hooks/useTransitSettings';

function TrainLineInfoSection({ train }: { train: TrainListDto }) {
  const trainDynamic = useTrainDynamic(train.id);
  const transitSettings = useTransitSettings();

  if (!transitSettings) return null;

  const line = trainDynamic?.line ?? train.line ?? '-';
  const destination = trainDynamic?.destination ?? train.destination ?? '-';
  return <TrainLineInformationView line={line} destination={destination} />;
}

export default TrainLineInfoSection;
