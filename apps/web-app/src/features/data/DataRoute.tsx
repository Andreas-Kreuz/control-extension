import { useRoutes } from 'react-router-dom';
import routes from './routes';

function DataRoute() {
  return useRoutes(routes);
}

export default DataRoute;
