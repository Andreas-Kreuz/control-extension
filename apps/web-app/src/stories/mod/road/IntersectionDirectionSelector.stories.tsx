import { useState } from 'react';
import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { alpha } from '@mui/material/styles';
import StraightIcon from '@mui/icons-material/Straight';
import TurnLeftIcon from '@mui/icons-material/TurnLeft';
import TurnRightIcon from '@mui/icons-material/TurnRight';
import TurnSlightLeftIcon from '@mui/icons-material/TurnSlightLeft';
import TurnSlightRightIcon from '@mui/icons-material/TurnSlightRight';
import type { Meta, StoryObj } from '@storybook/react';
import type { IntersectionWizardTurnDirection } from '@ce/web-shared';

const directions: IntersectionWizardTurnDirection[] = ['LEFT', 'HALF_LEFT', 'STRAIGHT', 'HALF_RIGHT', 'RIGHT'];

const directionLabels: Record<IntersectionWizardTurnDirection, string> = {
  LEFT: 'Links',
  HALF_LEFT: 'Halblinks',
  STRAIGHT: 'Geradeaus',
  HALF_RIGHT: 'Halbrechts',
  RIGHT: 'Rechts',
};

const directionIcons = {
  LEFT: TurnLeftIcon,
  HALF_LEFT: TurnSlightLeftIcon,
  STRAIGHT: StraightIcon,
  HALF_RIGHT: TurnSlightRightIcon,
  RIGHT: TurnRightIcon,
} satisfies Record<IntersectionWizardTurnDirection, typeof TurnLeftIcon>;

const primaryDisabledOptions = [
  { label: 'Primary 45%', alpha: 0.45 },
  { label: 'Primary 55%', alpha: 0.55 },
  { label: 'Primary 60%', alpha: 0.6 },
  { label: 'Primary 65%', alpha: 0.65 },
  { label: 'Primary 75%', alpha: 0.75 },
];

function toggleDirectionSelection(
  selectedDirections: IntersectionWizardTurnDirection[],
  direction: IntersectionWizardTurnDirection,
) {
  if (selectedDirections.includes(direction)) {
    return selectedDirections.filter((selectedDirection) => selectedDirection !== direction);
  }
  return [...selectedDirections, direction];
}

function IntersectionDirectionSelectorStory() {
  const [selectedDirections, setSelectedDirections] = useState<IntersectionWizardTurnDirection[]>([
    'STRAIGHT',
    'RIGHT',
  ]);

  return (
    <Stack spacing={3} sx={{ maxWidth: 720 }}>
      <Box>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
          Abbiegerichtung - Success aktiv
        </Typography>
        <ToggleButtonGroup color="success" value={selectedDirections} size="small">
          {directions.map((direction) => {
            const DirectionIcon = directionIcons[direction];

            return (
              <ToggleButton
                key={direction}
                value={direction}
                aria-label={directionLabels[direction]}
                title={directionLabels[direction]}
                onClick={() => setSelectedDirections((current) => toggleDirectionSelection(current, direction))}
                sx={{
                  px: 1.5,
                  color: 'grey.900',
                  '&.Mui-selected, &.Mui-selected:hover': {
                    color: 'common.white',
                    bgcolor: 'success.dark',
                  },
                }}
              >
                <DirectionIcon fontSize="small" />
              </ToggleButton>
            );
          })}
        </ToggleButtonGroup>
      </Box>
      <Typography variant="body2" color="text.secondary">
        Auswahl: {selectedDirections.map((direction) => directionLabels[direction]).join(', ')}
      </Typography>
      <Box>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
          Primary aktiv
        </Typography>
        <ToggleButtonGroup color="primary" value={selectedDirections} size="small">
          {directions.map((direction) => {
            const DirectionIcon = directionIcons[direction];

            return (
              <ToggleButton
                key={direction}
                value={direction}
                aria-label={`Primary ${directionLabels[direction]}`}
                title={directionLabels[direction]}
                onClick={() => setSelectedDirections((current) => toggleDirectionSelection(current, direction))}
                sx={{
                  px: 1.5,
                  color: 'grey.900',
                  '&.Mui-selected, &.Mui-selected:hover': {
                    color: 'common.white',
                    bgcolor: 'primary.main',
                    borderColor: 'primary.main',
                  },
                }}
              >
                <DirectionIcon fontSize="small" />
              </ToggleButton>
            );
          })}
        </ToggleButtonGroup>
      </Box>
      <Box>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
          Primary disabled Varianten
        </Typography>
        <Stack spacing={1.25}>
          {primaryDisabledOptions.map((option) => (
            <Stack key={option.label} direction="row" spacing={1.5} alignItems="center">
              <Typography variant="caption" color="text.secondary" sx={{ width: 88 }}>
                {option.label}
              </Typography>
              <ToggleButtonGroup value={selectedDirections} size="small">
                {directions.map((direction) => {
                  const DirectionIcon = directionIcons[direction];
                  const selected = selectedDirections.includes(direction);

                  return (
                    <ToggleButton
                      key={direction}
                      value={direction}
                      disabled
                      aria-label={`${option.label} ${directionLabels[direction]}`}
                      title={directionLabels[direction]}
                      sx={{
                        px: 1.5,
                        '&.Mui-disabled': {
                          color: selected ? 'common.white' : 'text.disabled',
                          borderColor: selected ? (theme) => alpha(theme.palette.primary.main, 0.28) : undefined,
                        },
                        '&.Mui-disabled.Mui-selected': {
                          color: 'common.white',
                          bgcolor: (theme) => alpha(theme.palette.primary.main, option.alpha),
                          borderColor: (theme) => alpha(theme.palette.primary.main, 0.28),
                          opacity: 1,
                        },
                      }}
                    >
                      <DirectionIcon fontSize="small" />
                    </ToggleButton>
                  );
                })}
              </ToggleButtonGroup>
            </Stack>
          ))}
        </Stack>
      </Box>
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Direction Selector',
  component: IntersectionDirectionSelectorStory,
} satisfies Meta<typeof IntersectionDirectionSelectorStory>;

export default meta;
type Story = StoryObj<typeof meta>;

export const GreenSelectedWhiteUnselected: Story = {};
