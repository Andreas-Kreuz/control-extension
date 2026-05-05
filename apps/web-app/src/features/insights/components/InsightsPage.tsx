import Grid from '@mui/material/Grid';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import useStatistics from '../hooks/useStatistics';
import TimeDesc from '../model/TimeDesc';
import { useState } from 'react';
import InsightsRuntimeInfo from './InsightsRuntimeInfo';
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
    <PageContainer>
      <PageHeadline>Einblicke</PageHeadline>
      <CardGridContainer>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatusInfo />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsRuntimeInfo updateTimes={updateTimes} />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsVersionInfo />
        </Grid>
      </CardGridContainer>
      <CardGridContainer sx={{ mt: 3 }}>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Erkennung"
            description="Discovery für neue Daten"
            samples={discoveryTimes}
            initializationSamples={discoveryInitializationTimes}
            maxValue={maxStatisticsValue}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Aktualisierung"
            description="Update vorhandener Daten"
            samples={updateTimes}
            initializationSamples={updateInitializationTimes}
            maxValue={maxStatisticsValue}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
        <Grid size={{ xs: 12, md: 6, lg: 4 }}>
          <InsightsStatisticsPanel
            title="Bereitstellung"
            description="Publisher kodiert Daten für die Bridge"
            samples={publisherTimes}
            initializationSamples={publisherInitializationTimes}
            maxValue={maxStatisticsValue}
            legendExpanded={legendsExpanded}
            onLegendToggle={() => setLegendsExpanded((current) => !current)}
          />
        </Grid>
      </CardGridContainer>
    </PageContainer>
  );
}

export default InsightsPage;
