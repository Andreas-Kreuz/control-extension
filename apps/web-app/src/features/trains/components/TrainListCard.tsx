import type { ReactNode } from 'react';
import { TrainListAppDto, TrainType } from '@ce/web-shared';
import BackgroundImageCard from '../../../shared/components/cards/BackgroundImageCard';
import { trainIconFor } from '../lib/trainIconFor';
import { getTrainChips } from '../lib/trainDetails';

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

interface TrainListCardProps {
  train: TrainListAppDto;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

const TrainListCard = ({ train, selected, onSelect, children }: TrainListCardProps) => {
  const additionalChips = getTrainChips(train);

  return (
    <BackgroundImageCard
      title={train.id}
      additionalChips={additionalChips}
      icon={getIconName(train.trainType)}
      selected={selected}
      expanded={selected}
      setExpanded={() => onSelect()}
    >
      {children}
    </BackgroundImageCard>
  );
};

export default TrainListCard;
