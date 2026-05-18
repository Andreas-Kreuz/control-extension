import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';

export interface IntersectionWizardNavigationProps {
  activeStep: number;
  nextDisabled: boolean;
  onBack: () => void;
  onNext: () => void;
}

function IntersectionWizardNavigation({ activeStep, nextDisabled, onBack, onNext }: IntersectionWizardNavigationProps) {
  return (
    <Stack direction="row" spacing={1}>
      <Button disabled={activeStep === 0} onClick={onBack}>
        Zurück
      </Button>
      <Button variant="contained" disabled={nextDisabled} onClick={onNext}>
        Weiter
      </Button>
    </Stack>
  );
}

export default IntersectionWizardNavigation;
