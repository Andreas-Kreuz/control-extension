import { Suspense } from 'react';
import { RouterProvider } from 'react-router-dom';
import { appRouter } from '../appRouter';
import ErrorBoundary from './ErrorBoundary';
import PairingGate from './PairingGate';

function WebAppRouter() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<div>Loading...</div>}>
        <PairingGate>
          <RouterProvider router={appRouter} />
        </PairingGate>
      </Suspense>
    </ErrorBoundary>
  );
}

export default WebAppRouter;
