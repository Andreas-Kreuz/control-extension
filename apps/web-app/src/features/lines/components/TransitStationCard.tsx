import type { ReactNode } from 'react';
import DirectionsTransitIcon from '@mui/icons-material/DirectionsTransit';
import Chip from '@mui/material/Chip';
import AppCardBg from '../../../shared/components/AppCardBg';
import type { TransitStationDto } from '@ce/web-shared';

interface TransitStationCardProps {
  station: TransitStationDto;
  selected: boolean;
  onSelect: () => void;
  children?: ReactNode;
}

function TransitStationCard({ station, selected, onSelect, children }: TransitStationCardProps) {
  return (
    <AppCardBg
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
    </AppCardBg>
  );
}

export default TransitStationCard;
