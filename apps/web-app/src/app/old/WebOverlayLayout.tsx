import StatusSnackBar from '../../features/status/components/StatusSnackBar';
import LogOverlay from '../../features/log/LogOverlay';
import WebLayout from './WebLayout';

function WebOverlayLayout() {
  return (
    <div>
      <WebLayout />
      <StatusSnackBar />
      <LogOverlay />
    </div>
  );
}

export default WebOverlayLayout;
