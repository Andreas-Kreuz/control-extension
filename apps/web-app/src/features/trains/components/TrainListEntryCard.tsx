import { lazy } from 'react';
import type { ReactNode } from 'react';
import { TrainListDto, TrainType } from '@ce/web-shared';
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

interface TrainListEntryCardProps {
  train: TrainListDto;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

const TrainListEntryCard = ({ train, selected, onSelect, children }: TrainListEntryCardProps) => {
  const additionalChips = getTrainChips(train);

  return (
    <AppCardBg
      title="Fahrzeug"
      id={train.id}
      additionalChips={additionalChips}
      icon={getIconName(train.trainType)}
      image={getImageName(train.trackType ?? 'train')}
      selected={selected}
      expanded={selected}
      setExpanded={() => onSelect()}
    >
      {children}
    </AppCardBg>
  );
};

export default TrainListEntryCard;
