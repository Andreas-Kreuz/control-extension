import Box from '@mui/material/Box';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import AppCaption from '../../../shared/components/AppCaption';
import type Intersection from '../model/Intersection';
import type { IntersectionPhase } from '../model/Intersection';

const rowLabelWidth = 56;
const minPhaseWidth = 96;
const rowHeight = 28;

function phaseWidth(phase: IntersectionPhase) {
  return Math.max(minPhaseWidth, phase.greenPhaseSeconds * 8);
}

function signalIdsFor(phases: IntersectionPhase[]) {
  const ids = new Set<number>();
  phases.forEach((phase) => phase.trafficLights.forEach((trafficLight) => ids.add(trafficLight.signalId)));
  return Array.from(ids).sort((a, b) => a - b);
}

function phaseHasSignal(phase: IntersectionPhase, signalId: number) {
  return phase.trafficLights.some((trafficLight) => trafficLight.signalId === signalId);
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
  const signalIds = signalIdsFor(phases);

  if (phases.length === 0) {
    return (
      <Box sx={{ p: 2 }}>
        <Typography variant="body2" color="text.secondary">
          Keine Phasen vorhanden.
        </Typography>
      </Box>
    );
  }

  return (
    <Stack sx={{ px: 2, pt: 1, pb: 2, minWidth: 0 }}>
      <AppCaption>Signalzeitenplan</AppCaption>
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
                  <Typography variant="caption" color={stateLabel ? 'primary' : 'text.secondary'} noWrap>
                    {stateLabel ?? `${phase.greenPhaseSeconds}s`}
                  </Typography>
                </Box>
              );
            })}
          </Box>
          {signalIds.map((signalId) => (
            <Box key={signalId} sx={{ display: 'flex', alignItems: 'center', height: rowHeight }}>
              <Typography
                variant="caption"
                sx={{
                  width: rowLabelWidth,
                  pr: 1,
                  textAlign: 'right',
                  color: 'text.secondary',
                  flexShrink: 0,
                }}
              >
                K{signalId}
              </Typography>
              {phases.map((phase) => {
                const green = phaseHasSignal(phase, signalId);
                const stateLabel = phaseStateLabel(intersection, phase);
                return (
                  <Tooltip
                    key={`${phase.id}-${signalId}`}
                    title={`K${signalId}: ${green ? 'Grün' : 'Rot'} in ${phase.name}`}
                  >
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
          ))}
        </Box>
      </Box>
    </Stack>
  );
}

export default IntersectionPhasesSection;
