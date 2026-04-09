import WebAppLayout from './WebAppLayout';
import WebAppOverlayLayout from './WebAppOverlayLayout';

function WebAppLayoutSelector(props: { simple?: boolean }) {
  return props.simple ? <WebAppLayout /> : <WebAppOverlayLayout />;
}

export default WebAppLayoutSelector;
