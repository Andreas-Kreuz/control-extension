import StatusSnackBar from '../../features/status/components/StatusSnackBar';
import LogOverlay from '../../features/log/overlay';
import WebAppLayout from './WebAppLayout';

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
