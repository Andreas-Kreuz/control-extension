import Stack from '@mui/material/Stack';
import EastIcon from '@mui/icons-material/East';
import NorthIcon from '@mui/icons-material/North';
import NorthEastIcon from '@mui/icons-material/NorthEast';
import NorthWestIcon from '@mui/icons-material/NorthWest';
import SouthIcon from '@mui/icons-material/South';
import SouthEastIcon from '@mui/icons-material/SouthEast';
import SouthWestIcon from '@mui/icons-material/SouthWest';
import WestIcon from '@mui/icons-material/West';
import type { IntersectionWizardApproach } from '@ce/web-shared';

export const approachLabels = {
  NORTH: 'Norden',
  NORTH_EAST: 'Nordost',
  EAST: 'Osten',
  SOUTH_EAST: 'Südost',
  SOUTH: 'Süden',
  SOUTH_WEST: 'Südwest',
  WEST: 'Westen',
  NORTH_WEST: 'Nordwest',
} satisfies Record<IntersectionWizardApproach, string>;

export const approaches = Object.keys(approachLabels) as IntersectionWizardApproach[];

const approachIcons = {
  NORTH: SouthIcon,
  NORTH_EAST: SouthWestIcon,
  EAST: WestIcon,
  SOUTH_EAST: NorthWestIcon,
  SOUTH: NorthIcon,
  SOUTH_WEST: NorthEastIcon,
  WEST: EastIcon,
  NORTH_WEST: SouthEastIcon,
} satisfies Record<IntersectionWizardApproach, typeof NorthIcon>;

function Approach(props: { approach: IntersectionWizardApproach }) {
  const ApproachIcon = approachIcons[props.approach];
  return (
    <Stack direction="row" spacing={1} alignItems="center">
      <ApproachIcon fontSize="small" />
      <span>{approachLabels[props.approach]}</span>
    </Stack>
  );
}

export default Approach;
