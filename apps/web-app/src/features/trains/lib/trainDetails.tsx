import { TrainListDto } from '@ce/web-shared';
import BadgeIcon from '@mui/icons-material/Badge';
import DirectionsIcon from '@mui/icons-material/Directions';
import LabelIcon from '@mui/icons-material/Label';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import RouteIcon from '@mui/icons-material/Route';
import Chip from '@mui/material/Chip';

export const getTrainElements = (train: TrainListDto) => [
  { key: 1, on: train.id, icon: BadgeIcon, primary: train.id, description: 'Name des Fahrzeugs in EEP' },
  { key: 2, on: train.route, icon: DirectionsIcon, primary: train.route, description: 'Route aus EEP' },
  { key: 3, on: train.line, icon: RouteIcon, primary: train.line || '-', description: 'Linie' },
  {
    key: 4,
    on: train.destination,
    icon: LocationOnIcon,
    primary: (train.destination && train.destination + (train.via ? ' über ' + train.via : '')) || '-',
    description: 'Ziel der Linie',
  },
  { key: 'Zugname', on: train.name, icon: LabelIcon, primary: train.name || '-', description: 'Name des Zuges' },
];

export const getTrainChips = (train: TrainListDto) => {
  return getTrainElements(train)
    .filter((element) => element.key === 2 && element.on)
    .map((element) => <Chip key={element.key} variant="outlined" label={element.primary} icon={<element.icon />} />);
};
