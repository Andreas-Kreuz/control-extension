import { lazy } from 'react';
const AppCardGridContainer = lazy(() => import('../../components/AppCardGridContainer'));
const AppPage = lazy(() => import('../../components/AppPage'));
import StatisticsCard from './StatisticsCard';
import useStatistics from './useStatistics';
import AppPageHeadline from '../../components/AppPageHeadline';
import VersionInfoWrapper from './VersionInfoWrapper';

function StatisticsOverview() {
  const { publisherSyncTimes, publisherInitTimes, controllerUpdateTimes, moduleInitTimes, moduleRunTimes } =
    useStatistics();

  return (
    <AppPage>
      <AppPageHeadline>Statistik</AppPageHeadline>
      <AppCardGridContainer>
        <VersionInfoWrapper />
        <StatisticsCard title="Ausführung der Publisher" samples={publisherSyncTimes} />
        <StatisticsCard title="Ausführung CeModule" samples={moduleRunTimes} />
        <StatisticsCard title="Server" samples={controllerUpdateTimes} />
        <StatisticsCard
          title="Initialisierung CeModule"
          samples={moduleInitTimes.length > 0 ? [moduleInitTimes] : []}
          maxEntries={1}
        />
        <StatisticsCard
          title="Initialisierung der Publisher"
          samples={publisherInitTimes.length > 0 ? [publisherInitTimes] : []}
          maxEntries={1}
        />
      </AppCardGridContainer>
    </AppPage>
  );
}

export default StatisticsOverview;
