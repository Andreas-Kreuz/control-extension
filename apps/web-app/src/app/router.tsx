import { Suspense, lazy } from 'react';
import { RouterProvider, createBrowserRouter } from 'react-router-dom';
import ErrorBoundary from './errors/ErrorBoundary';
import PairingGate from './gates/PairingGate';

const ConnectionWrapper = lazy(() => import('./providers/ConnectionWrapper'));
const DataRoute = lazy(() => import('../features/data/route'));
const DataEntriesRoute = lazy(() => import('../features/data/entries-route'));
const DataEntryDetailsRoute = lazy(() => import('../features/data/details-route'));
const RoadDetailsRoute = lazy(() => import('../features/road/details-route'));
const RoadRoute = lazy(() => import('../features/road/route'));
const HomeRoute = lazy(() => import('../features/home/route'));
const LinesRoute = lazy(() => import('../features/lines/route'));
const ServerRoute = lazy(() => import('../features/server/route'));
const StatisticsRoute = lazy(() => import('../features/statistics/route'));
const StatusRoute = lazy(() => import('../features/status/route'));
const TrainsRoute = lazy(() => import('../features/trains/route'));

const homeRoutes = [
  { path: '/', element: <HomeRoute /> },
  { path: '/transit', element: <LinesRoute /> },
  { path: '/road', element: <RoadRoute /> },
  { path: '/road/:intersectionId', element: <RoadDetailsRoute /> },
  { path: '/statistics', element: <StatisticsRoute /> },
  { path: '/trains', element: <TrainsRoute /> },
  { path: '/data', element: <DataRoute /> },
  { path: '/data/:ceType', element: <DataEntriesRoute /> },
  { path: '/data/:ceType/:entryId', element: <DataEntryDetailsRoute /> },
];

export const router = createBrowserRouter([
  {
    path: '/simple',
    element: <ConnectionWrapper simple />,
    children: homeRoutes.map((route) => ({
      path: '/simple' + route.path,
      element: route.element,
    })),
  },
  {
    path: '/',
    element: <ConnectionWrapper />,
    children: homeRoutes,
  },
  { path: '/status', element: <StatusRoute /> },
  { path: '/server', element: <ServerRoute /> },
  { path: '*', element: <div>Not Found: {window.location.pathname}</div> },
]);

function AppRouter() {
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

export default AppRouter;




















