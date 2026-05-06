import Stack from '@mui/material/Stack';
import type { Meta, StoryObj } from '@storybook/react';
import Line from '../../../features/lines/model/Line';
import StationInfo from '../../../features/lines/model/StationInfo';
import { TransitLineListCard as TransitLineListCardStory } from './TransitLineListCard.component';

const meta = {
  title: 'Module Elements/Transit/TransitLineListCard',
  tags: ['autodocs'],
  component: TransitLineListCardStory,
} satisfies Meta<typeof TransitLineListCardStory>;

const line10HbfStations: StationInfo[] = [
  { station: { name: 'Alte Messe' }, timeToStation: 0 },
  { station: { name: 'Am Markt' }, timeToStation: 3 },
  { station: { name: 'Brückenstraße' }, timeToStation: 4 },
  { station: { name: 'Hohenau' }, timeToStation: 2 },
  { station: { name: 'Hauptbahnhof' }, timeToStation: 3 },
];
const line10AmStations: StationInfo[] = [
  { station: { name: 'Hauptbahnhof' }, timeToStation: 0 },
  { station: { name: 'Hohenau' }, timeToStation: 3 },
  { station: { name: 'Brückenstraße' }, timeToStation: 2 },
  { station: { name: 'Am Markt' }, timeToStation: 4 },
  { station: { name: 'Alte Messe' }, timeToStation: 2 },
];

const line1: Line = {
  id: 10,
  nr: '10',
  trafficType: 'TRAM',
  lineSegments: [
    { id: '10 Hbf', destination: 'Hauptbahnhof', route: 'Linie 10: Hauptbahnhof', stations: line10HbfStations },
    { id: '10 Am', destination: 'Alte Messe', route: 'Linie 10: Alte Messe', stations: line10AmStations },
  ],
};

const line2Bus: Line = { ...line1, id: 65, nr: '65', trafficType: 'BUS' };
const line3Train: Line = { ...line1, id: 43, nr: 'S43', trafficType: 'TRAIN' };
const line4Subway: Line = { ...line1, id: 405, nr: 'U5', trafficType: 'SUBWAY' };
const line5Ferry: Line = { ...line1, id: 120, nr: 'F12', trafficType: 'FERRY' };
const line6Sbahn: Line = { ...line1, id: 3, nr: 'S3', trafficType: 'SBAHN' };
const iconLines = [line2Bus, line1, line4Subway, line5Ferry, line6Sbahn];

export default meta;
type Story = StoryObj<typeof meta>;

export const Tram: Story = {
  args: { line: line1, selected: false, onSelect: () => {} },
};

export const Bus: Story = {
  args: { line: line2Bus, selected: false, onSelect: () => {} },
};

export const Rail: Story = {
  args: { line: line3Train, selected: false, onSelect: () => {} },
};

export const Subway: Story = {
  args: { line: line4Subway, selected: false, onSelect: () => {} },
};

export const AllIcons: Story = {
  render: () => (
    <Stack spacing={2} sx={{ p: 2 }}>
      {iconLines.map((line) => (
        <TransitLineListCardStory key={line.id} line={line} selected={false} onSelect={() => {}} />
      ))}
    </Stack>
  ),
};

export const SubwayOnMobile: Story = {
  args: { line: line4Subway, selected: false, onSelect: () => {} },
  globals: { viewport: { value: 'mobile1', isRotated: false } },
  tags: ['mobile'],
};

export const Selected: Story = {
  args: { line: line1, selected: true, onSelect: () => {} },
};

export const SelectedOnMobile: Story = {
  args: { line: line1, selected: true, onSelect: () => {} },
  globals: { viewport: { value: 'mobile1', isRotated: false } },
  tags: ['mobile'],
};
