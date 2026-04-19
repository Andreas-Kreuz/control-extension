import { useRoutes } from 'react-router-dom';
import routes from './routes';

function StatusRoute() {
  return useRoutes(routes);
}

export default StatusRoute;
