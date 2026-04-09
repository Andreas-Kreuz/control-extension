import { lazy } from 'react';
const WebAppLayout = lazy(() => import('./WebAppLayout'));
const StatusSnackBar = lazy(() => import('../../features/status/components/StatusSnackBar'));
import LogOverlay from '../../features/log/overlay';

function WebAppOverlayLayout() {
  return (
    <div>
      <WebAppLayout />
      <StatusSnackBar />
      <LogOverlay />
    </div>
  );
}

export default WebAppOverlayLayout;
