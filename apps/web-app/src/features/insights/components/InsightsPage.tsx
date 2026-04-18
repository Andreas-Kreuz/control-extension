import Grid from '@mui/material/Grid';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import useStatistics from '../../statistics/hooks/useStatistics';
import TimeDesc from '../../statistics/model/TimeDesc';
import { useState } from 'react';
import InsightsDashboardPanel from './InsightsDashboardPanel';
import InsightsInformationInfo from './InsightsInformationInfo';
import InsightsStatisticsPanel from './InsightsStatisticsPanel';
import InsightsStatusInfo from './InsightsStatusInfo';
import InsightsVersionInfo from './InsightsVersionInfo';

function totalOf(sample: TimeDesc[]) {
  return sample.reduce((sum, entry) => sum + entry.ms, 0);
}

function maxTotalOf(samples: TimeDesc[][]) {
  return Math.max(100, ...samples.slice(-30).map((sample) => totalOf(sample)));
}

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
  const maxStatisticsValue = Math.max(
    maxTotalOf(discoveryTimes),
    maxTotalOf(updateTimes),
    maxTotalOf(publisherTimes),
    totalOf(discoveryInitializationTimes[0] ?? []),
    totalOf(updateInitializationTimes[0] ?? []),
    totalOf(publisherInitializationTimes[0] ?? []),
  );

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
            maxValue={maxStatisticsValue}
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
            maxValue={maxStatisticsValue}
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
            maxValue={maxStatisticsValue}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
      </AppCardGridContainer>
    </AppPage>
  );
}

export default InsightsPage;
