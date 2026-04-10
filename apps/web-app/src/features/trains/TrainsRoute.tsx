import { TrainProvider } from './providers/TrainProvider';
import TrainsPage from './components/TrainsPage';

const TrainsRoute = () => {
  return (
    <TrainProvider>
      <TrainsPage />
    </TrainProvider>
  );
};

export default TrainsRoute;
