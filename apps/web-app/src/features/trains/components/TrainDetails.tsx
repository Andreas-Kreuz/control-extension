import { useState } from 'react';
import { TrainListAppDto } from '@ce/web-shared';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import TrainCamerasView from './TrainCamerasView';
import TrainInformationView from './TrainInformationView';
import TrainLineView from './TrainLineView';
import RollingStockView from './RollingStockView';
import useTransitTrain from '../hooks/useTransitTrain';
import useTrainDynamic from '../hooks/useTrainDynamic';
import useTrainRollingStock from '../hooks/useTrainRollingStock';
import useTransitSettings from '../../lines/hooks/useTransitSettings';

const TrainDetails = (props: { train: TrainListAppDto }) => {
  const [activeTab, setActiveTab] = useState(0);
  const train = props.train;
  const trainDynamic = useTrainDynamic(train.id);
  const transitTrain = useTransitTrain(train.id);
  const rollingStock = useTrainRollingStock(train.id);
  const transitSettings = useTransitSettings();
  const showTransitTab = Boolean(transitSettings);
  const currentLine = transitTrain?.line ?? train.line ?? '-';
  const currentDestination = transitTrain?.destination ?? train.destination ?? '-';
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
        <TrainInformationView
          train={train}
          {...(trainDynamic?.targetSpeed !== undefined ? { targetSpeed: trainDynamic.targetSpeed } : {})}
        />
      )}
      {tabs[safeTabIndex]?.key === 'rolling-stock' && <RollingStockView rollingStock={rollingStock} />}
      {tabs[safeTabIndex]?.key === 'kameras' && (
        <TrainCamerasView trainName={train.id} rollingStockName={train.firstRollingStockName} />
      )}
      {tabs[safeTabIndex]?.key === 'linieninformationen' && (
        <TrainLineView
          line={currentLine}
          destination={currentDestination}
          nextStations={transitTrain?.nextStations ?? []}
        />
      )}
    </Stack>
  );
};

export default TrainDetails;
