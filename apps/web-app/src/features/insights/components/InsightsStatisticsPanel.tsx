import StatisticsDiagram from './StatisticsDiagram';
import TimeDesc from '../../statistics/model/TimeDesc';
import OutlinedCard from '../../../shared/components/cards/OutlinedCard';

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
    <OutlinedCard title={props.title} description={props.description}>
      <StatisticsDiagram
        samples={props.samples}
        initializationSamples={props.initializationSamples ?? []}
        {...(props.maxValue !== undefined ? { maxValue: props.maxValue } : {})}
        legendExpanded={props.legendExpanded}
        onLegendToggle={props.onLegendToggle}
      />
    </OutlinedCard>
  );
}

export default InsightsStatisticsPanel;
