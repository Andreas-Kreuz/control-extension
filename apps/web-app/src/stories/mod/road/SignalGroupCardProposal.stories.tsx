import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import TrafficIcon from '@mui/icons-material/Traffic';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import { IconHeadlineDelete } from '../../../shared/components/headlines';
import { Approach, SignalGroupTrafficLightPreview } from '../../../shared/components/road';

function SectionTitle(props: { children: string; helper: string }) {
  return (
    <Stack spacing={0.25}>
      <Typography variant="subtitle2">{props.children}</Typography>
      <Typography variant="caption" color="text.secondary">
        {props.helper}
      </Typography>
    </Stack>
  );
}

function AmpelGroupCardProposal() {
  return (
    <Box sx={{ maxWidth: 1180 }}>
      <Stack spacing={2} sx={{ bgcolor: 'grey.50', p: 1.5, borderRadius: 1 }}>
        <Paper
          variant="outlined"
          sx={{
            p: 2,
            bgcolor: 'background.paper',
            borderColor: 'grey.300',
            boxShadow: '0 1px 2px rgba(15, 23, 42, 0.06)',
          }}
        >
          <Stack spacing={2.25}>
            <IconHeadlineDelete
              icon={<TrafficIcon />}
              text="Ampelgruppe sgSouthCarRight"
              subText="Schaltet gemeinsam · Süden · Auto · Rechts"
              variant="h6"
              ariaLabel="Ampelgruppe löschen"
              onDelete={() => undefined}
            />

            <Stack spacing={1.25}>
              <SectionTitle helper="Diese Angaben gelten für alle Ampeln in dieser Gruppe.">
                Gemeinsame Bedeutung
              </SectionTitle>
              <Box
                sx={{
                  display: 'grid',
                  gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr auto' },
                  gap: 1.5,
                  alignItems: 'start',
                }}
              >
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Zufahrt
                  </Typography>
                  <Select
                    size="small"
                    value="SOUTH"
                    renderValue={() => <Approach approach="SOUTH" />}
                    sx={{ width: 'max-content', minWidth: 220 }}
                  >
                    <MenuItem value="SOUTH">
                      <Approach approach="SOUTH" />
                    </MenuItem>
                  </Select>
                </Stack>

                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Typ
                  </Typography>
                  <ToggleButtonGroup exclusive size="small" value="CAR">
                    <ToggleButton value="CAR">Auto</ToggleButton>
                    <ToggleButton value="TRAM">ÖPNV</ToggleButton>
                    <ToggleButton value="PEDESTRIAN">Fussg.</ToggleButton>
                  </ToggleButtonGroup>
                </Stack>

                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Abbiegerichtungen
                  </Typography>
                  <ToggleButtonGroup size="small" value={['RIGHT']}>
                    <ToggleButton value="LEFT">Links</ToggleButton>
                    <ToggleButton value="STRAIGHT">Geradeaus</ToggleButton>
                    <ToggleButton value="RIGHT">Rechts</ToggleButton>
                  </ToggleButtonGroup>
                </Stack>

                <Stack spacing={0.5} sx={{ alignItems: 'flex-start' }}>
                  <Typography variant="caption" color="text.secondary">
                    Vorschau
                  </Typography>
                  <SignalGroupTrafficLightPreview trafficType="CAR" turnDirections={['RIGHT']} />
                  <Typography variant="caption" color="text.secondary">
                    Gilt für alle Ampeln dieser Gruppe.
                  </Typography>
                </Stack>
              </Box>
            </Stack>

            <Stack spacing={1.25}>
              <Stack direction="row" spacing={1} alignItems="flex-start">
                <SectionTitle helper="Füge alle EEP-Ampeln hinzu, die gemeinsam schalten sollen.">
                  Ampeln aus EEP
                </SectionTitle>
                <Box sx={{ flex: 1 }} />
                <Button size="small" startIcon={<AddIcon />}>
                  EEP-Ampel hinzufügen
                </Button>
              </Stack>
              <TableContainer component={Box} sx={{ border: 1, borderColor: 'divider', borderRadius: 1 }}>
                <Table size="small" aria-label="Ampeln aus EEP">
                  <TableHead>
                    <TableRow>
                      <TableCell>Name</TableCell>
                      <TableCell>Signal-ID</TableCell>
                      <TableCell>Signal-Modell</TableCell>
                      <TableCell align="right" sx={{ width: 56 }} />
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {[
                      ['K1', '91', 'Ampel_3er_XXX_mit_FG'],
                      ['K2', '92', 'Ampel_3er_XXX_mit_FG'],
                    ].map(([name, signalId, model]) => (
                      <TableRow key={name} hover>
                        <TableCell>{name}</TableCell>
                        <TableCell>{signalId}</TableCell>
                        <TableCell>{model}</TableCell>
                        <TableCell align="right">
                          <IconButton size="small" color="error" aria-label={`${name} löschen`}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </Stack>
          </Stack>
        </Paper>

        <Paper
          variant="outlined"
          sx={{
            p: 2,
            bgcolor: 'background.paper',
            borderColor: 'grey.300',
            boxShadow: '0 1px 2px rgba(15, 23, 42, 0.06)',
          }}
        >
          <Stack spacing={2.25}>
            <IconHeadlineDelete
              icon={<TrafficIcon />}
              text="Ampelgruppe sgEastPed"
              subText="Schaltet gemeinsam · Osten · Fußgänger"
              variant="h6"
              ariaLabel="Ampelgruppe löschen"
              onDelete={() => undefined}
            />
            <Stack spacing={1.25}>
              <SectionTitle helper="Diese Gruppe steuert die Fußgängerampeln einer Furt.">Fußgängerfurt</SectionTitle>
              <Box
                sx={{
                  display: 'grid',
                  gridTemplateColumns: { xs: '1fr', md: '1fr 1fr 1fr auto' },
                  gap: 1.5,
                  alignItems: 'start',
                }}
              >
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Zufahrt
                  </Typography>
                  <Select
                    size="small"
                    value="EAST"
                    renderValue={() => <Approach approach="EAST" />}
                    sx={{ width: 'max-content', minWidth: 220 }}
                  >
                    <MenuItem value="EAST">
                      <Approach approach="EAST" />
                    </MenuItem>
                  </Select>
                </Stack>
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Typ
                  </Typography>
                  <ToggleButtonGroup exclusive size="small" value="PEDESTRIAN">
                    <ToggleButton value="CAR">Auto</ToggleButton>
                    <ToggleButton value="TRAM">ÖPNV</ToggleButton>
                    <ToggleButton value="PEDESTRIAN">Fussg.</ToggleButton>
                  </ToggleButtonGroup>
                </Stack>
                <Stack spacing={0.5}>
                  <Typography variant="caption" color="text.secondary">
                    Vorschau
                  </Typography>
                  <SignalGroupTrafficLightPreview trafficType="PEDESTRIAN" turnDirections={[]} />
                  <Typography variant="caption" color="text.secondary">
                    Fußgängerampeln der Furt hinzufügen.
                  </Typography>
                </Stack>
              </Box>
            </Stack>
            <Stack spacing={1.25}>
              <Stack direction="row" spacing={1} alignItems="flex-start">
                <SectionTitle helper="Füge beide EEP-Fußgängerampeln hinzu, die zur Furt gehören.">
                  Fußgängerampeln aus EEP
                </SectionTitle>
                <Box sx={{ flex: 1 }} />
                <Button size="small" startIcon={<AddIcon />}>
                  Fußgängerampel hinzufügen
                </Button>
              </Stack>
              <TableContainer component={Box} sx={{ border: 1, borderColor: 'divider', borderRadius: 1 }}>
                <Table size="small" aria-label="Fußgängerampeln aus EEP">
                  <TableBody>
                    <TableRow>
                      <TableCell sx={{ color: 'text.secondary' }}>Noch keine EEP-Ampel hinzugefügt.</TableCell>
                    </TableRow>
                  </TableBody>
                </Table>
              </TableContainer>
            </Stack>
          </Stack>
        </Paper>
      </Stack>
    </Box>
  );
}

const meta = {
  title: 'Module Elements/Road/Signal Group Card Proposal',
  component: AmpelGroupCardProposal,
} satisfies Meta<typeof AmpelGroupCardProposal>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AmpelGroupLanguage: Story = {};
