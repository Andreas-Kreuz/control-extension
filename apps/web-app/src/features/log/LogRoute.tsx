import { useRoutes } from 'react-router-dom';
import routes from './routes';

function LogRoute() {
  return useRoutes(routes);
}

export default LogRoute;
