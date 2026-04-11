import { useRoutes } from 'react-router-dom';
import routes from './routes';

function RoadRoute() {
  return useRoutes(routes);
}

export default RoadRoute;
