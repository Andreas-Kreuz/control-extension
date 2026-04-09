import { lazy } from 'react';
import { createBrowserRouter } from 'react-router-dom';
import useNavItems from './hooks/useNavItems';
import AppLayout from './components/AppLayout';

const WebAppLayoutSelector = lazy(() => import('./components/WebAppLayoutSelector'));
const DataRoute = lazy(() => import('../features/data/DataRoute'));
const DataEntriesRoute = lazy(() => import('../features/data/DataEntriesRoute'));
const DataEntryDetailsRoute = lazy(() => import('../features/data/DataEntryDetailsRoute'));
const RoadDetailsRoute = lazy(() => import('../features/road/RoadDetailsRoute'));
const RoadRoute = lazy(() => import('../features/road/RoadRoute'));
const HomeRoute = lazy(() => import('../features/home/HomeRoute'));
const LinesRoute = lazy(() => import('../features/lines/LinesRoute'));
const ServerRoute = lazy(() => import('../features/server/ServerRoute'));
const StatisticsRoute = lazy(() => import('../features/statistics/StatisticsRoute'));
const StatusRoute = lazy(() => import('../features/status/StatusRoute'));
const TrainsRoute = lazy(() => import('../features/trains/TrainsRoute'));

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

export const appRouter = createBrowserRouter([
  {
    path: '/simple',
    element: <WebAppLayoutSelector simple />,
    children: homeRoutes.map((route) => ({
      path: '/simple' + route.path,
      element: route.element,
    })),
  },
  {
    path: '/old',
    element: <WebAppLayoutSelector />,
    children: homeRoutes.map((route) => ({
      path: '/old' + route.path,
      element: route.element,
    })),
  },
  {
    path: '/',
    element: <AppLayout navItems={useNavItems} />,
    children: homeRoutes,
  },
  { path: '/status', element: <StatusRoute /> },
  { path: '/server', element: <ServerRoute /> },
  { path: '*', element: <div>Not Found: {window.location.pathname}</div> },
]);
