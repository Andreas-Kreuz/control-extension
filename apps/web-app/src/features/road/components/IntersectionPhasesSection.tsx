import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import TypeCaption from '../../../shared/components/TypeCaption';
import type Intersection from '../model/Intersection';
import type { IntersectionPhase, IntersectionPhaseTrafficLight } from '../model/Intersection';

const rowLabelWidth = 72;
const minPhaseWidth = 96;
const rowHeight = 38;

function phaseWidth(phase: IntersectionPhase) {
  return Math.max(minPhaseWidth, phase.greenPhaseSeconds * 8);
}

function signalKindFor(trafficLight: IntersectionPhaseTrafficLight) {
  return trafficLight.signalKind ?? (trafficLight.type === 'PEDESTRIAN' ? 'PEDESTRIAN' : 'TRAFFIC');
}

function signalKeyFor(trafficLight: IntersectionPhaseTrafficLight) {
  return trafficLight.signalKey ?? `${trafficLight.signalId}:${signalKindFor(trafficLight)}`;
}

function signalNameFor(trafficLight: IntersectionPhaseTrafficLight) {
  if (trafficLight.signalName !== undefined) return trafficLight.signalName;
  if (signalKindFor(trafficLight) === 'PEDESTRIAN') return trafficLight.pedestrianSignalName ?? '';
  return trafficLight.trafficSignalName ?? '';
}

function signalRowsFor(phases: IntersectionPhase[]) {
  const rows = new Map<string, IntersectionPhaseTrafficLight>();
  phases.forEach((phase) => {
    phase.trafficLights.forEach((trafficLight) => {
      const signalKey = signalKeyFor(trafficLight);
      if (!rows.has(signalKey)) rows.set(signalKey, trafficLight);
    });
  });
  return Array.from(rows.values()).sort(
    (a, b) =>
      signalNameFor(a).localeCompare(signalNameFor(b), undefined, { numeric: true }) ||
      a.signalId - b.signalId ||
      signalKindFor(a).localeCompare(signalKindFor(b)),
  );
}

function phaseHasSignal(phase: IntersectionPhase, signalKey: string) {
  return phase.trafficLights.some((trafficLight) => signalKeyFor(trafficLight) === signalKey);
}

function signalRowNames(trafficLight: IntersectionPhaseTrafficLight) {
  return [signalNameFor(trafficLight)];
}

function signalTooltipName(trafficLight: IntersectionPhaseTrafficLight) {
  return signalRowNames(trafficLight).filter(Boolean).join(' / ');
}

function signalTooltipText(trafficLight: IntersectionPhaseTrafficLight, green: boolean, phase: IntersectionPhase) {
  const name = signalTooltipName(trafficLight);
  const state = green ? 'Grün' : 'Rot';
  return name ? `${name}: ${state} in ${phase.name}` : `${state} in ${phase.name}`;
}

function phaseStateLabel(intersection: Intersection, phase: IntersectionPhase) {
  if (intersection.currentSwitching === phase.name) return 'Aktuell';
  if (intersection.nextSwitching === phase.name) return 'Nächste';
  if (intersection.manualSwitching === phase.name) return 'Manuell';
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
                    {stateLabel ?? `${phase.greenPhaseSeconds}s`}
                  </Typography>
                </Box>
              );
            })}
          </Box>
          {signalRows.map((trafficLight) => {
            const signalKey = signalKeyFor(trafficLight);
            return (
              <Box key={signalKey} sx={{ display: 'flex', alignItems: 'center', height: rowHeight }}>
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
                  {signalRowNames(trafficLight).map((name, index) => (
                    <Typography key={`${signalKey}-${index}`} variant="caption" noWrap>
                      {name}
                    </Typography>
                  ))}
                </Stack>
                {phases.map((phase) => {
                  const green = phaseHasSignal(phase, signalKey);
                  const stateLabel = phaseStateLabel(intersection, phase);
                  return (
                    <Tooltip key={`${phase.id}-${signalKey}`} title={signalTooltipText(trafficLight, green, phase)}>
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
