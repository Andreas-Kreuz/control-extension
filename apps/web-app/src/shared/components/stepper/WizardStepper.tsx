import Paper from '@mui/material/Paper';
import Badge from '@mui/material/Badge';
import Step from '@mui/material/Step';
import StepButton from '@mui/material/StepButton';
import Stepper from '@mui/material/Stepper';
import Typography from '@mui/material/Typography';
import useMediaQuery from '@mui/material/useMediaQuery';
import { useTheme } from '@mui/material/styles';
import type { SxProps, Theme } from '@mui/material/styles';

export interface WizardStep {
  errorCount?: number;
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
            <StepButton onClick={() => onStepSelect(index)}>
              <Badge
                badgeContent={step.errorCount}
                color="error"
                invisible={!step.errorCount}
                sx={{ '& .MuiBadge-badge': { right: -12, top: 2 } }}
              >
                <Typography component="span" color={step.errorCount ? 'error' : 'inherit'}>
                  {step.label}
                </Typography>
              </Badge>
            </StepButton>
          </Step>
        ))}
      </Stepper>
    </Paper>
  );
}

export default WizardStepper;
