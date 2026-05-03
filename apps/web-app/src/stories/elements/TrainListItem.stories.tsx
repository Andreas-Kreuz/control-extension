import { TrackType, TrainListAppDto, TrainType } from '@ce/web-shared';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import TrainListItem from '../../features/trains/components/TrainListItem';
import ListLayout from '../../shared/layouts/ListLayout';

const makeTrain = (
  train: Pick<TrainListAppDto, 'id' | 'name' | 'line' | 'destination' | 'trainType' | 'trackType'> &
    Partial<TrainListAppDto>,
): TrainListAppDto => ({
  route: 'Anlage Stadtverkehr',
  via: '',
  firstRollingStockName: train.name,
  lastRollingStockName: train.name,
  rollingStockCount: 1,
  movesForward: true,
  ...train,
});

const trains: TrainListAppDto[] = [
  makeTrain({
    id: 'RE 7142',
    name: 'Regionalexpress 7142',
    line: 'RE7',
    destination: 'Dresden Hbf',
    firstRollingStockName: 'BR 146',
    lastRollingStockName: 'Doppelstockwagen',
    rollingStockCount: 5,
    trainType: TrainType.TrainElectric,
    trackType: TrackType.Rail,
  }),
  makeTrain({
    id: 'D 1829',
    name: 'Dieselzug 1829',
    line: 'RB31',
    destination: 'Waldbrueck',
    firstRollingStockName: 'BR 218',
    lastRollingStockName: 'n-Wagen',
    rollingStockCount: 4,
    trainType: TrainType.TrainDiesel,
    trackType: TrackType.Rail,
  }),
  makeTrain({
    id: 'S 3',
    name: 'S-Bahn 3',
    line: 'S3',
    destination: 'Flughafen',
    firstRollingStockName: 'ET 423',
    lastRollingStockName: 'ET 423',
    rollingStockCount: 2,
    trainType: TrainType.TrainMetro,
    trackType: TrackType.Rail,
  }),
  makeTrain({
    id: 'P 8 Museum',
    name: 'Museumszug P 8',
    line: '',
    destination: 'Betriebswerk',
    firstRollingStockName: 'P 8',
    lastRollingStockName: 'Abteilwagen',
    rollingStockCount: 6,
    trainType: TrainType.TrainSteam,
    trackType: TrackType.Rail,
  }),
  makeTrain({
    id: 'M4-12',
    name: 'M4 Innenstadt',
    line: 'M4',
    destination: 'Hauptbahnhof',
    firstRollingStockName: 'Flexity 301',
    lastRollingStockName: 'Flexity 301',
    trainType: TrainType.Tram,
    trackType: TrackType.Tram,
  }),
  makeTrain({
    id: 'Bus 87',
    name: 'Stadtbus 87',
    line: '87',
    destination: 'ZOB',
    firstRollingStockName: 'MAN Lion City',
    lastRollingStockName: 'MAN Lion City',
    trainType: TrainType.Bus,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'PKW 14',
    name: 'Pendlerverkehr 14',
    line: '',
    destination: 'Parkhaus',
    firstRollingStockName: 'Kompaktwagen',
    lastRollingStockName: 'Kompaktwagen',
    trainType: TrainType.Car,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'PKW 14A',
    name: 'Pendlerverkehr 14A',
    line: '',
    destination: 'Campingplatz',
    firstRollingStockName: 'Kombi',
    lastRollingStockName: 'Wohnanhaenger',
    rollingStockCount: 2,
    trainType: TrainType.CarWithTrailer,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'LKW 15',
    name: 'Lieferverkehr 15',
    line: '',
    destination: 'Logistikzentrum',
    firstRollingStockName: 'Scania S',
    lastRollingStockName: 'Scania S',
    trainType: TrainType.Truck,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'LKW 21',
    name: 'Sattelzug 21',
    line: '',
    destination: 'Containerterminal',
    firstRollingStockName: 'Actros',
    lastRollingStockName: 'Auflieger',
    rollingStockCount: 2,
    trainType: TrainType.TruckWithTrailer,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'KRAD 2',
    name: 'Motorradstreife 2',
    line: '',
    destination: 'Innenstadt',
    firstRollingStockName: 'Motorrad',
    lastRollingStockName: 'Motorrad',
    trainType: TrainType.Motorcycle,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'Rad 5',
    name: 'Radverkehr 5',
    line: '',
    destination: 'Uferweg',
    firstRollingStockName: 'Fahrrad',
    lastRollingStockName: 'Fahrrad',
    trainType: TrainType.Bike,
    trackType: TrackType.Road,
  }),
  makeTrain({
    id: 'FS 1',
    name: 'Faehre 1',
    line: 'F1',
    destination: 'Nordkai',
    firstRollingStockName: 'Faehre',
    lastRollingStockName: 'Faehre',
    trainType: TrainType.Boat,
    trackType: TrackType.Auxiliary,
  }),
  makeTrain({
    id: 'LH 432',
    name: 'Landeanflug 432',
    line: '',
    destination: 'Gate 4',
    firstRollingStockName: 'A320',
    lastRollingStockName: 'A320',
    trainType: TrainType.Plane,
    trackType: TrackType.Auxiliary,
  }),
];

const TrainListItemStory = () => (
  <ListLayout
    items={trains}
    keyExtractor={(train) => train.id}
    getFilterText={(train) => train.id}
    filterLabel="Zugname filtern"
    selectedElement="RE 7142"
    onSelectedElementChange={() => undefined}
    renderListItem={(train, selected, onSelect) => (
      <TrainListItem train={train} selected={selected} onSelect={onSelect} />
    )}
    renderCard={(train, selected, onSelect) => <TrainListItem train={train} selected={selected} onSelect={onSelect} />}
    getDetails={(train) => [
      {
        title: 'Information',
        component: (
          <Typography variant="body2" sx={{ p: 2 }}>
            {train.name} nach {train.destination}
          </Typography>
        ),
      },
    ]}
  />
);

const meta = {
  title: 'Elements/Lists/TrainListItem',
  component: TrainListItemStory,
  parameters: {
    layout: 'fullscreen',
  },
} satisfies Meta<typeof TrainListItemStory>;

export default meta;
type Story = StoryObj<typeof meta>;

export const NewList: Story = {};
