import { TrainListDto } from '@ce/web-shared';
import { useTrain } from '../providers/TrainProvider';

function useTrains(): TrainListDto[] {
  const trainStore = useTrain();
  return trainStore?.trainList || [];
}

export default useTrains;
