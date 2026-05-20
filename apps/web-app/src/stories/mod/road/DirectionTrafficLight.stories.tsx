import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import type { ReactNode } from 'react';
import { SignalGroupTrafficLightPreview } from '../../../shared/components/road';
import DirectionTrafficLight, {
  type DirectionTrafficLightItem,
} from '../../../shared/components/road/DirectionTrafficLight';

const signStraight = '/assets/sign-straight.svg';
const signRight = '/assets/sign-right.svg';
const signLeft = '/assets/sign-left.svg';

const carSigns: DirectionTrafficLightItem[] = [
  {
    signSrc: signLeft,
    signAlt: 'Links',
    trafficLightSrc: '/assets/traffic-lights/tl-car-all.png',
    trafficLightAlt: 'Auto-Ampel links',
  },
  {
    signSrc: signStraight,
    signAlt: 'Geradeaus',
    trafficLightSrc: '/assets/traffic-lights/tl-car-all.png',
    trafficLightAlt: 'Auto-Ampel geradeaus',
  },
  {
    signSrc: signRight,
    signAlt: 'Rechts',
    trafficLightSrc: '/assets/traffic-lights/tl-car-all.png',
    trafficLightAlt: 'Auto-Ampel rechts',
  },
];

const tramItems: DirectionTrafficLightItem[] = [
  {
    signSrc: signLeft,
    signAlt: 'Links',
    trafficLightSrc: '/assets/traffic-lights/tl-tram-f3-left-all.png',
    trafficLightAlt: 'Tram links',
  },
  {
    signSrc: signStraight,
    signAlt: 'Geradeaus',
    trafficLightSrc: '/assets/traffic-lights/tl-tram-1-straight-all.png',
    trafficLightAlt: 'Tram geradeaus',
  },
  {
    signSrc: signRight,
    signAlt: 'Rechts',
    trafficLightSrc: '/assets/traffic-lights/tl-tram-f2-right-all.png',
    trafficLightAlt: 'Tram rechts',
  },
];

function ExampleCard(props: { title: string; children: ReactNode }) {
  return (
    <Paper
      variant="outlined"
      sx={{
        display: 'flex',
        justifyContent: 'center',
        p: 1.5,
        borderRadius: 1,
        minWidth: 216,
      }}
    >
      <Stack spacing={1.25} alignItems="center">
        <Typography variant="caption" color="text.secondary">
          {props.title}
        </Typography>
        {props.children}
      </Stack>
    </Paper>
  );
}

function DirectionTrafficLightStory() {
  return (
    <Stack spacing={2.5}>
      <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
        <ExampleCard title="Ampelgruppe Auto">
          <SignalGroupTrafficLightPreview trafficType="CAR" turnDirections={['HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT']} />
        </ExampleCard>
        <ExampleCard title="Auto Kombi links">
          <SignalGroupTrafficLightPreview trafficType="CAR" turnDirections={['LEFT', 'STRAIGHT']} />
        </ExampleCard>
        <ExampleCard title="Auto Kombi rechts">
          <SignalGroupTrafficLightPreview trafficType="CAR" turnDirections={['STRAIGHT', 'RIGHT']} />
        </ExampleCard>
      </Stack>
      <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
        <ExampleCard title="Ampelgruppe Tram">
          <SignalGroupTrafficLightPreview trafficType="TRAM" turnDirections={['HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT']} />
        </ExampleCard>
        <ExampleCard title="Fußgänger">
          <SignalGroupTrafficLightPreview trafficType="PEDESTRIAN" turnDirections={[]} />
        </ExampleCard>
        <ExampleCard title="Rechts ausgerichtet">
          <SignalGroupTrafficLightPreview align="right" trafficType="TRAM" turnDirections={['STRAIGHT', 'RIGHT']} />
        </ExampleCard>
      </Stack>
      <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
        <ExampleCard title="Klein Auto">
          <SignalGroupTrafficLightPreview
            size="small"
            trafficType="CAR"
            turnDirections={['HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT']}
          />
        </ExampleCard>
        <ExampleCard title="Klein Tram">
          <SignalGroupTrafficLightPreview
            size="small"
            trafficType="TRAM"
            turnDirections={['HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT']}
          />
        </ExampleCard>
        <ExampleCard title="Klein Fußgänger">
          <SignalGroupTrafficLightPreview size="small" trafficType="PEDESTRIAN" turnDirections={[]} />
        </ExampleCard>
      </Stack>
      <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
        <ExampleCard title="3 Zeichen, Auto">
          <DirectionTrafficLight items={carSigns} />
        </ExampleCard>
        <ExampleCard title="1 Zeichen, Auto">
          <DirectionTrafficLight
            items={[
              {
                signSrc: '/assets/sign-straight-right.svg',
                signAlt: 'Geradeaus und rechts',
                trafficLightSrc: '/assets/traffic-light-all.svg',
                trafficLightAlt: 'Auto-Ampel',
              },
            ]}
          />
        </ExampleCard>
      </Stack>
      <Stack direction="row" spacing={2} flexWrap="wrap" useFlexGap>
        {[1, 2, 3].map((count) => (
          <ExampleCard key={count} title={`${count} Tram-Signal${count === 1 ? '' : 'e'}`}>
            <DirectionTrafficLight items={tramItems.slice(0, count)} />
          </ExampleCard>
        ))}
      </Stack>
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Direction Traffic Light',
  component: DirectionTrafficLightStory,
} satisfies Meta<typeof DirectionTrafficLightStory>;

export default meta;
type Story = StoryObj<typeof meta>;

export const InCards: Story = {};
