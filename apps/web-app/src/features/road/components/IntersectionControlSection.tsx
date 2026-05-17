import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Box from '@mui/material/Box';
import { useTheme } from '@mui/material/styles';
import { useSocket } from '../../../app/hooks/useSocket';
import { RoadEvent } from '@ce/web-shared';
import Intersection from '../model/Intersection';
import useIntersectionPhase from '../hooks/useIntersectionPhase';
import TypeCaption from '../../../shared/components/TypeCaption';
import FullBleedDivider from '../../../shared/components/sections/FullBleedDivider';

function IntersectionControlSection({ intersection: i }: { intersection: Intersection }) {
  const theme = useTheme();
  const socket = useSocket();
  const phases = useIntersectionPhase(i.name);

  function sendSwitchManually(intersectionName: string, phaseName: string) {
    socket.emit(RoadEvent.SwitchManually, { intersectionName, phaseName });
  }

  function sendSwitchAutomatically(intersectionName: string) {
    socket.emit(RoadEvent.SwitchAutomatically, { intersectionName });
  }

  return (
    <Stack>
      <TypeCaption>Modus</TypeCaption>
      <Stack direction="row" spacing={1} sx={{ pt: 1 }}>
        <Chip
          label="Auto"
          variant="filled"
          color={i.manualPhase ? 'default' : 'primary'}
          onClick={() => sendSwitchAutomatically(i.name)}
        />
        <Chip
          label="Manuell"
          variant="filled"
          color={i.manualPhase ? 'primary' : 'default'}
          onClick={() => sendSwitchManually(i.name, i.currentPhase)}
        />
      </Stack>
      <Box sx={{ my: 1 }}>
        <FullBleedDivider />
      </Box>
      <TypeCaption>Phase</TypeCaption>
      <Stack direction="row" sx={{ pt: 1, flexWrap: 'wrap' }}>
        {phases.map((s) => {
          const active = i.currentPhase === s.name;
          const next = (i.nextPhase === s.name || i.manualPhase === s.name) && i.currentPhase !== s.name;
          const clickable = Boolean(i.manualPhase);
          return (
            <Chip
              sx={{
                mr: 1,
                mb: 1,
                color: active || next ? theme.palette.primary.contrastText : undefined,
                backgroundColor: active || next ? theme.palette.primary.main : clickable ? undefined : 'white',
              }}
              label={s.name}
              variant={i.manualPhase ? 'filled' : 'outlined'}
              key={s.name}
              color={active ? 'primary' : next ? 'primary' : 'default'}
              clickable={clickable}
              disabled={!active && (!clickable || next)}
              onClick={() => {
                if (clickable) sendSwitchManually(i.name, s.name);
              }}
            />
          );
        })}
      </Stack>
    </Stack>
  );
}

export default IntersectionControlSection;
