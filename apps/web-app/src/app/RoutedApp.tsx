import ErrorBoundary from './ErrorBoundary';
import PairingGate from './PairingGate';
import { Suspense, lazy } from 'react';
import { RouterProvider, createBrowserRouter } from 'react-router-dom';

const ConnectionWrapper = lazy(() => import('./ConnectionWrapper'));
const IntersectionDetails = lazy(() => import('../mod/road/IntersectionDetails'));
const IntersectionOverview = lazy(() => import('../mod/road/IntersectionOverview'));
const MainMenu = lazy(() => import('../home/MainMenu'));
const TransitOverview = lazy(() => import('../mod/lines/TransitOverview'));
const Server = lazy(() => import('../server/Server'));
const StatisticsOverview = lazy(() => import('../mod/statistics/StatisticsMod'));
const StatusGrid = lazy(() => import('../mod/status/StatusGrid'));
const Trains = lazy(() => import('../mod/trains/TrainMod'));

const homeRoutes = [
  { path: '/', element: <MainMenu /> },
  { path: '/transit', element: <TransitOverview /> },
  { path: '/road', element: <IntersectionOverview /> },
  { path: '/road/:intersectionId', element: <IntersectionDetails /> },
  { path: '/statistics', element: <StatisticsOverview /> },
  { path: '/trains', element: <Trains /> },
];

export const router = createBrowserRouter([
  {
    path: '/simple',
    element: <ConnectionWrapper simple />,
    children: homeRoutes.map((r) => {
      return { path: '/simple' + r.path, element: r.element };
    }),
  },
  {
    path: '/',
    element: <ConnectionWrapper />,
    children: homeRoutes,
  },
  { path: '/status', element: <StatusGrid /> },
  { path: '/server', element: <Server /> },
  { path: '*', element: <div>Not Found: {window.location.pathname}</div> },
]);

function RoutedApp() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<div>Loading...</div>}>
        <PairingGate>
          <RouterProvider router={router} />
        </PairingGate>
      </Suspense>
    </ErrorBoundary>
  );
}

export default RoutedApp;
