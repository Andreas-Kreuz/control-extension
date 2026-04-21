import { TrainListDto } from '@ce/web-shared';
import TrainLineInformationView from './TrainLineInformationView';
import useTransitTrain from '../hooks/useTransitTrain';
import useTransitSettings from '../../lines/hooks/useTransitSettings';

function TrainLineInfoSection({ train }: { train: TrainListDto }) {
  const transitTrain = useTransitTrain(train.id);
  const transitSettings = useTransitSettings();

  if (!transitSettings) return null;

  const line = transitTrain?.line ?? train.line ?? '-';
  const destination = transitTrain?.destination ?? train.destination ?? '-';
  return (
    <TrainLineInformationView line={line} destination={destination} nextStations={transitTrain?.nextStations ?? []} />
  );
}

export default TrainLineInfoSection;
