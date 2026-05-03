import WebLayout from './WebLayout';
import WebOverlayLayout from './WebOverlayLayout';

function WebLayoutSelector(props: { simple?: boolean }) {
  return props.simple ? <WebLayout /> : <WebOverlayLayout />;
}

export default WebLayoutSelector;
