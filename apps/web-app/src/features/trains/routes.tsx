import { Navigate, RouteObject, useParams } from 'react-router-dom';
import TrainDashboard from './components/selectedTrain/TrainDashboard';
import TrainRollingStockModelSummaryRoute from './components/selectedTrain/TrainRollingStockModelSummaryRoute';
import TrainsPage from './components/TrainsPage';

function TrainsPageRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <TrainsPage {...(selectedElement !== undefined ? { selectedElement } : {})} />;
}

const routes: RouteObject[] = [
  { index: true, element: <Navigate replace to="list" /> },
  { path: 'list/:selectedElement?', element: <TrainsPageRoute /> },
  { path: 'selected', element: <TrainDashboard /> },
  { path: 'selected-as-rs-model', element: <TrainRollingStockModelSummaryRoute /> },
];

export default routes;
