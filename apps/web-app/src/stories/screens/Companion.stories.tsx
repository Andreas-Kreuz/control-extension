import { TrackType } from '@ce/web-shared';
import type { RollingStockAppDto, TrainAppDto } from '@ce/web-shared';
import type { Meta, StoryObj } from '@storybook/react';
import { MemoryRouter } from 'react-router-dom';
import CompanionPage from '../../features/companion/components/CompanionPage';
import type { TrainDashboardPanelModel } from '../../features/trains/lib/trainDashboardPanelModel';

const noop = () => undefined;

const train: TrainAppDto = {
  id: 'M4-12',
  name: 'M4 Innenstadt',
  route: 'Stadtring',
  rollingStockCount: 2,
  length: 58,
  speed: 35,
  targetSpeed: 40,
  couplingFront: 0,
  couplingRear: 0,
  lights: { 2: true, 3: false },
  active: true,
  inTrainyard: false,
  movesForward: true,
  line: 'M4',
  destination: 'Hauptbahnhof',
  nextStations: [
    { station: { name: 'Marktplatz', platform: '1' }, departureInMinutes: 2 },
    { station: { name: 'Rathaus', platform: '2' }, departureInMinutes: 5 },
    { station: { name: 'Hauptbahnhof', platform: '4' }, departureInMinutes: 9 },
  ],
  trackType: TrackType.Tram,
};

const rollingStock: RollingStockAppDto[] = [
  {
    id: 'flexity-301-a',
    name: 'Flexity 301 A',
    trainName: train.id,
    positionInTrain: 1,
    couplingFront: 0,
    couplingRear: 1,
    length: 29,
    propelled: true,
    modelType: 0,
    modelTypeText: 'Tram',
    tag: 'M4',
    hookStatus: 0,
    hookGlueMode: 0,
    trackSystem: 0,
    trackId: 12,
    trackDistance: 145,
    trackDirection: 1,
    posX: 0,
    posY: 0,
    posZ: 0,
    mileage: 1240,
    orientationForward: true,
    smoke: 0,
    active: true,
    axisNamesKnown: true,
    axisNames: { 1: 'Tür links', 2: 'Tür rechts' },
    axisValues: { 1: 0, 2: 100 },
    surfaceTexts: { 1: 'M4', 2: 'Hauptbahnhof' },
    textureNames: { 1: 'Linie', 2: 'Ziel' },
    rotX: 0,
    rotY: 0,
    rotZ: 0,
    trackType: TrackType.Tram,
    xmlModel: 'Resourcen/Rollmaterial/Strassenbahn/Flexity.3dm',
  },
  {
    id: 'flexity-301-b',
    name: 'Flexity 301 B',
    trainName: train.id,
    positionInTrain: 2,
    couplingFront: 1,
    couplingRear: 0,
    length: 29,
    propelled: true,
    modelType: 0,
    modelTypeText: 'Tram',
    tag: 'M4',
    hookStatus: 0,
    hookGlueMode: 0,
    trackSystem: 0,
    trackId: 12,
    trackDistance: 174,
    trackDirection: 1,
    posX: 0,
    posY: 0,
    posZ: 0,
    mileage: 1240,
    orientationForward: true,
    smoke: 0,
    active: false,
    axisNamesKnown: true,
    axisNames: { 1: 'Tür links', 2: 'Tür rechts' },
    axisValues: { 1: 0, 2: 100 },
    surfaceTexts: { 1: 'M4', 2: 'Hauptbahnhof' },
    textureNames: { 1: 'Linie', 2: 'Ziel' },
    rotX: 0,
    rotY: 0,
    rotZ: 0,
    trackType: TrackType.Tram,
    xmlModel: 'Resourcen/Rollmaterial/Strassenbahn/Flexity.3dm',
  },
];

const readyDashboard: TrainDashboardPanelModel = {
  cameraSources: [],
  canShowTrainAxes: true,
  controls: {
    couplingFront: 0,
    couplingRear: 0,
    lights: {},
    onCouplingChange: noop,
    onLightChange: noop,
  },
  mergedAxisGroups: [
    {
      name: 'Tür links',
      value: 0,
      targets: [
        {
          rollingStockName: 'Flexity 301 A',
          axisNumber: 1,
          axisName: 'Tür links',
          axisNamesKnown: true,
          value: 0,
        },
        {
          rollingStockName: 'Flexity 301 B',
          axisNumber: 1,
          axisName: 'Tür links',
          axisNamesKnown: true,
          value: 0,
        },
      ],
    },
    {
      name: 'Tür rechts',
      value: 100,
      targets: [
        {
          rollingStockName: 'Flexity 301 A',
          axisNumber: 2,
          axisName: 'Tür rechts',
          axisNamesKnown: true,
          value: 100,
        },
        {
          rollingStockName: 'Flexity 301 B',
          axisNumber: 2,
          axisName: 'Tür rechts',
          axisNamesKnown: true,
          value: 100,
        },
      ],
    },
  ],
  onCameraSelect: noop,
  onMergedAxisCommit: noop,
  onSpeedCommit: noop,
  rollingStock,
  selectedRollingStockName: 'Flexity 301 A',
  selectedTrainName: train.id,
  status: 'ready',
  train,
  trainSelected: true,
  transit: {
    line: 'M4',
    destination: 'Hauptbahnhof',
    nextStations: train.nextStations ?? [],
  },
};

const meta = {
  title: 'Screens/Routes/Companion',
  component: CompanionPage,
  parameters: {
    layout: 'fullscreen',
  },
  decorators: [
    (Story) => (
      <MemoryRouter initialEntries={['/companion']}>
        <Story />
      </MemoryRouter>
    ),
  ],
} satisfies Meta<typeof CompanionPage>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Ready: Story = {
  args: {
    dashboard: readyDashboard,
    transitTrafficType: 'TRAM',
  },
};

export const Empty: Story = {
  args: {
    dashboard: { status: 'empty' },
  },
};

export const Loading: Story = {
  args: {
    dashboard: { status: 'loading' },
  },
};
