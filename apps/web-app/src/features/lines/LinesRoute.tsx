import { useRoutes } from 'react-router-dom';
import routes from './routes';

function LinesRoute() {
  return useRoutes(routes);
}

export default LinesRoute;
