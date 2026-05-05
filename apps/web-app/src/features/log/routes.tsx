import { Navigate, RouteObject } from 'react-router-dom';
import LogPureRoute from './LogPureRoute';

const routes: RouteObject[] = [
  { index: true, element: <Navigate to="pure" replace /> },
  { path: 'pure', element: <LogPureRoute /> },
];

export default routes;
