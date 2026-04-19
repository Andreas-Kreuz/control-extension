import ExpandMoreRoundedIcon from '@mui/icons-material/ExpandMoreRounded';
import ChevronRightRoundedIcon from '@mui/icons-material/ChevronRightRounded';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import TimeDesc from '../../statistics/model/TimeDesc';
import StatisticsDiagramLegend from './StatisticsDiagramLegend';

const AREA_COLORS = [
  '#2a9d8f',
  '#3a86ff',
  '#f77f00',
  '#8338ec',
  '#d62828',
  '#6a994e',
  '#ff006e',
  '#577590',
  '#fcbf49',
  '#00b4d8',
];

interface AreaPoint {
  x: number;
  bottom: number;
  top: number;
}

function colorOf(index: number) {
  return AREA_COLORS[index % AREA_COLORS.length] ?? '#2a9d8f';
}

function ceTypeOf(id: string) {
  return id.replace(/^[^/]+\//, '');
}

function getIds(samples: TimeDesc[][], idOf: (id: string) => string = (id) => id) {
  const ids: string[] = [];

  for (const sample of samples) {
    for (const entry of sample) {
      const id = idOf(entry.id);
      if (!ids.includes(id)) {
        ids.push(id);
      }
    }
  }

  return ids;
}

function totalOf(sample: TimeDesc[]) {
  return sample.reduce((sum, entry) => sum + entry.ms, 0);
}

function maxTotalOf(samples: TimeDesc[][]) {
  return Math.max(100, ...samples.map((sample) => totalOf(sample)));
}

function valueOf(sample: TimeDesc[], id: string) {
  return sample.find((entry) => entry.id === id)?.ms ?? 0;
}

function yOf(value: number, max: number, height: number) {
  return height - (value / max) * height;
}

function pointsToString(points: AreaPoint[], height: number) {
  const topPoints = points.map((point) => `${point.x.toFixed(2)},${point.top.toFixed(2)}`);
  const bottomPoints = points
    .slice()
    .reverse()
    .map((point) => `${point.x.toFixed(2)},${point.bottom.toFixed(2)}`);

  return points.length > 0 ? [...topPoints, ...bottomPoints].join(' ') : `0,${height} 100,${height}`;
}

function StatisticsDiagram(props: {
  title: string;
  description: string;
  samples: TimeDesc[][];
  initializationSamples: TimeDesc[][];
  maxValue?: number;
  legendExpanded: boolean;
  onLegendToggle: () => void;
}) {
  const samples = props.samples.slice(-30);
  const initializationEntries = props.initializationSamples[0] ?? [];
  const ids = getIds(samples);
  const legendIds = getIds([initializationEntries, ...samples], ceTypeOf);
  const max = props.maxValue ?? Math.max(maxTotalOf(samples), totalOf(initializationEntries));
  const width = 100;
  const height = 42;
  const initializationBarX = 2;
  const initializationBarWidth = 5;
  const areaStartX = 12;
  const areaWidth = width - areaStartX;
  const step = samples.length > 1 ? areaWidth / (samples.length - 1) : 0;
  const scaleLines = [1, 0.75, 0.5, 0.25, 0];

  const areas = ids.map((id, idIndex) => {
    const points = samples.map((sample, sampleIndex) => {
      const bottomValue = ids.slice(0, idIndex).reduce((sum, currentId) => sum + valueOf(sample, currentId), 0);
      const topValue = bottomValue + valueOf(sample, id);

      return {
        x: areaStartX + (samples.length > 1 ? sampleIndex * step : areaWidth / 2),
        bottom: yOf(bottomValue, max, height),
        top: yOf(topValue, max, height),
      };
    });

    return { id, points };
  });

  return (
    <Box
      sx={{
        border: 1,
        borderColor: 'divider',
        borderRadius: 1,
        minWidth: 0,
        overflow: 'hidden',
        p: 2,
        width: 1,
        height: 1,
      }}
    >
      <Stack spacing={1.25} sx={{ height: 1, minWidth: 0, width: 1 }}>
        <Stack spacing={0.5} sx={{ mb: 1 }}>
          <Typography variant="h6" sx={{ lineHeight: 1 }}>
            {props.title}
          </Typography>
          <Typography variant="caption" sx={{ color: 'text.secondary', lineHeight: 1 }}>
            {props.description}
          </Typography>
        </Stack>
        <Stack direction="row" spacing={1} sx={{ alignItems: 'stretch', width: 1 }}>
          <Box sx={{ flex: '1 1 auto', minWidth: 0, overflow: 'hidden' }}>
            <svg width="100%" height="180" viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
              {scaleLines.map((line) => {
                const y = height - line * height;

                return <line key={line} x1="0" x2={width} y1={y} y2={y} stroke="#dddddd" strokeWidth="0.25" />;
              })}
              {initializationEntries.map((entry, index) => {
                const bottomValue = initializationEntries
                  .slice(0, index)
                  .reduce((sum, currentEntry) => sum + currentEntry.ms, 0);
                const topValue = bottomValue + entry.ms;

                return (
                  <rect
                    key={entry.id}
                    x={initializationBarX}
                    y={yOf(topValue, max, height)}
                    width={initializationBarWidth}
                    height={yOf(bottomValue, max, height) - yOf(topValue, max, height)}
                    fill={colorOf(legendIds.indexOf(ceTypeOf(entry.id)))}
                    opacity="0.82"
                  >
                    <title>
                      Initialisierungszeit: {entry.ms.toFixed(1)} ms for {entry.id}
                    </title>
                  </rect>
                );
              })}
              <line
                x1={areaStartX - 2}
                x2={areaStartX - 2}
                y1="0"
                y2={height}
                stroke="#dddddd"
                strokeDasharray="1 1"
                strokeWidth="0.25"
              />
              {areas.map((area) => (
                <polygon
                  key={area.id}
                  points={pointsToString(area.points, height)}
                  fill={colorOf(legendIds.indexOf(ceTypeOf(area.id)))}
                  opacity="0.82"
                >
                  <title>{area.id}</title>
                </polygon>
              ))}
            </svg>
          </Box>
          <Stack
            sx={{
              flex: '0 0 auto',
              height: 180,
              justifyContent: 'space-between',
              width: 48,
              py: 0,
            }}
          >
            {scaleLines.map((line) => (
              <Typography key={line} variant="caption" sx={{ color: 'text.secondary', lineHeight: 1 }}>
                {Math.round(max * line)} ms
              </Typography>
            ))}
          </Stack>
        </Stack>
        <Button
          variant="text"
          size="small"
          startIcon={props.legendExpanded ? <ExpandMoreRoundedIcon /> : <ChevronRightRoundedIcon />}
          onClick={props.onLegendToggle}
          sx={{ alignSelf: 'flex-start', minWidth: 0, px: 0 }}
        >
          Legende
        </Button>
        {props.legendExpanded && <StatisticsDiagramLegend ids={legendIds} colorOf={colorOf} />}
      </Stack>
    </Box>
  );
}

export default StatisticsDiagram;
