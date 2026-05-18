import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { FeedbackMessage } from '../../../../shared/components/feedback';

export interface IntersectionWizardSummaryStepProps {
  status: string;
}

function IntersectionWizardSummaryStep({ status }: IntersectionWizardSummaryStepProps) {
  return (
    <Stack spacing={2}>
      {status && <FeedbackMessage severity="success">{status}</FeedbackMessage>}
      <Typography variant="body2" color="text.secondary">
        Der fertige Lua-Code kann jetzt über die Kopierbuttons in der Codevorschau übernommen werden.
      </Typography>
    </Stack>
  );
}

export default IntersectionWizardSummaryStep;
