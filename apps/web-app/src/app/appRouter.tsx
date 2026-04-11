import { lazy } from 'react';
import { createBrowserRouter } from 'react-router-dom';
import navItems from './hooks/navItems';
import AppLayout from './components/AppLayout';

const WebAppLayoutSelector = lazy(() => import('./old/WebAppLayoutSelector'));
const DataRoute = lazy(() => import('../features/data/DataRoute'));
const RoadRoute = lazy(() => import('../features/road/RoadRoute'));
const HomeRoute = lazy(() => import('../features/home/HomeRoute'));
const LinesRoute = lazy(() => import('../features/lines/LinesRoute'));
const ServerRoute = lazy(() => import('../features/server/ServerRoute'));
const StatisticsRoute = lazy(() => import('../features/statistics/StatisticsRoute'));
const StatusRoute = lazy(() => import('../features/status/StatusRoute'));
const TrainsRoute = lazy(() => import('../features/trains/TrainsRoute'));

const homeRoutes = [
  { path: '/', element: <HomeRoute /> },
  { path: '/transit/*', element: <LinesRoute /> },
  { path: '/road/*', element: <RoadRoute /> },
  { path: '/statistics', element: <StatisticsRoute /> },
  { path: '/trains/*', element: <TrainsRoute /> },
  { path: '/data/*', element: <DataRoute /> },
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
    element: <AppLayout navItems={navItems} />,
    children: homeRoutes,
  },
  { path: '/status', element: <StatusRoute /> },
  { path: '/server', element: <ServerRoute /> },
  { path: '*', element: <div>Not Found: {window.location.pathname}</div> },
]);
