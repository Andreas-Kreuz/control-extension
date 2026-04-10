import './index.css';
import React from 'react';
import ReactDOM from 'react-dom/client';
import WebAppRoot from './app/components/WebAppRoot';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

const serverRenderPaths = ['/api'];

// Only render the router if the path is not in the excluded list
if (serverRenderPaths.some((path) => window.location.pathname.startsWith(path))) {
  root.render(<div>Server-rendered content</div>);
} else {
  root.render(
    <React.StrictMode>
      <WebAppRoot />
    </React.StrictMode>,
  );
}
