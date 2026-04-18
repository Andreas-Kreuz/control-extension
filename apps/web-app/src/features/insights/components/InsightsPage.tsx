import Grid from '@mui/material/Grid';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import useStatistics from '../../statistics/hooks/useStatistics';
import { useState } from 'react';
import InsightsDashboardPanel from './InsightsDashboardPanel';
import InsightsInformationInfo from './InsightsInformationInfo';
import InsightsStatisticsPanel from './InsightsStatisticsPanel';
import InsightsStatusInfo from './InsightsStatusInfo';
import InsightsVersionInfo from './InsightsVersionInfo';

function InsightsPage() {
  const [legendsExpanded, setLegendsExpanded] = useState(false);
  const {
    discoveryInitializationTimes,
    discoveryTimes,
    publisherInitializationTimes,
    publisherTimes,
    updateInitializationTimes,
    updateTimes,
  } = useStatistics();

  return (
    <AppPage>
      <AppPageHeadline>Einblicke</AppPageHeadline>
      <AppCardGridContainer>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsDashboardPanel>
            <InsightsStatusInfo />
          </InsightsDashboardPanel>
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsDashboardPanel>
            <InsightsVersionInfo />
          </InsightsDashboardPanel>
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsDashboardPanel>
            <InsightsInformationInfo updateTimes={updateTimes} />
          </InsightsDashboardPanel>
        </Grid>
      </AppCardGridContainer>
      <AppCardGridContainer sx={{ mt: 3 }}>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Discovery"
            description="Daten-Erkennung"
            samples={discoveryTimes}
            initializationSamples={discoveryInitializationTimes}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Update"
            description="Daten-Aktualisierung"
            samples={updateTimes}
            initializationSamples={updateInitializationTimes}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Publisher"
            description="Daten-Bereitstellung"
            samples={publisherTimes}
            initializationSamples={publisherInitializationTimes}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
      </AppCardGridContainer>
    </AppPage>
  );
}

export default InsightsPage;
