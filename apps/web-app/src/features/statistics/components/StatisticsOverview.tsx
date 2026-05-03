import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import StatisticsTimingCard from './StatisticsTimingCard';
import useStatistics from '../hooks/useStatistics';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import VersionInfoWrapper from './VersionInfoWrapper';

function StatisticsOverview() {
  const { overallTimes, initializationTimes, controllerUpdateTimes } = useStatistics();

  return (
    <PageContainer>
      <PageHeadline>Statistik</PageHeadline>
      <CardGridContainer>
        <VersionInfoWrapper />
        <StatisticsTimingCard title="Initialisierungszeit" samples={initializationTimes} maxEntries={1} hidelegend />
        <StatisticsTimingCard title="Gesamtzeit" samples={overallTimes} />
        <StatisticsTimingCard title="Server-Kommunikation" samples={controllerUpdateTimes} />
      </CardGridContainer>
    </PageContainer>
  );
}

export default StatisticsOverview;
