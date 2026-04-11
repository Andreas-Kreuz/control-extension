import { RouteObject, useParams } from 'react-router-dom';
import TrainsPage from './components/TrainsPage';

function TrainsPageRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <TrainsPage selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [{ path: ':selectedElement?', element: <TrainsPageRoute /> }];

export default routes;
