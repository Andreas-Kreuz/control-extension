import { lazy } from 'react';
const ClientAppMainPage = lazy(() => import('./ClientAppMainPage'));
const StatusSnackBar = lazy(() => import('../features/status/components/StatusSnackBar'));
import LogOverlay from '../features/log/overlay';

function ClientAppMainPageWithSnack() {
  return (
    <div>
      <ClientAppMainPage />
      <StatusSnackBar />
      <LogOverlay />
    </div>
  );
}

export default ClientAppMainPageWithSnack;



