import { TrainProvider } from './providers/TrainProvider';
import { useRoutes } from 'react-router-dom';
import routes from './routes';

const TrainsRoute = () => {
  const routeElement = useRoutes(routes);

  return <TrainProvider>{routeElement}</TrainProvider>;
};

export default TrainsRoute;
