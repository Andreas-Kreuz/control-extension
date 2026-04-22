import { TrainListAppDto } from '@ce/web-shared';
import { useTrain } from '../providers/TrainProvider';

function useTrains(): TrainListAppDto[] {
  const trainStore = useTrain();
  return trainStore?.trainList || [];
}

export default useTrains;
