import { lazy, useState } from 'react';
import { TrainListDto, TrainType } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Collapse from '@mui/material/Collapse';
import Divider from '@mui/material/Divider';
import TrainDetails from './TrainDetails';
import { trainIconFor } from '../lib/trainIconFor';
import { getTrainChips } from '../lib/trainDetails';

const AppCardBg = lazy(() => import('../../../shared/ui/AppCardBg'));

const getIconName = (trainType: TrainType): string => {
  const imgName = trainIconFor(trainType);
  return '/assets/' + imgName + '.svg';
};

const getImageName = (trackType: string): string => {
  switch (trackType) {
    case 'road':
      return '/assets/card-img-trains-road.jpg';
    case 'tram':
      return '/assets/card-img-trains-tram.jpg';
    case 'train':
    default:
      return '/assets/card-img-trains-rail.jpg';
  }
};

const TrainListEntryCard = (props: { train: TrainListDto }) => {
  const [expanded, setExpanded] = useState(false);
  const train = props.train;
  const additionalChips = getTrainChips(train);

  return (
    <AppCardBg
      title="Fahrzeug"
      id={train.id}
      additionalChips={additionalChips}
      icon={getIconName(train.trainType)}
      image={getImageName(train.trackType ?? 'train')}
      expanded={expanded}
      setExpanded={setExpanded}
    >
      {expanded && <Divider sx={{ width: 1 }} />}
      <Collapse in={expanded} mountOnEnter unmountOnExit sx={{ flexGrow: 1, width: 1 }}>
        <Box sx={{ flexGrow: 1, width: 1, p: 0 }}>
          <TrainDetails train={train} />
        </Box>
      </Collapse>
    </AppCardBg>
  );
};

export default TrainListEntryCard;
