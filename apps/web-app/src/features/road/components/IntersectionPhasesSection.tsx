import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import TypeCaption from '../../../shared/components/TypeCaption';
import type Intersection from '../model/Intersection';
import type { IntersectionPhase, IntersectionPhaseSignalHead } from '../model/Intersection';

const rowLabelWidth = 72;
const minPhaseWidth = 96;
const rowHeight = 38;

function phaseWidth(phase: IntersectionPhase) {
  return Math.max(minPhaseWidth, phase.greenTimeSeconds * 8);
}

function signalKindFor(signalHead: IntersectionPhaseSignalHead) {
  return signalHead.signalHeadKind ?? (signalHead.type === 'PEDESTRIAN' ? 'PEDESTRIAN' : 'VEHICLE');
}

function signalKeyFor(signalHead: IntersectionPhaseSignalHead) {
  return signalHead.signalHeadKey ?? `${signalHead.signalId}:${signalKindFor(signalHead)}`;
}

function signalNameFor(signalHead: IntersectionPhaseSignalHead) {
  if (signalHead.signalHeadName !== undefined) return signalHead.signalHeadName;
  if (signalKindFor(signalHead) === 'PEDESTRIAN') return signalHead.pedestrianSignalHeadName ?? '';
  return signalHead.vehicleSignalHeadName ?? '';
}

function signalRowsFor(phases: IntersectionPhase[]) {
  const rows = new Map<string, IntersectionPhaseSignalHead>();
  phases.forEach((phase) => {
    phase.signalHeads.forEach((signalHead) => {
      const signalHeadKey = signalKeyFor(signalHead);
      if (!rows.has(signalHeadKey)) rows.set(signalHeadKey, signalHead);
    });
  });
  return Array.from(rows.values()).sort(
    (a, b) =>
      signalNameFor(a).localeCompare(signalNameFor(b), undefined, { numeric: true }) ||
      a.signalId - b.signalId ||
      signalKindFor(a).localeCompare(signalKindFor(b)),
  );
}

function phaseHasSignal(phase: IntersectionPhase, signalHeadKey: string) {
  return phase.signalHeads.some((signalHead) => signalKeyFor(signalHead) === signalHeadKey);
}

function signalRowNames(signalHead: IntersectionPhaseSignalHead) {
  return [signalNameFor(signalHead)];
}

function signalTooltipName(signalHead: IntersectionPhaseSignalHead) {
  return signalRowNames(signalHead).filter(Boolean).join(' / ');
}

function signalTooltipText(signalHead: IntersectionPhaseSignalHead, green: boolean, phase: IntersectionPhase) {
  const name = signalTooltipName(signalHead);
  const state = green ? 'Grün' : 'Rot';
  return name ? `${name}: ${state} in ${phase.name}` : `${state} in ${phase.name}`;
}

function phaseStateLabel(intersection: Intersection, phase: IntersectionPhase) {
  if (intersection.currentPhase === phase.name) return 'Aktuell';
  if (intersection.nextPhase === phase.name) return 'Nächste';
  if (intersection.manualPhase === phase.name) return 'Manuell';
  return undefined;
}

function IntersectionPhasesSection({ intersection }: { intersection: Intersection }) {
  const theme = useTheme();
  const phases = [...(intersection.phases ?? [])].sort((a, b) => a.order - b.order || a.name.localeCompare(b.name));
  const signalRows = signalRowsFor(phases);

  if (phases.length === 0) {
    return (
      <Box sx={{ p: 2 }}>
        <Typography variant="body2" color="textSecondary">
          Keine Phasen vorhanden.
        </Typography>
      </Box>
    );
  }

  return (
    <Stack sx={{ px: 2, pt: 1, pb: 2, minWidth: 0 }}>
      <TypeCaption>Signalzeitenplan</TypeCaption>
      <Box sx={{ mt: 1, overflowX: 'auto' }}>
        <Box sx={{ minWidth: rowLabelWidth + phases.reduce((sum, phase) => sum + phaseWidth(phase), 0) }}>
          <Box sx={{ display: 'flex', ml: `${rowLabelWidth}px` }}>
            {phases.map((phase) => {
              const stateLabel = phaseStateLabel(intersection, phase);
              return (
                <Box
                  key={phase.id}
                  sx={{
                    width: phaseWidth(phase),
                    px: 1,
                    pb: 0.5,
                    borderLeft: 1,
                    borderColor: 'divider',
                  }}
                >
                  <Typography variant="caption" sx={{ display: 'block', fontWeight: 700 }} noWrap>
                    {phase.name}
                  </Typography>
                  <Typography variant="caption" color={stateLabel ? 'primary' : 'textSecondary'} noWrap>
                    {stateLabel ?? `${phase.greenTimeSeconds}s`}
                  </Typography>
                </Box>
              );
            })}
          </Box>
          {signalRows.map((signalHead) => {
            const signalHeadKey = signalKeyFor(signalHead);
            return (
              <Box key={signalHeadKey} sx={{ display: 'flex', alignItems: 'center', height: rowHeight }}>
                <Stack
                  sx={{
                    width: rowLabelWidth,
                    pr: 1,
                    textAlign: 'right',
                    color: 'text.secondary',
                    flexShrink: 0,
                    lineHeight: 1.1,
                  }}
                >
                  {signalRowNames(signalHead).map((name, index) => (
                    <Typography key={`${signalHeadKey}-${index}`} variant="caption" noWrap>
                      {name}
                    </Typography>
                  ))}
                </Stack>
                {phases.map((phase) => {
                  const green = phaseHasSignal(phase, signalHeadKey);
                  const stateLabel = phaseStateLabel(intersection, phase);
                  return (
                    <Tooltip key={`${phase.id}-${signalHeadKey}`} title={signalTooltipText(signalHead, green, phase)}>
                      <Box
                        sx={{
                          width: phaseWidth(phase),
                          height: 16,
                          bgcolor: green ? '#7cb342' : '#e9552a',
                          borderLeft: 1,
                          borderRight: stateLabel ? 2 : 0,
                          borderColor: stateLabel ? theme.palette.primary.main : 'rgba(255,255,255,0.5)',
                          boxShadow: stateLabel ? `inset 0 0 0 2px ${theme.palette.primary.main}` : undefined,
                        }}
                      />
                    </Tooltip>
                  );
                })}
              </Box>
            );
          })}
        </Box>
      </Box>
    </Stack>
  );
}

export default IntersectionPhasesSection;
