import Box from '@mui/material/Box';
import FormControl from '@mui/material/FormControl';
import FormHelperText from '@mui/material/FormHelperText';
import InputLabel from '@mui/material/InputLabel';
import OutlinedInput from '@mui/material/OutlinedInput';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import type { IntersectionWizardTurnDirection } from '@ce/web-shared';
import { turnDirectionIcons, turnDirectionLabels, turnDirections } from './NeutralTurnToggle';

function FormTurnToggle(props: {
  errorTexts?: string[];
  infoText?: string;
  label: string;
  onChange: (value: IntersectionWizardTurnDirection[]) => void;
  value: IntersectionWizardTurnDirection[];
}) {
  function toggleTurnDirection(turnDirection: IntersectionWizardTurnDirection) {
    if (props.value.includes(turnDirection)) {
      props.onChange(props.value.filter((selectedTurnDirection) => selectedTurnDirection !== turnDirection));
      return;
    }
    props.onChange([...props.value, turnDirection]);
  }

  const hasError = Boolean(props.errorTexts?.length);
  const helperText = hasError ? props.errorTexts?.join(' ') : props.infoText;

  return (
    <FormControl
      error={hasError}
      sx={
        !hasError && props.infoText
          ? {
              '& .MuiFormHelperText-root': {
                visibility: 'hidden',
              },
              '&:hover .MuiFormHelperText-root, &:focus-within .MuiFormHelperText-root': {
                visibility: 'visible',
              },
            }
          : undefined
      }
    >
      <InputLabel shrink>{props.label}</InputLabel>
      <OutlinedInput
        label={props.label}
        notched
        readOnly
        startAdornment={
          <Box sx={{ display: 'inline-flex', position: 'relative', zIndex: 0 }}>
            <ToggleButtonGroup
              color="primary"
              value={props.value}
              size="medium"
              sx={{
                flexWrap: 'wrap',
                '& .MuiToggleButtonGroup-grouped': {
                  minHeight: 44,
                },
                '& .MuiToggleButton-root': {
                  borderBottom: 0,
                  borderRadius: 0,
                  color: 'grey.900',
                  minWidth: 56,
                  px: 1.75,
                },
                '& .MuiToggleButtonGroup-firstButton': {
                  borderLeft: 0,
                },
                '& .MuiToggleButtonGroup-lastButton': {
                  borderRight: 0,
                },
                '& .MuiToggleButton-root.Mui-selected, & .MuiToggleButton-root.Mui-selected:hover': {
                  color: 'common.white',
                  bgcolor: 'primary.main',
                  borderColor: 'primary.main',
                },
                '& .MuiToggleButton-root.Mui-disabled.Mui-selected': {
                  color: 'common.white',
                  bgcolor: 'primary.main',
                  borderColor: 'primary.main',
                  opacity: 0.65,
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
                    onClick={() => toggleTurnDirection(turnDirection)}
                  >
                    <TurnDirectionIcon fontSize="small" />
                  </ToggleButton>
                );
              })}
            </ToggleButtonGroup>
          </Box>
        }
        sx={{
          alignItems: 'stretch',
          display: 'inline-flex',
          px: 0,
          pb: 0,
          pt: 1.5,
          width: 'max-content',
          maxWidth: 1,
          overflow: 'hidden',
          '& .MuiOutlinedInput-input': {
            display: 'none',
          },
          '& .MuiOutlinedInput-notchedOutline': {
            zIndex: 1,
          },
          '&:focus-within .MuiOutlinedInput-notchedOutline': {
            borderColor: hasError ? 'error.main' : 'primary.main',
            borderWidth: 2,
          },
        }}
      />
      {helperText && (
        <FormHelperText error={hasError} sx={{ ml: 1.75 }}>
          {helperText}
        </FormHelperText>
      )}
    </FormControl>
  );
}

export default FormTurnToggle;
