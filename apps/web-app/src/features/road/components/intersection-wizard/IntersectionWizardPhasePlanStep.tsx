import Box from '@mui/material/Box';
import Badge from '@mui/material/Badge';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import type {
  IntersectionWizardDraftAppDto,
  IntersectionWizardPhaseAppDto,
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardTrafficType,
  IntersectionWizardTurnDirection,
} from '@ce/web-shared';
import { ExplainedCheckbox } from '../../../../shared/components/checkbox';
import { FeedbackMessage } from '../../../../shared/components/feedback';
import {
  SignalGroupTrafficLightPreview,
  approachLabels,
  turnDirectionLabels,
} from '../../../../shared/components/road';

const trafficTypeLabels = {
  CAR: 'Auto',
  TRAM: 'Tram/Bus',
  PEDESTRIAN: 'Fußgänger',
} satisfies Record<IntersectionWizardTrafficType, string>;

const signalGroupTurnOrder = {
  LEFT: 0,
  HALF_LEFT: 1,
  STRAIGHT: 2,
  HALF_RIGHT: 3,
  RIGHT: 4,
} satisfies Record<IntersectionWizardTurnDirection, number>;

export interface IntersectionWizardPhasePlanStepProps {
  draft: IntersectionWizardDraftAppDto;
  ampelLabel: (ampelId: string) => string;
  phaseErrors?: Record<string, { greenTimeSeconds?: string[]; name?: string[]; signalGroupIds?: string[] }>;
  onAddPhase: () => void;
  onDraftPatch: (patch: Partial<IntersectionWizardDraftAppDto>) => void;
  onOptionalPositiveNumber: (value: string) => number | undefined;
  onRemovePhase: (id: string) => void;
  onTogglePhaseSignalGroup: (phase: IntersectionWizardPhaseAppDto, signalGroupId: string) => void;
  onUpdatePhase: (id: string, patch: Partial<IntersectionWizardPhaseAppDto>) => void;
}

function IntersectionWizardPhasePlanStep({
  ampelLabel,
  draft,
  phaseErrors = {},
  onAddPhase,
  onDraftPatch,
  onOptionalPositiveNumber,
  onRemovePhase,
  onTogglePhaseSignalGroup,
  onUpdatePhase,
}: IntersectionWizardPhasePlanStepProps) {
  const signalGroupGridColumns =
    draft.phases.length > 0
      ? `minmax(20rem, 1.2fr) repeat(${draft.phases.length}, minmax(6.25rem, 0.7fr))`
      : 'minmax(20rem, 1fr)';
  function orderTurnDirections(directions: IntersectionWizardTurnDirection[]) {
    return [...directions].sort((a, b) => signalGroupTurnOrder[a] - signalGroupTurnOrder[b]);
  }

  function signalNamesForGroup(group: IntersectionWizardSignalGroupAppDto): string[] {
    const names = new Map<string, string>();

    group.ampelIds.forEach((ampelId) => names.set(ampelId, ampelLabel(ampelId)));

    return Array.from(names.values());
  }

  function signalGroupSummary(group: IntersectionWizardSignalGroupAppDto) {
    const directionText =
      group.trafficType === 'PEDESTRIAN'
        ? undefined
        : orderTurnDirections(group.turnDirections)
            .map((direction) => turnDirectionLabels[direction])
            .join(', ');
    return [approachLabels[group.approach], trafficTypeLabels[group.trafficType], directionText]
      .filter(Boolean)
      .join(' · ');
  }

  function formatPhaseList(names: string[]) {
    if (names.length === 0) return 'keine';
    if (names.length === 1) return names[0];
    return `${names.slice(0, -1).join(', ')} und ${names[names.length - 1]}`;
  }

  function phaseSignalGroupInfoText(phase: IntersectionWizardPhaseAppDto) {
    return `Schaltet ${phase.signalGroupIds.length} ${
      phase.signalGroupIds.length === 1 ? 'Ampelgruppe' : 'Ampelgruppen'
    }`;
  }

  function signalGroupPhaseInfoText(group: IntersectionWizardSignalGroupAppDto) {
    const phaseNames = draft.phases
      .filter((phase) => phase.signalGroupIds.includes(group.id))
      .map((phase) => phase.name || phase.id);
    return `Phasen: ${formatPhaseList(phaseNames)}.`;
  }

  return (
    <Stack spacing={2}>
      <Stack direction="row" spacing={1} alignItems="center">
        <Typography variant="h6" sx={{ flex: 1 }}>
          Ampelphasen
        </Typography>
        <Button startIcon={<AddIcon />} onClick={onAddPhase}>
          Ampelphase hinzufügen
        </Button>
      </Stack>
      {draft.signalGroups.length === 0 ? (
        <FeedbackMessage severity="warning">Lege zuerst Ampelgruppen an, um Ampelphasen zu planen.</FeedbackMessage>
      ) : (
        <Stack spacing={1}>
          <Typography variant="body2" color="text.secondary">
            Eine Phase ist ein Zustand der Kreuzung. Markiere pro Phase alle Ampelgruppen, die gleichzeitig Grün zeigen
            sollen.
          </Typography>
          <Paper variant="outlined" sx={{ overflowX: 'auto' }}>
            <Box sx={{ minWidth: draft.phases.length > 0 ? 560 + draft.phases.length * 104 : 560 }}>
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
                  <Typography variant="subtitle2">Ampelgruppe</Typography>
                  <Typography variant="caption" color="text.secondary">
                    EEP-Ampeln
                  </Typography>
                </Box>
                {draft.phases.map((phase) => (
                  <Box key={phase.id} sx={{ p: 1, borderRight: 1, borderColor: 'divider' }}>
                    {(() => {
                      const errors = phaseErrors[phase.id] ?? {};
                      return (
                    <Stack spacing={1.5}>
                      <Box sx={{ minHeight: draft.manualLuaVariableNames ? 40 : 28, position: 'relative', pr: 4 }}>
                        <Box sx={{ display: 'inline-flex', position: 'relative' }}>
                          {draft.manualLuaVariableNames ? (
                            <Badge
                              anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
                              badgeContent="!"
                              color="error"
                              invisible={phase.signalGroupIds.length > 0}
                              overlap="rectangular"
                            >
                              <TextField
                                label="Phasenname"
                                value={phase.name}
                                size="small"
                                error={Boolean(errors.name?.length)}
                                helperText={errors.name?.length ? <strong>{errors.name.join(' ')}</strong> : undefined}
                                inputProps={{ maxLength: 12, 'aria-label': `Ampelphase ${phase.name}` }}
                                onChange={(event) => onUpdatePhase(phase.id, { name: event.target.value })}
                                sx={{ width: 112, minWidth: 0 }}
                              />
                            </Badge>
                          ) : (
                            <Badge
                              anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
                              badgeContent="!"
                              color="error"
                              invisible={phase.signalGroupIds.length > 0}
                              overlap="rectangular"
                            >
                              <Typography variant="subtitle2" sx={{ width: 72 }}>
                                {phase.name}
                              </Typography>
                            </Badge>
                          )}
                        </Box>
                        <IconButton
                          size="small"
                          aria-label={`Ampelphase ${phase.name || phase.id} löschen`}
                          title="Ampelphase löschen"
                          onClick={() => onRemovePhase(phase.id)}
                          sx={{ position: 'absolute', right: 0, top: 0 }}
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </Box>
                      {!draft.manualLuaVariableNames &&
                        errors.name?.map((errorText) => (
                          <Typography key={errorText} variant="caption" color="error">
                            {errorText}
                          </Typography>
                        ))}
                      {draft.individualLanePhaseSettings && (
                        <TextField
                          label="Grünzeit (s)"
                          type="number"
                          value={phase.greenTimeSeconds ?? ''}
                          size="small"
                          error={Boolean(errors.greenTimeSeconds?.length)}
                          helperText={
                            errors.greenTimeSeconds?.length ? (
                              <strong>{errors.greenTimeSeconds.join(' ')}</strong>
                            ) : undefined
                          }
                          inputProps={{ min: 1, 'aria-label': `Grünzeit ${phase.name}` }}
                          onChange={(event) =>
                            onUpdatePhase(phase.id, { greenTimeSeconds: onOptionalPositiveNumber(event.target.value) })
                          }
                          sx={{ width: 112 }}
                        />
                      )}
                      <Typography
                        variant="caption"
                        color={phase.signalGroupIds.length === 0 || errors.signalGroupIds?.length ? 'error' : 'text.secondary'}
                        sx={{ minHeight: 18 }}
                      >
                        {errors.signalGroupIds?.length ? (
                          <strong>{errors.signalGroupIds.join(' ')}</strong>
                        ) : phase.signalGroupIds.length === 0 ? (
                          <strong>Keine Ampelgruppe grün</strong>
                        ) : (
                          phaseSignalGroupInfoText(phase)
                        )}
                      </Typography>
                    </Stack>
                      );
                    })()}
                  </Box>
                ))}
              </Box>
              {draft.signalGroups.map((group) => {
                const signalNames = signalNamesForGroup(group);
                const hasGreenPhase = draft.phases.some((phase) => phase.signalGroupIds.includes(group.id));
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
                      <Stack direction="row" spacing={1.5} alignItems="center">
                        <Box sx={{ width: 96, flex: '0 0 auto' }}>
                          <SignalGroupTrafficLightPreview
                            align="left"
                            size="small"
                            trafficType={group.trafficType}
                            turnDirections={group.turnDirections}
                          />
                        </Box>
                        <Stack spacing={0.25} sx={{ minWidth: 0 }}>
                          <Badge
                            anchorOrigin={{ horizontal: 'left', vertical: 'top' }}
                            badgeContent="!"
                            color="error"
                            invisible={hasGreenPhase}
                            overlap="rectangular"
                            sx={{ alignSelf: 'flex-start' }}
                          >
                            <Typography variant="body2" fontWeight={600}>
                              {group.name || group.id}
                            </Typography>
                          </Badge>
                          <Typography variant="caption" color="text.secondary">
                            {signalGroupSummary(group)}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {signalNames.length > 0 ? signalNames.join(', ') : 'Keine Ampel zugeordnet'}
                          </Typography>
                          <Typography
                            variant="caption"
                            color={hasGreenPhase ? 'text.secondary' : 'error'}
                            sx={{ minHeight: 18 }}
                          >
                            {hasGreenPhase ? (
                              signalGroupPhaseInfoText(group)
                            ) : (
                              <strong>Wird nicht grüngeschaltet</strong>
                            )}
                          </Typography>
                        </Stack>
                      </Stack>
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
        </Stack>
      )}
      {draft.phases.length === 0 && (
        <FeedbackMessage severity="info">
          Füge mindestens eine Ampelphase hinzu und markiere die grünen Ampelgruppen.
        </FeedbackMessage>
      )}
      <ExplainedCheckbox
        checked={draft.switchInStrictOrder ?? false}
        label="Ampelphasen strikt in der angelegten Reihenfolge schalten"
        explanation="Wenn aktiv, wird nach P1 immer P2 usw. geschaltet."
        onChange={(_event, checked) => onDraftPatch({ switchInStrictOrder: checked })}
      />
    </Stack>
  );
}

export default IntersectionWizardPhasePlanStep;
