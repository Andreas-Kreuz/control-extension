import './index.css';
import React from 'react';
import ReactDOM from 'react-dom/client';
import { lazy } from 'react';
const ThemedApp = lazy(() => import('./base/ThemedApp'));
// import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

const serverRenderPaths = ['/api'];

// Only render the router if the path is not in the excluded list
if (serverRenderPaths.some((path) => window.location.pathname.startsWith(path))) {
  root.render(<div>Server-rendered content</div>);
} else {
  root.render(
    <React.StrictMode>
      <ThemedApp />
    </React.StrictMode>,
  );
}

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
// reportWebVitals();
