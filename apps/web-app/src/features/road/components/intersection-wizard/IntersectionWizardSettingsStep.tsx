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
  errorTexts?: {
    greenTimeSeconds?: string[];
    intersectionEepSaveId?: string[];
    luaVariableName?: string[];
    name?: string[];
    staticCams?: string[];
    tippStructure?: string[];
  };
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
  errorTexts = {},
  onDraftPatch,
  onIntersectionNameChange,
  onLuaVariableNameChange,
  onOptionalPositiveNumber,
  onShowAdvancedIntersectionSettingsChange,
  showAdvancedIntersectionSettings,
  storageSlotOptions,
}: IntersectionWizardSettingsStepProps) {
  const hasPedestrianSignalGroups = draft.signalGroups.some((group) => group.trafficType === 'PEDESTRIAN');
  const hasMultipleSignalGroupLanes = draft.lanes.some((lane) => lane.signalGroupAssignments.length > 1);
  const hasStructureLightSignals = draft.ampeln.some(
    (ampel) =>
      ampel.kind === 'STRUCTURE_LIGHT' || (!ampel.signalId?.trim() && (ampel.lightStructures ?? []).length > 0),
  );
  const supportPedestrianSignals = (draft.supportPedestrianSignals ?? false) || hasPedestrianSignalGroups;
  const supportMultipleLaneSignals = (draft.supportMultipleLaneSignals ?? false) || hasMultipleSignalGroupLanes;
  const supportStructureLightSignals = (draft.supportStructureLightSignals ?? false) || hasStructureLightSignals;
  const hasSelectedAdvancedSettings = Boolean(
    draft.greenTimeSeconds !== undefined ||
    draft.manualLuaVariableNames ||
    draft.individualLanePhaseSettings ||
    (draft.showLuaCodeImmediately ?? false) ||
    supportMultipleLaneSignals ||
    supportStructureLightSignals,
  );
  const showAdvancedSettings = showAdvancedIntersectionSettings || hasSelectedAdvancedSettings;

  return (
    <Stack spacing={2}>
      <TextField
        label="Kreuzungsname"
        value={draft.name}
        onChange={(event) => onIntersectionNameChange(event.target.value)}
        error={Boolean(errorTexts.name?.length)}
        helperText={
          errorTexts.name?.length
            ? <strong>{errorTexts.name.join(' ')}</strong>
            : 'Wie soll diese Kreuzung heißen, z.B. Bahnhofsstraße - Hauptstraße.'
        }
        fullWidth
      />
      <FormControl fullWidth error={Boolean(errorTexts.intersectionEepSaveId?.length)}>
        <InputLabel id="intersection-storage-slot-label">Speicherplatz in EEP</InputLabel>
        <Select
          labelId="intersection-storage-slot-label"
          label="Speicherplatz in EEP"
          value={draft.intersectionEepSaveId ?? -1}
          onChange={(event) => onDraftPatch({ intersectionEepSaveId: Number(event.target.value) })}
        >
          <MenuItem value={-1}>Nicht in EEP speichern</MenuItem>
          {storageSlotOptions.map((slot) => (
            <MenuItem key={slot.id} value={Number(slot.id)}>
              {slot.id} {slot.name}
            </MenuItem>
          ))}
        </Select>
        <Typography
          variant="caption"
          color={errorTexts.intersectionEepSaveId?.length ? 'error' : 'text.secondary'}
          sx={{ mt: 0.5, ml: 1.75 }}
        >
          {errorTexts.intersectionEepSaveId?.length
            ? <strong>{errorTexts.intersectionEepSaveId.join(' ')}</strong>
            : 'Optional: Speichert die Einstellungen der Kreuzung in EEP.'}
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
            label="Kameras der Kreuzung"
            error={Boolean(errorTexts.staticCams?.length)}
            helperText={
              errorTexts.staticCams?.length
                ? <strong>{errorTexts.staticCams.join(' ')}</strong>
                : 'Optional: Gib hier alle EEP-Kameras mit denen du schnell zur Kreuzung springen kannst.'
            }
          />
        )}
      />
      <TextField
        label="Phasenanzeige-Immobilie"
        value={draft.tippStructure ?? ''}
        onChange={(event) => onDraftPatch({ tippStructure: event.target.value || undefined })}
        placeholder="#5573_Schaltschrank-Ampel2_SK2"
        error={Boolean(errorTexts.tippStructure?.length)}
        helperText={
          errorTexts.tippStructure?.length
            ? <strong>{errorTexts.tippStructure.join(' ')}</strong>
            : 'Optional: Immobilie, an der die aktuelle Phase als Immobilie angezeigt wird.'
        }
        fullWidth
      />
      <ExplainedCheckbox
        checked={supportPedestrianSignals}
        disabled={hasPedestrianSignalGroups}
        label="Fußgängerfurten verwenden"
        explanation="Aktiviert Ampelgruppen für Fußgängerfurten."
        onChange={(_event, checked) => onDraftPatch({ supportPedestrianSignals: checked })}
      />
      <ExplainedCheckbox
        checked={showAdvancedSettings}
        disabled={hasSelectedAdvancedSettings}
        label="Erweiterte Einstellungen"
        onChange={(_event, checked) => onShowAdvancedIntersectionSettingsChange(checked)}
      />
      {showAdvancedSettings && (
        <Stack spacing={2} sx={{ pl: { xs: 0, sm: 4 } }}>
          <Stack spacing={1.5}>
            <Stack spacing={0.25}>
              <Typography variant="subtitle2">EEP-Optionen</Typography>
              <Typography variant="caption" color="text.secondary">
                Optionen für besondere Ampel- oder Fahrspur-Setups in EEP.
              </Typography>
            </Stack>
            <ExplainedCheckbox
              checked={supportMultipleLaneSignals}
              disabled={hasMultipleSignalGroupLanes}
              label="Mehrere Ampelbilder für eine Fahrspur unterstützen"
              explanation="Optional: Ermöglicht auf einer Spur unterschiedliche Ampeln, z.B. Rechtsabbiegerpfeile oder Abbiegesignale für die Tram."
              onChange={(_event, checked) => onDraftPatch({ supportMultipleLaneSignals: checked })}
            />
            <ExplainedCheckbox
              checked={supportStructureLightSignals}
              disabled={hasStructureLightSignals}
              label="Immobilien-Ampeln benutzen"
              explanation="Zeigt Immobilien Ampeln an."
              onChange={(_event, checked) => onDraftPatch({ supportStructureLightSignals: checked })}
            />
            <ExplainedCheckbox
              checked={draft.individualLanePhaseSettings ?? false}
              label="Individuelle Einstellungen für Fahrspuren und Phasen"
              explanation="Optional: Multiplikator für erkannte Fahrzeuge, Länge einzelner Phasen."
              onChange={(_event, checked) => onDraftPatch({ individualLanePhaseSettings: checked })}
            />
            <TextField
              label="Standard-Grünzeit (s)"
              type="number"
              value={draft.greenTimeSeconds ?? ''}
              onChange={(event) => onDraftPatch({ greenTimeSeconds: onOptionalPositiveNumber(event.target.value) })}
              error={Boolean(errorTexts.greenTimeSeconds?.length)}
              helperText={
                errorTexts.greenTimeSeconds?.length
                  ? <strong>{errorTexts.greenTimeSeconds.join(' ')}</strong>
                  : 'Optional: Leeres Feld nutzt die Standardzeit der Runtime.'
              }
              size="small"
              inputProps={{ min: 1, 'aria-label': 'Standard-Grünzeit' }}
              fullWidth
            />
          </Stack>
          <Stack spacing={1.5}>
            <Stack spacing={0.25}>
              <Typography variant="subtitle2">Lua & Code</Typography>
              <Typography variant="caption" color="text.secondary">
                Technische Einstellungen für den erzeugten Lua-Code.
              </Typography>
            </Stack>
            <ExplainedCheckbox
              checked={draft.showLuaCodeImmediately ?? false}
              label="Lua-Code sofort anzeigen"
              explanation="Optional: Der Lua Code wird bereits vor der Zusammenfassung in allen Schritten angezeigt."
              onChange={(_event, checked) => onDraftPatch({ showLuaCodeImmediately: checked })}
            />
            <ExplainedCheckbox
              checked={draft.manualLuaVariableNames ?? false}
              label="Lua-Variablennamen selbst festlegen"
              explanation="Optional: Vergib die Variablennamen für die Fahrspuren und Signalgruppen selbst."
              onChange={(_event, checked) => onDraftPatch({ manualLuaVariableNames: checked })}
            />
            {draft.manualLuaVariableNames && (
              <TextField
                label="Lua-Variable"
                value={draft.luaVariableName}
                onChange={(event) => onLuaVariableNameChange(event.target.value)}
                error={Boolean(errorTexts.luaVariableName?.length)}
                helperText={
                  errorTexts.luaVariableName?.length
                    ? <strong>{errorTexts.luaVariableName.join(' ')}</strong>
                    : 'Diese Variable wird im Lua-Code verwendet, empfohlen: c1 oder c2 usw.'
                }
                size="small"
                fullWidth
              />
            )}
          </Stack>
        </Stack>
      )}
    </Stack>
  );
}

export default IntersectionWizardSettingsStep;
