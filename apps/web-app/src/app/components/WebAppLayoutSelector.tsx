import { lazy } from 'react';

const WebAppLayout = lazy(() => import('./WebAppLayout'));
const WebAppOverlayLayout = lazy(() => import('./WebAppOverlayLayout'));

function WebAppLayoutSelector(props: { simple?: boolean }) {
  return props.simple ? <WebAppLayout /> : <WebAppOverlayLayout />;
}

export default WebAppLayoutSelector;
