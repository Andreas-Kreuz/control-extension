import Chip from '@mui/material/Chip';
import Stack from '@mui/material/Stack';
import Divider from '@mui/material/Divider';
import { useTheme } from '@mui/material/styles';
import { useSocket } from '../../../app/hooks/useSocket';
import { RoadEvent } from '@ce/web-shared';
import Intersection from '../model/Intersection';
import useIntersectionSwitching from '../hooks/useIntersectionSwitching';
import AppCaption from '../../../shared/ui/AppCaption';

function IntersectionControlSection({ intersection: i }: { intersection: Intersection }) {
  const theme = useTheme();
  const socket = useSocket();
  const switchings = useIntersectionSwitching(i.name);

  function sendSwitchManually(intersectionName: string, switchingName: string) {
    socket.emit(RoadEvent.SwitchManually, { intersectionName, switchingName });
  }

  function sendSwitchAutomatically(intersectionName: string) {
    socket.emit(RoadEvent.SwitchAutomatically, { intersectionName });
  }

  return (
    <Stack sx={{ px: 2, pt: 1, pb: 2 }}>
      <AppCaption>Modus</AppCaption>
      <Stack direction="row" spacing={1} sx={{ pt: 1 }}>
        <Chip
          label="Auto"
          variant="filled"
          color={i.manualSwitching ? 'default' : 'primary'}
          onClick={() => sendSwitchAutomatically(i.name)}
        />
        <Chip
          label="Manuell"
          variant="filled"
          color={i.manualSwitching ? 'primary' : 'default'}
          onClick={() => sendSwitchManually(i.name, i.currentSwitching)}
        />
      </Stack>
      <Divider sx={{ my: 1 }} />
      <AppCaption>Schaltung</AppCaption>
      <Stack direction="row" sx={{ pt: 1, flexWrap: 'wrap' }}>
        {switchings.map((s) => {
          const active = i.currentSwitching === s.name;
          const next = (i.nextSwitching === s.name || i.manualSwitching === s.name) && i.currentSwitching !== s.name;
          const clickable = Boolean(i.manualSwitching);
          return (
            <Chip
              sx={{
                mr: 1,
                mb: 1,
                color: active || next ? theme.palette.primary.contrastText : undefined,
                backgroundColor: active || next ? theme.palette.primary.main : clickable ? undefined : 'white',
              }}
              label={s.name}
              variant={i.manualSwitching ? 'filled' : 'outlined'}
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
