import Paper from '@mui/material/Paper';
import Step from '@mui/material/Step';
import StepButton from '@mui/material/StepButton';
import Stepper from '@mui/material/Stepper';
import useMediaQuery from '@mui/material/useMediaQuery';
import { useTheme } from '@mui/material/styles';
import type { SxProps, Theme } from '@mui/material/styles';

export interface WizardStep {
  label: string;
}

export interface WizardStepperProps {
  activeStep: number;
  steps: WizardStep[];
  onStepSelect: (stepIndex: number) => void;
  sx?: SxProps<Theme>;
}

function WizardStepper({ activeStep, onStepSelect, steps, sx }: WizardStepperProps) {
  const theme = useTheme();
  const isTabletOrBelow = useMediaQuery(theme.breakpoints.down('md'));

  return (
    <Paper sx={[{ p: 2 }, ...(Array.isArray(sx) ? sx : sx ? [sx] : [])]}>
      <Stepper
        activeStep={activeStep}
        alternativeLabel={!isTabletOrBelow}
        nonLinear
        orientation={isTabletOrBelow ? 'vertical' : 'horizontal'}
      >
        {steps.map((step, index) => (
          <Step key={step.label}>
            <StepButton onClick={() => onStepSelect(index)}>{step.label}</StepButton>
          </Step>
        ))}
      </Stepper>
    </Paper>
  );
}

export default WizardStepper;
