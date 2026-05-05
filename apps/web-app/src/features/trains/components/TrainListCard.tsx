import type { ReactNode } from 'react';
import { TrainListAppDto } from '@ce/web-shared';
import BackgroundImageCard from '../../../shared/components/cards/BackgroundImageCard';
import { getTrainChips } from '../lib/trainDetails';
import { ListIconSources } from '../lib/trainListIconSources';

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
      icon={ListIconSources[train.trainType]}
      framedIcon
      selected={selected}
      expanded={selected}
      setExpanded={() => onSelect()}
    >
      {children}
    </BackgroundImageCard>
  );
};

export default TrainListCard;
