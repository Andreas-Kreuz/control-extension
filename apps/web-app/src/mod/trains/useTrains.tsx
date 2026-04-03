import { useTrain } from './TrainProvider';
import { TrainListDto } from '@ce/web-shared';

function useTrains(): TrainListDto[] {
  const trainStore = useTrain();
  return trainStore?.trainList || [];
}

export default useTrains;

