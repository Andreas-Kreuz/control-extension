import { RouteObject, useParams } from 'react-router-dom';
import DataPage from './components/DataPage';
import DataEntriesPage from './components/DataEntriesPage';

function DataEntriesRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <DataEntriesPage selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { index: true, element: <DataPage /> },
  { path: ':ceType/:selectedElement?', element: <DataEntriesRoute /> },
];

export default routes;
