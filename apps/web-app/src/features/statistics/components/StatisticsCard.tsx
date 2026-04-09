import { lazy } from 'react';
import Grid from '@mui/material/Grid';
const AppCardBg = lazy(() => import('../../../shared/components/AppCardBg'));
import TimeDesc from '../model/TimeDesc';
import React, { useState } from 'react';

const LEGEND_COLORS = [
  '#d62828',
  '#f77f00',
  '#fcbf49',
  '#2a9d8f',
  '#3a86ff',
  '#8338ec',
  '#ff006e',
  '#6a994e',
  '#bc4749',
  '#577590',
  '#ff595e',
  '#ff924c',
  '#8ac926',
  '#1982c4',
  '#6a4c93',
  '#c1121f',
  '#00b4d8',
  '#9b5de5',
  '#00f5d4',
  '#f15bb5',
  '#4361ee',
  '#fb5607',
  '#3a0ca3',
  '#4d908e',
  '#90be6d',
  '#277da1',
  '#f94144',
  '#f3722c',
  '#43aa8b',
  '#577590',
  '#b5179e',
];

const StatisticsOverview = (props: {
  title: string;
  samples: TimeDesc[][];
  maxEntries?: number;
  hidelegend?: boolean;
}) => {
  const [legendHidden, setLegendHidden] = useState(props.hidelegend === true);
  const maxEntries = props.maxEntries || 10;
  const list = props.samples;
  const max = getMax(list);
  const lastEntries = list.length > 0 ? list[list.length - 1] : undefined;
  const ids = lastEntries?.map((entry: TimeDesc) => entry.id) ?? [];
  const title = props.title;
  const items = Array(maxEntries)
    .fill(30)
    .map((x, i) => i);

  function colorOf(index: number) {
    return LEGEND_COLORS[index % LEGEND_COLORS.length] ?? '#d62828';
  }

  function getMax(list: TimeDesc[][]) {
    let max1 = 0;
    for (const entries of list) {
      max1 = Math.max(100, Math.max(max1, maxOfSingleList(entries)));
    }
    return max1;
  }

  function maxOfSingleList(entries: TimeDesc[]) {
    if (entries && entries.length > 0) {
      return entries.map((a) => a.ms).reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  function scaledValueOf(i: number) {
    if (max === 0) {
      return 0;
    }
    // maximum shall be 80 % of the scale
    return (i / max) * 80;
  }

  function startXOf(index: number, list: TimeDesc[]) {
    return index === 0 || !list
      ? 0
      : list
          .slice(0, index)
          .map((a) => a.ms)
          .reduce((a, b) => a + b);
  }

  const base = 16;
  const fontSize = base * 0.75;
  const graphBarHeight = base * 1.125;
  const graphLineHeight = graphBarHeight * 1.33;
  const graphSvgHeight = Math.max(maxEntries, 1) * graphLineHeight - (graphLineHeight - graphBarHeight);

  const legendEntryHeight = base;
  const legendLineHeight = legendEntryHeight * 1.2;
  const legendSvgHeight = Math.max(ids.length, 1) * legendLineHeight - (legendLineHeight - legendEntryHeight);

  return (
    <Grid size={{ xs: 12 }}>
      <AppCardBg
        title={title + (maxEntries > 1 ? ' (max: ' : ' (') + Math.round(max) + ' ms)'}
        image={'/assets/title-image-simulator.jpg'}
      >
        <Grid sx={{ pl: 2, pr: 2, cursor: 'pointer' }} onClick={() => setLegendHidden((current) => !current)}>
          <svg width="100%" height={graphSvgHeight} style={{ backgroundColor: 'white' }}>
            {items.map((item, index) => (
              <rect
                key={index}
                x="0"
                y={index * graphLineHeight}
                width={'100%'}
                height={graphBarHeight}
                style={{ fill: '#f9f9f9' }}
              />
            ))}
            {list.map((entries, j) => (
              <React.Fragment key={'Outer' + j}>
                {entries.map((item, i) => (
                  <React.Fragment key={'Inner' + i}>
                    <rect
                      x={scaledValueOf(startXOf(i, entries)) + '%'}
                      y={j * graphLineHeight}
                      width={scaledValueOf(item.ms) + '%'}
                      height={graphBarHeight}
                      style={{ fill: colorOf(i) }}
                    >
                      <title>
                        {item.ms.toFixed()} ms for {item.id}
                      </title>
                    </rect>
                  </React.Fragment>
                ))}
                <text
                  x="99%"
                  y={j * graphLineHeight + graphBarHeight / 2}
                  style={{
                    fontSize: fontSize + 'px',
                    fontFamily: "source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace",
                    fill: '#cccccc',
                    textAnchor: 'end',
                    dominantBaseline: 'middle',
                  }}
                >
                  {maxOfSingleList(entries).toFixed(1)} ms
                </text>
              </React.Fragment>
            ))}
          </svg>
          <p style={{ marginTop: '1rem', marginBottom: legendHidden ? '1rem' : '0.3rem' }}>
            Legende {legendHidden ? '(anzeigen)' : '(ausblenden)'}
          </p>
          {!legendHidden ? (
            <svg width="100%" height={legendSvgHeight} style={{ backgroundColor: 'white', marginBottom: '0.5rem' }}>
              {ids.map((id: string, j: number) => (
                <React.Fragment key={'Legend' + j}>
                  <rect
                    x="0"
                    y={j * legendLineHeight}
                    width={legendEntryHeight}
                    height={legendEntryHeight}
                    style={{ fill: colorOf(j) }}
                  />
                  <text
                    x={1.5 * legendEntryHeight}
                    y={j * legendLineHeight + legendEntryHeight / 2}
                    style={{
                      fontSize: fontSize + 'px',
                      dominantBaseline: 'middle',
                      fontFamily: "source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace",
                      fontWeight: 'lighter',
                    }}
                  >
                    {id}
                  </text>
                </React.Fragment>
              ))}
            </svg>
          ) : null}
        </Grid>
      </AppCardBg>
    </Grid>
  );
};

export default StatisticsOverview;
