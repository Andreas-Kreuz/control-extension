import Autocomplete from '@mui/material/Autocomplete';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import type { DataSlotAppDto, IntersectionWizardDraftAppDto } from '@ce/web-shared';
import { ExplainedCheckbox } from '../../../../shared/components/checkbox';

export interface IntersectionWizardSettingsStepProps {
  cameraOptions: string[];
  draft: IntersectionWizardDraftAppDto;
  showAdvancedIntersectionSettings: boolean;
  storageSlotOptions: DataSlotAppDto[];
  onDraftPatch: (patch: Partial<IntersectionWizardDraftAppDto>) => void;
  onIntersectionNameChange: (name: string) => void;
  onLuaVariableNameChange: (luaVariableName: string) => void;
  onOptionalPositiveNumber: (value: string) => number | undefined;
  onShowAdvancedIntersectionSettingsChange: (checked: boolean) => void;
}

function IntersectionWizardSettingsStep({
  cameraOptions,
  draft,
  onDraftPatch,
  onIntersectionNameChange,
  onLuaVariableNameChange,
  onOptionalPositiveNumber,
  onShowAdvancedIntersectionSettingsChange,
  showAdvancedIntersectionSettings,
  storageSlotOptions,
}: IntersectionWizardSettingsStepProps) {
  return (
    <Stack spacing={2}>
      <TextField
        label="Kreuzungsname"
        value={draft.name}
        onChange={(event) => onIntersectionNameChange(event.target.value)}
        helperText="Wie soll diese Kreuzung heißen, z.B. Bahnhofsstraße - Hauptstraße."
        fullWidth
      />
      <TextField
        label="Lua-Variable"
        value={draft.luaVariableName}
        onChange={(event) => onLuaVariableNameChange(event.target.value)}
        helperText="Diese Variable wird im Lua-Code verwendet, empfohlen: c1 oder c2 usw."
        fullWidth
      />
      <FormControl fullWidth>
        <InputLabel id="intersection-storage-slot-label">Kreuzungs-Speicherplatz</InputLabel>
        <Select
          labelId="intersection-storage-slot-label"
          label="Kreuzungs-Speicherplatz"
          value={draft.intersectionEepSaveId ?? -1}
          onChange={(event) => onDraftPatch({ intersectionEepSaveId: Number(event.target.value) })}
        >
          <MenuItem value={-1}>Nicht speichern (-1)</MenuItem>
          {storageSlotOptions.map((slot) => (
            <MenuItem key={slot.id} value={Number(slot.id)}>
              {slot.id} {slot.name}
            </MenuItem>
          ))}
        </Select>
        <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, ml: 1.75 }}>
          Optional: Hinterlegt Informationen zur Kreuzung mit EEPSaveData.
        </Typography>
      </FormControl>
      <Autocomplete
        multiple
        freeSolo
        options={cameraOptions}
        value={draft.staticCams ?? []}
        filterSelectedOptions
        onChange={(_event, value) =>
          onDraftPatch({
            staticCams: Array.from(new Set(value.map((cameraName) => cameraName.trim()).filter(Boolean))),
          })
        }
        renderInput={(params) => (
          <TextField
            {...params}
            label="Statische Kameras"
            helperText="Optional: Wähle Kameras für diese Kreuzung aus, um schnell hinzuspringen."
          />
        )}
      />
      <TextField
        label="Tipp-Text-Immobilie"
        value={draft.tippStructure ?? ''}
        onChange={(event) => onDraftPatch({ tippStructure: event.target.value || undefined })}
        placeholder="#5573_Schaltschrank-Ampel2_SK2"
        helperText="Optional: Hier wird auf Wunsch die Phase der Kreuzung angezeigt."
        fullWidth
      />
      <ExplainedCheckbox
        checked={showAdvancedIntersectionSettings}
        label="Erweiterte Einstellungen"
        onChange={(_event, checked) => onShowAdvancedIntersectionSettingsChange(checked)}
      />
      {showAdvancedIntersectionSettings && (
        <Stack spacing={2} sx={{ pl: { xs: 0, sm: 4 } }}>
          <TextField
            label="Standard-Grünzeit (s)"
            type="number"
            value={draft.greenTimeSeconds ?? ''}
            onChange={(event) => onDraftPatch({ greenTimeSeconds: onOptionalPositiveNumber(event.target.value) })}
            helperText="Optional: Leeres Feld nutzt die Standardzeit der Runtime."
            size="small"
            inputProps={{ min: 1, 'aria-label': 'Standard-Grünzeit' }}
            fullWidth
          />
          <ExplainedCheckbox
            checked={draft.supportPedestrianSignals ?? false}
            label="Fußgängerampeln unterstützen"
            explanation="Optional: Ermöglicht die Verwendung von Fußgängerampeln und -furten."
            onChange={(_event, checked) => onDraftPatch({ supportPedestrianSignals: checked })}
          />
          <ExplainedCheckbox
            checked={draft.supportMultipleLaneSignals ?? false}
            label="Mehrere Ampelbilder für eine Fahrspur unterstützen"
            explanation="Optional: Ermöglicht auf einer Spur unterschiedliche Ampeln, z.B. Rechtsabbiegerpfeile oder Abbiegesignale für die Tram."
            onChange={(_event, checked) => onDraftPatch({ supportMultipleLaneSignals: checked })}
          />
          <ExplainedCheckbox
            checked={draft.manualLuaVariableNames ?? false}
            label="Lua-Variablennamen selbst festlegen"
            explanation="Optional: Vergib die Variablennamen für die Fahrspuren und Signalgruppen selbst."
            onChange={(_event, checked) => onDraftPatch({ manualLuaVariableNames: checked })}
          />
          <ExplainedCheckbox
            checked={draft.individualLanePhaseSettings ?? false}
            label="Individuelle Einstellungen für Fahrspuren und Phasen"
            explanation="Optional: Multiplikator für erkannte Fahrzeuge, Länge einzelner Phasen."
            onChange={(_event, checked) => onDraftPatch({ individualLanePhaseSettings: checked })}
          />
          <ExplainedCheckbox
            checked={draft.showLuaCodeImmediately ?? true}
            label="Lua-Code sofort anzeigen"
            explanation="Optional: Der Lua Code wird bereits vor der Zusammenfassung in allen Schritten angezeigt."
            onChange={(_event, checked) => onDraftPatch({ showLuaCodeImmediately: checked })}
          />
        </Stack>
      )}
    </Stack>
  );
}

export default IntersectionWizardSettingsStep;
