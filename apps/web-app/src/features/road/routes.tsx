import { RouteObject, useParams } from 'react-router-dom';
import IntersectionOverview from './components/IntersectionOverview';

function RoadOverviewRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <IntersectionOverview selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { path: ':selectedElement?', element: <RoadOverviewRoute /> },
];

export default routes;
