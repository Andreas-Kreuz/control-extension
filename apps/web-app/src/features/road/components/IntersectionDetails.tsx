import { useSocket } from '../../../app/hooks/useSocket';
import TypeCaption from '../../../shared/components/TypeCaption';
import SectionHeadline from '../../../shared/components/SectionHeadline';
import PageContainer from '../../../shared/layouts/PageContainer';
import BackgroundPaper from '../../../shared/layouts/BackgroundPaper';
import useIntersection from '../hooks/useIntersection';
import useIntersectionPhase from '../hooks/useIntersectionPhase';
import { CommandEvent, RoadEvent } from '@ce/web-shared';
import CamIcon from '@mui/icons-material/Videocam';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useTheme } from '@mui/material/styles';
import { useParams } from 'react-router-dom';
import { Tooltip } from '@mui/material';

function IntersectionDetails() {
  const theme = useTheme();
  const socket = useSocket();
  const { intersectionId } = useParams();
  const id = parseInt(intersectionId || '555');
  const i = useIntersection(id);
  const phases = useIntersectionPhase(i?.name);

  function sendSwitchManually(intersectionName: string, phaseName: string) {
    socket.emit(RoadEvent.SwitchManually, {
      intersectionName,
      phaseName,
    });
  }

  function sendSwitchAutomatically(intersectionName: string) {
    socket.emit(RoadEvent.SwitchAutomatically, {
      intersectionName,
    });
  }

  function changeCam(camName: string) {
    socket.emit(CommandEvent.ChangeCamToStatic, { staticCam: camName });
  }

  return (
    <PageContainer>
      {i && (
        <>
          <BackgroundPaper
          // image="/assets/card-img-intersection.jpg"
          >
            <SectionHeadline gutterBottom>Kreuzung {i.id}</SectionHeadline>
            <Chip label={i.name} />
            <Stack
              direction="row"
              sx={{ alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap' }}
            ></Stack>
            <TypeCaption gutterTop>Modus</TypeCaption>
            <Stack direction="row" spacing={1}>
              <Chip
                label="Auto"
                variant="filled"
                color={i.manualPhase ? 'default' : 'primary'}
                onClick={() => {
                  sendSwitchAutomatically(i.name);
                }}
              />
              <Chip
                label="Manuell"
                variant="filled"
                color={i.manualPhase ? 'primary' : 'default'}
                onClick={() => {
                  sendSwitchManually(i.name, i.currentPhase);
                }}
              />
            </Stack>

            <Divider sx={{ py: 1 }} />
            <TypeCaption gutterTop>Phase</TypeCaption>
            <Stack
              direction="row"
              sx={{ pt: 1, pb: 0, flexWrap: 'wrap' }}
              // sx={{ backgroundColor: theme.palette.background.default }}
            >
              {phases.map((s) => {
                const active = i.currentPhase === s.name;
                const next =
                  (i.nextPhase === s.name || i.manualPhase === s.name) && i.currentPhase !== s.name;
                const color = active ? 'primary' : next ? 'primary' : 'default';
                const clickable = i.manualPhase ? true : false;
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
                    color={color}
                    clickable={clickable}
                    disabled={!active && (!clickable || next)}
                    onClick={() => {
                      if (clickable) sendSwitchManually(i.name, s.name);
                    }}
                  ></Chip>
                );
              })}
            </Stack>
            {i.staticCams && i.staticCams.length > 0 && (
              <>
                <Divider sx={{ py: 1 }} />
                <TypeCaption gutterTop>Kameras</TypeCaption>
                <Stack direction="row" sx={{ pt: 1, pb: 0 }}>
                  {i.staticCams.map((c, j) => {
                    return (
                      <Tooltip title={c}>
                        <Chip
                          sx={{
                            mr: 1,
                            mb: 1,
                            justifyContent: 'flex-start',
                          }}
                          color={'secondary'}
                          icon={<CamIcon />}
                          label={(i.staticCams.length === 1 && c) || j}
                          variant={'outlined'}
                          key={c}
                          clickable
                          onClick={() => {
                            changeCam(c);
                          }}
                        ></Chip>
                      </Tooltip>
                    );
                  }) || 'Keine'}
                </Stack>
              </>
            )}
          </BackgroundPaper>

          {i.staticCams && i.staticCams.length === 0 && (
            <Alert
              severity="info"
              sx={{
                border: 1,
                borderColor: 'info.main',
                alignItems: 'top',
                mt: 2,
              }}
              icon={false}
            >
              <Typography variant="body2" sx={{ fontWeight: 'bolder' }} gutterBottom>
                Tipp: Kameras hinzufügen
              </Typography>
              <Typography variant="body2">
                So hast Du Deine Kreuzung angelegt:
                <Box component="pre" sx={{ fontSize: 14, whiteSpace: 'normal' }}>
                  c1 = Crossing:new(...)
                </Box>
                Suche Dir nun eine statische Kamera aus und füge ihren Namen wie folgt hinzu:
                <Box component="pre" sx={{ fontSize: 14, whiteSpace: 'normal' }}>
                  c1:addStaticCam('Kameraname')
                </Box>
              </Typography>
            </Alert>
          )}
        </>
      )}
    </PageContainer>
  );
}

export default IntersectionDetails;
