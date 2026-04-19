import StatisticsDiagram from './StatisticsDiagram';
import TimeDesc from '../../statistics/model/TimeDesc';
import InsightsDashboardPanel from './InsightsDashboardPanel';

function InsightsStatisticsPanel(props: {
  title: string;
  description: string;
  samples: TimeDesc[][];
  initializationSamples?: TimeDesc[][];
  maxValue?: number;
  legendExpanded: boolean;
  onLegendToggle: () => void;
}) {
  return (
    <InsightsDashboardPanel>
      <StatisticsDiagram
        title={props.title}
        description={props.description}
        samples={props.samples}
        initializationSamples={props.initializationSamples ?? []}
        {...(props.maxValue !== undefined ? { maxValue: props.maxValue } : {})}
        legendExpanded={props.legendExpanded}
        onLegendToggle={props.onLegendToggle}
      />
    </InsightsDashboardPanel>
  );
}

export default InsightsStatisticsPanel;
