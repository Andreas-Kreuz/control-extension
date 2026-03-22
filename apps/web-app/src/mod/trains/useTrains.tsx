import { useTrain } from './TrainProvider';
import { TrainListDto } from '@ak/web-shared';

function useTrains(): TrainListDto[] {
  const trainStore = useTrain();
  return trainStore?.trainList || [];
}

export default useTrains;
