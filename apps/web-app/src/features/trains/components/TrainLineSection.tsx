import { TrainListAppDto } from '@ce/web-shared';
import useTransitSettings from '../../lines/hooks/useTransitSettings';
import useTransitTrain from '../hooks/useTransitTrain';
import TrainLinePanel from './panels/TrainLinePanel';

function TrainLineSection({ train }: { train: TrainListAppDto }) {
  const transitTrain = useTransitTrain(train.id);
  const transitSettings = useTransitSettings();

  if (!transitSettings) return null;

  const line = transitTrain?.line ?? train.line ?? '-';
  const destination = transitTrain?.destination ?? train.destination ?? '-';
  return <TrainLinePanel line={line} destination={destination} nextStations={transitTrain?.nextStations ?? []} />;
}

export default TrainLineSection;
