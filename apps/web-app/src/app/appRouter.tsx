import { ReactNode, lazy, useEffect } from 'react';
import { createBrowserRouter } from 'react-router-dom';
import navItems from './hooks/navItems';
import RootLayout from './components/RootLayout';

const WebLayoutSelector = lazy(() => import('./old/WebLayoutSelector'));
const CompanionRoute = lazy(() => import('../features/companion/CompanionRoute'));
const DataRoute = lazy(() => import('../features/data/DataRoute'));
const RoadRoute = lazy(() => import('../features/road/RoadRoute'));
const HomeRoute = lazy(() => import('../features/home/HomeRoute'));
const InsightsRoute = lazy(() => import('../features/insights/InsightsRoute'));
const LinesRoute = lazy(() => import('../features/lines/LinesRoute'));
const LogRoute = lazy(() => import('../features/log/LogRoute'));
const ServerRoute = lazy(() => import('../features/server/ServerRoute'));
const StatusRoute = lazy(() => import('../features/status/StatusRoute'));
const TrainsRoute = lazy(() => import('../features/trains/TrainsRoute'));
const AboutRoute = lazy(() => import('../features/about/AboutRoute'));

const defaultDocumentTitle = 'Control Extension';
const serverDocumentTitle = 'CE-Server';

function DocumentTitleRoute(props: { title?: string; children: ReactNode }) {
  useEffect(() => {
    document.title = props.title ?? defaultDocumentTitle;
  }, [props.title]);

  return <>{props.children}</>;
}

const homeRoutes = [
  { path: '/', element: <HomeRoute /> },
  { path: '/transit/*', element: <LinesRoute /> },
  { path: '/road/*', element: <RoadRoute /> },
  { path: '/insights', element: <InsightsRoute /> },
  { path: '/about', element: <AboutRoute /> },
  { path: '/train/*', element: <TrainsRoute /> },
  { path: '/data/*', element: <DataRoute /> },
  { path: '/log/*', element: <LogRoute /> },
];

export const appRouter = createBrowserRouter([
  {
    path: '/companion',
    element: (
      <DocumentTitleRoute>
        <CompanionRoute />
      </DocumentTitleRoute>
    ),
  },
  {
    path: '/simple',
    element: (
      <DocumentTitleRoute>
        <WebLayoutSelector simple />
      </DocumentTitleRoute>
    ),
    children: homeRoutes.map((route) => ({
      path: '/simple' + route.path,
      element: route.element,
    })),
  },
  {
    path: '/old',
    element: (
      <DocumentTitleRoute>
        <WebLayoutSelector />
      </DocumentTitleRoute>
    ),
    children: homeRoutes.map((route) => ({
      path: '/old' + route.path,
      element: route.element,
    })),
  },
  {
    path: '/',
    element: (
      <DocumentTitleRoute>
        <RootLayout navItems={navItems} />
      </DocumentTitleRoute>
    ),
    children: homeRoutes,
  },
  {
    path: '/status',
    element: (
      <DocumentTitleRoute>
        <StatusRoute />
      </DocumentTitleRoute>
    ),
  },
  {
    path: '/server',
    element: (
      <DocumentTitleRoute title={serverDocumentTitle}>
        <ServerRoute />
      </DocumentTitleRoute>
    ),
  },
  {
    path: '*',
    element: (
      <DocumentTitleRoute>
        <div>Not Found: {window.location.pathname}</div>
      </DocumentTitleRoute>
    ),
  },
]);
