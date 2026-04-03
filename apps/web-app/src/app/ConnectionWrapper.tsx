import { lazy } from 'react';
const ClientAppMainPage = lazy(() => import('./ClientAppMainPage'));
const ClientAppMainPageWithSnack = lazy(() => import('./ClientAppMainPageWithSnack'));

function ConnectionWrapper(props: { simple?: boolean }) {
  return props.simple ? <ClientAppMainPage /> : <ClientAppMainPageWithSnack />;
}

export default ConnectionWrapper;
