import Button from '@mui/material/Button';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { FeedbackMessage } from '../../../../shared/components/feedback';

export interface IntersectionWizardStartStepProps {
  isLoadingIntersection: boolean;
  sendPreparationSettings: boolean;
  onSendPreparationSettingsChange: (checked: boolean) => void;
  onStartNewIntersection: () => void;
}

function IntersectionWizardStartStep({
  isLoadingIntersection,
  onSendPreparationSettingsChange,
  onStartNewIntersection,
  sendPreparationSettings,
}: IntersectionWizardStartStepProps) {
  if (isLoadingIntersection) {
    return (
      <Stack spacing={2} alignItems="flex-start">
        <Typography variant="h5">Kreuzung wird geladen</Typography>
        <Typography color="text.secondary">
          Die bestehende Kreuzung wird aus dem aktuellen Anlagenzustand übernommen.
        </Typography>
      </Stack>
    );
  }

  return (
    <Stack spacing={2} alignItems="flex-start">
      <Typography variant="h5">Neue Kreuzung erstellen</Typography>
      <Typography color="text.secondary">
        Starte den Assistenten, um Fahrspuren, Fahrspur-Ampeln, Signalgruppen und Verkehrsphasen zu erfassen.
      </Typography>
      <FeedbackMessage severity="info">
        Platziere eine Ampel auf allen Fahrspuren, die gesteuert werden sollen. Willst du eine Fahrspur durch
        unterschiedliche Ampeln in verschiedene Abbiegerichtungen steuern, dann platziere ein unsichtbares Signal.
      </FeedbackMessage>
      <Button
        aria-pressed={sendPreparationSettings}
        color="secondary"
        variant={sendPreparationSettings ? 'contained' : 'outlined'}
        onClick={() => onSendPreparationSettingsChange(!sendPreparationSettings)}
      >
        Signal-IDs und Modellinformationen in EEP anzeigen: {sendPreparationSettings ? 'Ja' : 'Nein'}
      </Button>
      {sendPreparationSettings && (
        <FeedbackMessage severity="warning">
          Beim Start werden Signal-IDs und Modellinformationen als Tipptexte in EEP angezeigt. Das überschreibt
          vorhandene Tipptexte an Signalen.
        </FeedbackMessage>
      )}
      <Button variant="contained" onClick={onStartNewIntersection}>
        Neue Kreuzung erstellen
      </Button>
    </Stack>
  );
}

export default IntersectionWizardStartStep;
