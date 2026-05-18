import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import type {
  IntersectionWizardAmpelAppDto,
  IntersectionWizardDraftAppDto,
  IntersectionWizardLaneAppDto,
  IntersectionWizardPhaseAppDto,
  IntersectionWizardSignalGroupAppDto,
} from '@ce/web-shared';
import { ExplainedCheckbox } from '../../../../shared/components/checkbox';
import { FeedbackMessage } from '../../../../shared/components/feedback';

export interface IntersectionWizardPhasePlanStepProps {
  draft: IntersectionWizardDraftAppDto;
  createAmpelForLane: (lane: IntersectionWizardLaneAppDto, index: number) => IntersectionWizardAmpelAppDto;
  laneAmpelId: (lane: IntersectionWizardLaneAppDto) => string;
  onAddPhase: () => void;
  onDraftPatch: (patch: Partial<IntersectionWizardDraftAppDto>) => void;
  onOptionalPositiveNumber: (value: string) => number | undefined;
  onRemovePhase: (id: string) => void;
  onTogglePhaseSignalGroup: (phase: IntersectionWizardPhaseAppDto, signalGroupId: string) => void;
  onUpdatePhase: (id: string, patch: Partial<IntersectionWizardPhaseAppDto>) => void;
  selectedLaneAmpel: (lane: IntersectionWizardLaneAppDto) => IntersectionWizardAmpelAppDto | undefined;
}

function IntersectionWizardPhasePlanStep({
  createAmpelForLane,
  draft,
  laneAmpelId,
  onAddPhase,
  onDraftPatch,
  onOptionalPositiveNumber,
  onRemovePhase,
  onTogglePhaseSignalGroup,
  onUpdatePhase,
  selectedLaneAmpel,
}: IntersectionWizardPhasePlanStepProps) {
  const laneAmpelIds = new Set(draft.lanes.map((lane) => laneAmpelId(lane)));
  const signalGroupGridColumns =
    draft.phases.length > 0
      ? `minmax(15rem, 1.2fr) repeat(${draft.phases.length}, minmax(6.25rem, 0.7fr))`
      : 'minmax(15rem, 1fr)';

  function ampelLabel(ampel: IntersectionWizardAmpelAppDto) {
    return ampel.name.trim() || ampel.signalId.trim() || ampel.id;
  }

  function signalNamesForGroup(group: IntersectionWizardSignalGroupAppDto): string[] {
    const names = new Map<string, string>();

    group.ampelIds
      .filter((ampelId) => !laneAmpelIds.has(ampelId))
      .forEach((ampelId) => {
        const ampel = draft.ampeln.find((entry) => entry.id === ampelId);
        if (ampel) names.set(ampel.id, ampelLabel(ampel));
      });

    draft.lanes.forEach((lane) => {
      const defaultGroups = draft.signalGroups.filter((entry) => entry.laneIds.includes(lane.id));
      if (defaultGroups.length !== 1 || defaultGroups[0]?.id !== group.id) return;

      const laneAmpel = selectedLaneAmpel(lane) ?? {
        ...createAmpelForLane(lane, draft.ampeln.length + 1),
        id: laneAmpelId(lane),
      };
      names.set(laneAmpel.id, ampelLabel(laneAmpel));
    });

    return Array.from(names.values());
  }

  return (
    <Stack spacing={2}>
      <Stack direction="row" spacing={1} alignItems="center">
        <Typography variant="h6" sx={{ flex: 1 }}>
          Signalzeitenplan
        </Typography>
        <Button startIcon={<AddIcon />} onClick={onAddPhase}>
          Phase hinzufügen
        </Button>
      </Stack>
      {draft.signalGroups.length === 0 ? (
        <FeedbackMessage severity="warning">Lege zuerst Signalgruppen an, um Verkehrsphasen zu planen.</FeedbackMessage>
      ) : (
        <Paper variant="outlined" sx={{ overflowX: 'auto' }}>
          <Box sx={{ minWidth: draft.phases.length > 0 ? 480 + draft.phases.length * 104 : 480 }}>
            <Box
              sx={{
                display: 'grid',
                gridTemplateColumns: signalGroupGridColumns,
                borderBottom: 1,
                borderColor: 'divider',
                bgcolor: 'grey.50',
              }}
            >
              <Box sx={{ p: 1.25, borderRight: 1, borderColor: 'divider' }}>
                <Typography variant="subtitle2">Signalgruppe</Typography>
                <Typography variant="caption" color="text.secondary">
                  geschaltete Ampeln
                </Typography>
              </Box>
              {draft.phases.map((phase) => (
                <Box key={phase.id} sx={{ p: 1, borderRight: 1, borderColor: 'divider' }}>
                  <Stack spacing={1.5}>
                    <Stack direction="row" spacing={0.5} alignItems="center">
                      <TextField
                        label="Phasenname"
                        value={phase.name}
                        size="small"
                        inputProps={{ maxLength: 12, 'aria-label': `Verkehrsphase ${phase.name}` }}
                        onChange={(event) => onUpdatePhase(phase.id, { name: event.target.value })}
                        sx={{ width: 112, minWidth: 0 }}
                      />
                      <IconButton
                        size="small"
                        aria-label={`Verkehrsphase ${phase.name || phase.id} löschen`}
                        title="Verkehrsphase löschen"
                        onClick={() => onRemovePhase(phase.id)}
                      >
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </Stack>
                    {draft.individualLanePhaseSettings && (
                      <TextField
                        label="Grünzeit (s)"
                        type="number"
                        value={phase.greenTimeSeconds ?? ''}
                        size="small"
                        inputProps={{ min: 1, 'aria-label': `Grünzeit ${phase.name}` }}
                        onChange={(event) =>
                          onUpdatePhase(phase.id, { greenTimeSeconds: onOptionalPositiveNumber(event.target.value) })
                        }
                        sx={{ width: 112 }}
                      />
                    )}
                  </Stack>
                </Box>
              ))}
            </Box>
            {draft.signalGroups.map((group) => {
              const signalNames = signalNamesForGroup(group);
              return (
                <Box
                  key={group.id}
                  sx={{
                    display: 'grid',
                    gridTemplateColumns: signalGroupGridColumns,
                    borderBottom: 1,
                    borderColor: 'divider',
                    '&:last-child': { borderBottom: 0 },
                  }}
                >
                  <Box sx={{ p: 1.25, borderRight: 1, borderColor: 'divider' }}>
                    <Typography variant="body2" fontWeight={600}>
                      {group.name || group.id}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {signalNames.length > 0 ? signalNames.join(', ') : 'Keine Ampel zugeordnet'}
                    </Typography>
                  </Box>
                  {draft.phases.map((phase) => {
                    const isActive = phase.signalGroupIds.includes(group.id);
                    return (
                      <Box key={phase.id} sx={{ p: 1, borderRight: 1, borderColor: 'divider' }}>
                        <Button
                          fullWidth
                          variant={isActive ? 'contained' : 'outlined'}
                          color={isActive ? 'success' : 'inherit'}
                          onClick={() => onTogglePhaseSignalGroup(phase, group.id)}
                          sx={{
                            minHeight: 44,
                            borderColor: isActive ? 'success.main' : 'divider',
                            bgcolor: isActive ? 'success.main' : 'background.paper',
                            color: isActive ? 'common.white' : 'text.secondary',
                            '&:hover': {
                              bgcolor: isActive ? 'success.dark' : 'grey.50',
                              borderColor: isActive ? 'success.dark' : 'text.secondary',
                            },
                          }}
                        >
                          {isActive ? 'Grün' : '-'}
                        </Button>
                      </Box>
                    );
                  })}
                </Box>
              );
            })}
          </Box>
        </Paper>
      )}
      {draft.phases.length === 0 && (
        <FeedbackMessage severity="info">
          Füge mindestens eine Verkehrsphase hinzu und markiere die grünen Signalgruppen.
        </FeedbackMessage>
      )}
      <ExplainedCheckbox
        checked={draft.switchInStrictOrder ?? false}
        label="Verkehrsphasen strikt in der angelegten Reihenfolge schalten"
        onChange={(_event, checked) => onDraftPatch({ switchInStrictOrder: checked })}
      />
    </Stack>
  );
}

export default IntersectionWizardPhasePlanStep;
