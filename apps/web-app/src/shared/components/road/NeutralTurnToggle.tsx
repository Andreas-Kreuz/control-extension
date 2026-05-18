import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import StraightIcon from '@mui/icons-material/Straight';
import TurnLeftIcon from '@mui/icons-material/TurnLeft';
import TurnRightIcon from '@mui/icons-material/TurnRight';
import TurnSlightLeftIcon from '@mui/icons-material/TurnSlightLeft';
import TurnSlightRightIcon from '@mui/icons-material/TurnSlightRight';
import type { IntersectionWizardTurnDirection } from '@ce/web-shared';

export const turnDirectionLabels = {
  LEFT: 'Links',
  HALF_LEFT: 'Halblinks',
  STRAIGHT: 'Geradeaus',
  HALF_RIGHT: 'Halbrechts',
  RIGHT: 'Rechts',
} satisfies Record<IntersectionWizardTurnDirection, string>;

export const turnDirections = Object.keys(turnDirectionLabels) as IntersectionWizardTurnDirection[];

export const turnDirectionIcons = {
  LEFT: TurnLeftIcon,
  HALF_LEFT: TurnSlightLeftIcon,
  STRAIGHT: StraightIcon,
  HALF_RIGHT: TurnSlightRightIcon,
  RIGHT: TurnRightIcon,
} satisfies Record<IntersectionWizardTurnDirection, typeof TurnLeftIcon>;

function NeutralTurnToggle(props: { value: IntersectionWizardTurnDirection[] }) {
  return (
    <ToggleButtonGroup
      value={props.value}
      size="small"
      disabled
      sx={{
        flexWrap: 'nowrap',
        '& .MuiToggleButtonGroup-grouped': {
          minHeight: 32,
        },
        '& .MuiToggleButton-root': {
          px: 0.75,
          color: 'text.secondary',
          borderColor: 'divider',
        },
        '& .MuiToggleButton-root.Mui-selected, & .MuiToggleButton-root.Mui-selected:hover': {
          color: 'text.primary',
          bgcolor: 'action.selected',
          borderColor: 'divider',
        },
        '& .MuiToggleButton-root.Mui-disabled': {
          color: 'text.disabled',
          borderColor: 'divider',
        },
        '& .MuiToggleButton-root.Mui-disabled.Mui-selected': {
          color: 'text.secondary',
          bgcolor: 'action.selected',
          borderColor: 'divider',
          opacity: 1,
        },
      }}
    >
      {turnDirections.map((turnDirection) => {
        const TurnDirectionIcon = turnDirectionIcons[turnDirection];
        return (
          <ToggleButton
            key={turnDirection}
            value={turnDirection}
            aria-label={turnDirectionLabels[turnDirection]}
            title={turnDirectionLabels[turnDirection]}
          >
            <TurnDirectionIcon fontSize="small" />
          </ToggleButton>
        );
      })}
    </ToggleButtonGroup>
  );
}

export default NeutralTurnToggle;
