import { RouteObject, useParams } from 'react-router-dom';
import DataPage from './components/DataPage';
import DataTypeEntriesPage from './components/DataTypeEntriesPage';

function DataTypeEntriesRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <DataTypeEntriesPage selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { index: true, element: <DataPage /> },
  { path: ':ceType/:selectedElement?', element: <DataTypeEntriesRoute /> },
];

export default routes;
