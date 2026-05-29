import { RouteObject } from 'react-router-dom';
import DataTransferPage from './components/DataTransferPage';
import InsightsPage from './components/InsightsPage';

const routes: RouteObject[] = [
  { index: true, element: <InsightsPage /> },
  { path: 'data-transfer', element: <DataTransferPage /> },
];

export default routes;
