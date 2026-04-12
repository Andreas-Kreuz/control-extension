import { RouteObject, useParams } from 'react-router-dom';
import TransitLandingPage from './components/TransitLandingPage';
import TransitStationsOverview from './components/TransitStationsOverview';
import TransitOverview from './components/TransitOverview';

function TransitOverviewRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <TransitOverview selectedElement={selectedElement} />;
}

function TransitStationsRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <TransitStationsOverview selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { index: true, element: <TransitLandingPage /> },
  { path: 'lines/:selectedElement?', element: <TransitOverviewRoute /> },
  { path: 'stations/:selectedElement?', element: <TransitStationsRoute /> },
];

export default routes;
