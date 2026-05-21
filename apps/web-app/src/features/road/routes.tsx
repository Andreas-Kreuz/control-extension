import { RouteObject, useParams } from 'react-router-dom';
import IntersectionOverview from './components/IntersectionOverview';
import IntersectionCreateWizard from './components/IntersectionCreateWizard';
import StructureSignalInstallerRoute from './components/StructureSignalInstallerRoute';

function RoadOverviewRoute() {
  const { selectedElement } = useParams<{ selectedElement: string }>();

  return <IntersectionOverview selectedElement={selectedElement} />;
}

const routes: RouteObject[] = [
  { path: 'traffic-signal-installer', element: <StructureSignalInstallerRoute /> },
  { path: 'createIntersection/:wizardStep?', element: <IntersectionCreateWizard /> },
  { path: ':selectedElement?', element: <RoadOverviewRoute /> },
];

export default routes;
