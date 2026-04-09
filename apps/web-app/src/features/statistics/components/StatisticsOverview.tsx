import { lazy } from 'react';
const AppCardGridContainer = lazy(() => import('../../../shared/ui/AppCardGridContainer'));
const AppPage = lazy(() => import('../../../shared/ui/AppPage'));
import StatisticsCard from './StatisticsCard';
import useStatistics from '../hooks/useStatistics';
import AppPageHeadline from '../../../shared/ui/AppPageHeadline';
import VersionInfoWrapper from './VersionInfoWrapper';

function StatisticsOverview() {
  const { overallTimes, initializationTimes, controllerUpdateTimes } = useStatistics();

  return (
    <AppPage>
      <AppPageHeadline>Statistik</AppPageHeadline>
      <AppCardGridContainer>
        <VersionInfoWrapper />
        <StatisticsCard title="Initialisierungszeit" samples={initializationTimes} maxEntries={1} hidelegend />
        <StatisticsCard title="Gesamtzeit" samples={overallTimes} />
        <StatisticsCard title="Server-Kommunikation" samples={controllerUpdateTimes} />
      </AppCardGridContainer>
    </AppPage>
  );
}

export default StatisticsOverview;
