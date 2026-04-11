import { RouteObject, useParams } from 'react-router-dom';
import TransitOverview from './components/TransitOverview';

function TransitOverviewRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <TransitOverview selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { path: ':selectedElement?', element: <TransitOverviewRoute /> },
];

export default routes;
