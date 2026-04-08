import TrainCamerasView from './TrainCamerasView';
import TrainInformationView from './TrainInformationView';
import TrainLineInformationView from './TrainLineInformationView';
import TrainRollingStockView from './TrainRollingStockView';
import useTrainDynamic from './useTrainDynamic';
import useTrainRollingStock from './useTrainRollingStock';
import { TrainListDto } from '@ce/web-shared';
import BadgeIcon from '@mui/icons-material/Badge';
import DirectionsIcon from '@mui/icons-material/Directions';
import LabelIcon from '@mui/icons-material/Label';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import RouteIcon from '@mui/icons-material/Route';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import { useState } from 'react';
import useTransitSettings from '../lines/useTransitSettings';

export const getTrainChips = (t: TrainListDto) => {
  const elements = getTrainElements(t).filter((el) => el.key !== 1 && el.on);
  return elements.map((el) => <Chip key={el.key} variant="outlined" label={el.primary} icon={<el.icon />} />);
};

export const getTrainElements = (t: TrainListDto) => [
  { key: 1, on: t.id, icon: BadgeIcon, primary: t.id, description: 'Name des Fahrzeugs in EEP' },
  { key: 2, on: t.route, icon: DirectionsIcon, primary: t.route, description: 'Route aus EEP' },
  { key: 3, on: t.line, icon: RouteIcon, primary: t.line || '-', description: 'Linie' },
  {
    key: 4,
    on: t.destination,
    icon: LocationOnIcon,
    primary: (t.destination && t.destination + (t.via ? ' über ' + t.via : '')) || '-',
    description: 'Ziel der Linie',
  },
  { key: 'Zugname', on: t.name, icon: LabelIcon, primary: t.name || '-', description: 'Name des Zuges' },
];

const TrainDetails = (props: { train: TrainListDto }) => {
  const [activeTab, setActiveTab] = useState(0);
  const t = props.train;
  const trainDynamic = useTrainDynamic(t.id);
  const rollingStock = useTrainRollingStock(t.id);
  const transitSettings = useTransitSettings();
  const showTransitTab = Boolean(transitSettings);
  const currentLine = trainDynamic?.line ?? t.line ?? '-';
  const currentDestination = trainDynamic?.destination ?? t.destination ?? '-';
  const tabs = [
    { key: 'information', label: 'Information' },
    { key: 'rolling-stock', label: 'RollingStock' },
    { key: 'kameras', label: 'Kameras' },
    ...(showTransitTab ? [{ key: 'linieninformationen', label: 'Linieninformationen' }] : []),
  ];

  const safeTabIndex = Math.min(activeTab, tabs.length - 1);

  return (
    <Stack spacing={0}>
      <Tabs
        value={safeTabIndex}
        onChange={(_event, value: number) => setActiveTab(value)}
        variant="scrollable"
        allowScrollButtonsMobile
        sx={{ minHeight: 44 }}
      >
        {tabs.map((tab) => (
          <Tab key={tab.key} label={tab.label} />
        ))}
      </Tabs>
      <Divider />
      {tabs[safeTabIndex]?.key === 'information' && (
        <TrainInformationView train={t} targetSpeed={trainDynamic?.targetSpeed} />
      )}
      {tabs[safeTabIndex]?.key === 'rolling-stock' && <TrainRollingStockView rollingStock={rollingStock} />}
      {tabs[safeTabIndex]?.key === 'kameras' && (
        <TrainCamerasView trainName={t.id} rollingStockName={t.firstRollingStockName} />
      )}
      {tabs[safeTabIndex]?.key === 'linieninformationen' && (
        <TrainLineInformationView line={currentLine} destination={currentDestination} />
      )}
    </Stack>
  );
};

export default TrainDetails;
