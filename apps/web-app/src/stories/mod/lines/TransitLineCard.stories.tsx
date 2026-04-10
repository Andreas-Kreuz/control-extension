import type { Meta, StoryObj } from '@storybook/react';
import { TransitLineCard as AkTransitLineCard } from './TransitLineCard.component';
import Line from '../../../features/lines/model/Line';
import StationInfo from '../../../features/lines/model/StationInfo';

const meta = {
  title: 'Module Elements/Transit/AkTransitLineCard',
  tags: ['autodocs'],
  component: AkTransitLineCard,
} satisfies Meta<typeof AkTransitLineCard>;

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
