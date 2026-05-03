import type { ReactNode } from 'react';
import DirectionsTransitIcon from '@mui/icons-material/DirectionsTransit';
import Chip from '@mui/material/Chip';
import BackgroundImageCard from '../../../shared/components/cards/BackgroundImageCard';
import type { TransitStationAppDto } from '@ce/web-shared';

interface TransitStationCardProps {
  station: TransitStationAppDto;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

function TransitStationCard({ station, selected, onSelect, children }: TransitStationCardProps) {
  return (
    <BackgroundImageCard
      title={station.name ?? station.id}
      selected={selected}
      expanded={selected}
      setExpanded={() => onSelect()}
      additionalChips={[
        <Chip
          key="platform-count"
          icon={<DirectionsTransitIcon />}
          label={`${station.platforms?.length ?? 0} Steige`}
          variant="outlined"
        />,
      ]}
    >
      {children}
    </BackgroundImageCard>
  );
}

export default TransitStationCard;
