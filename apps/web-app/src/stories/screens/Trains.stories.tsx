import type { Meta, StoryObj } from '@storybook/react';
import { TrackType, TrainListDto, TrainType } from '@ce/web-shared';
import { PropsWithChildren, useReducer } from 'react';
import { MemoryRouter } from 'react-router-dom';
import Trains from '../../mod/trains/Trains';
import { Action, TrainContext, TrainDispatchContext } from '../../mod/trains/TrainProvider';

const trains: TrainListDto[] = [
  {
    id: 'IC 2049',
    name: 'Intercity 2049',
    route: 'Nordring',
    line: 'IC',
    destination: 'Leipzig Hbf',
    via: 'Messe',
    firstRollingStockName: 'BR 146',
    lastRollingStockName: 'Bpmz 2',
    trainType: TrainType.TrainElectric,
    trackType: TrackType.Rail,
    rollingStockCount: 7,
    movesForward: true,
  },
  {
    id: 'M4-12',
    name: 'M4 Innenstadt',
    route: 'Stadtring',
    line: 'M4',
    destination: 'Hauptbahnhof',
    via: 'Marktplatz',
    firstRollingStockName: 'Flexity 301',
    lastRollingStockName: 'Flexity 301',
    trainType: TrainType.Tram,
    trackType: TrackType.Tram,
    rollingStockCount: 1,
    movesForward: true,
  },
  {
    id: 'Bus 87',
    name: 'Stadtbus 87',
    route: 'Ringlinie',
    line: '87',
    destination: 'ZOB',
    via: 'Rathaus',
    firstRollingStockName: 'MAN Lion City',
    lastRollingStockName: 'MAN Lion City',
    trainType: TrainType.Bus,
    trackType: TrackType.Road,
    rollingStockCount: 1,
    movesForward: true,
  },
  {
    id: 'LKW 15',
    name: 'Lieferverkehr 15',
    route: 'Gewerbepark',
    line: '',
    destination: 'Logistikzentrum',
    via: '',
    firstRollingStockName: 'Scania S',
    lastRollingStockName: 'Scania S',
    trainType: TrainType.Truck,
    trackType: TrackType.Road,
    rollingStockCount: 1,
    movesForward: true,
  },
];

const reducer = (
  state: { trackType: TrackType; trainList: TrainListDto[] },
  action: Action,
) => {
  switch (action.type) {
    case 'set track type':
      return { ...state, trackType: action.trackType };
    case 'trains updated':
      return state;
    default:
      return state;
  }
};

const TrainsStoryShell = ({ children }: PropsWithChildren) => {
  const [state, dispatch] = useReducer(reducer, {
    trackType: TrackType.Road,
    trainList: trains,
  });

  return (
    <MemoryRouter initialEntries={['/trains']}>
      <TrainContext.Provider value={state}>
        <TrainDispatchContext.Provider value={dispatch}>{children}</TrainDispatchContext.Provider>
      </TrainContext.Provider>
    </MemoryRouter>
  );
};

const meta = {
  title: 'Screens/Routes/Trains',
  component: Trains,
  parameters: {
    layout: 'fullscreen',
  },
  decorators: [
    (Story) => (
      <TrainsStoryShell>
        <Story />
      </TrainsStoryShell>
    ),
  ],
} satisfies Meta<typeof Trains>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Desktop: Story = {};

export const Mobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
