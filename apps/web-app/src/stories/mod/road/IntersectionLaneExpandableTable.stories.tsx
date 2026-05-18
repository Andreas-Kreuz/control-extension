import { useState } from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import type { Meta, StoryObj } from '@storybook/react';
import type { IntersectionWizardApproach, IntersectionWizardTurnDirection } from '@ce/web-shared';
import { IconHeadline } from '../../../shared/components/headlines';
import {
  Approach,
  ExpandableEditorTableRow,
  FormApproachSelect,
  FormSelect,
  FormTextfield,
  FormTurnToggle,
  NeutralTurnToggle,
} from '../../../shared/components/road';

type LaneEditorFixture = {
  id: string;
  name: string;
  luaVariableName: string;
  approach: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
  signalId: string;
  signalName: string;
  signalModel: string;
  vehicleMultiplier: string;
};

const sectionGridSx = {
  display: 'grid',
  gridTemplateColumns: { xs: '1fr', md: 'repeat(3, minmax(0, 1fr))' },
  gap: 1.5,
  alignItems: 'start',
};

const compactColumnSx = {
  width: '1px',
  whiteSpace: 'nowrap',
};

const initialLanes: LaneEditorFixture[] = [
  {
    id: 'lane-1',
    name: 'c1Fs1',
    luaVariableName: 'c1Lane1',
    approach: 'NORTH',
    turnDirections: ['STRAIGHT'],
    signalId: '92',
    signalName: 'K1',
    signalModel: 'JS2_3er_mit_FG',
    vehicleMultiplier: '1',
  },
  {
    id: 'lane-2',
    name: 'c1Fs2',
    luaVariableName: 'c1Lane2',
    approach: 'EAST',
    turnDirections: ['LEFT', 'STRAIGHT'],
    signalId: '91',
    signalName: 'K2',
    signalModel: 'JS2_3er_mit_FG',
    vehicleMultiplier: '1.5',
  },
  {
    id: 'lane-3',
    name: 'tramWest',
    luaVariableName: 'c1TramWest',
    approach: 'WEST',
    turnDirections: ['LEFT'],
    signalId: '',
    signalName: 'S1',
    signalModel: 'MA1_STRAB_3er_2_gruen',
    vehicleMultiplier: '2',
  },
];

const signalModelOptions = ['JS2_3er_mit_FG', 'JS2_2er_OFF_YELLOW_GREEN', 'MA1_STRAB_3er_2_gruen', 'Unsichtbar_2er'];

function IntersectionLaneExpandableTablePrototype() {
  const [lanes, setLanes] = useState(initialLanes);
  const [expandedLaneId, setExpandedLaneId] = useState<string | null>(initialLanes[0]?.id ?? null);

  function updateLane(id: string, patch: Partial<LaneEditorFixture>) {
    setLanes((current) => current.map((lane) => (lane.id === id ? { ...lane, ...patch } : lane)));
  }

  function toggleLane(laneId: string) {
    setExpandedLaneId((current) => (current === laneId ? null : laneId));
  }

  function addLane() {
    const nextIndex =
      lanes.reduce((maxIndex, lane) => {
        const laneIndex = Number(lane.id.replace(/^lane-/, ''));
        return Number.isFinite(laneIndex) ? Math.max(maxIndex, laneIndex) : maxIndex;
      }, 0) + 1;
    const lane: LaneEditorFixture = {
      id: `lane-${nextIndex}`,
      name: `c1Fs${nextIndex}`,
      luaVariableName: `c1Lane${nextIndex}`,
      approach: 'NORTH',
      turnDirections: [],
      signalId: '',
      signalName: `K${nextIndex}`,
      signalModel: signalModelOptions[0],
      vehicleMultiplier: '1',
    };

    setLanes((current) => [...current, lane]);
    setExpandedLaneId(lane.id);
  }

  function deleteLane(laneId: string) {
    setLanes((current) => current.filter((lane) => lane.id !== laneId));
    setExpandedLaneId((current) => (current === laneId ? null : current));
  }

  function renderEditor(lane: LaneEditorFixture) {
    const signalIdErrorTexts =
      lane.signalId.trim().length === 0 ? ['Fahrspur-Signal-ID fehlt für diese Fahrspur.'] : [];

    return (
      <Box sx={{ py: 2 }}>
        <Stack spacing={2.5}>
          <Stack spacing={1.25}>
            <Typography variant="subtitle2">Fahrspur</Typography>
            <Box sx={sectionGridSx}>
              <FormApproachSelect
                id={`${lane.id}-approach`}
                value={lane.approach}
                infoText="Aus dieser Richtung kommen Fahrzeuge."
                onChange={(approach) => updateLane(lane.id, { approach })}
              />
              <FormTurnToggle
                label="Abbiegerichtungen"
                value={lane.turnDirections}
                infoText="Wähle die Abbiegerichtungen."
                onChange={(turnDirections) => updateLane(lane.id, { turnDirections })}
              />
              <FormTextfield
                label="Name der Fahrspur"
                value={lane.name}
                infoText="Dient nur der Anzeige."
                onChange={(event) => updateLane(lane.id, { name: event.target.value })}
              />
            </Box>
          </Stack>
          <Stack spacing={1.25}>
            <Typography variant="subtitle2">Fahrspur-Signal</Typography>
            <Box sx={sectionGridSx}>
              <FormTextfield
                label="Signal-ID"
                value={lane.signalId}
                errorTexts={signalIdErrorTexts}
                infoText="Fahrspur-Signal-ID aus EEP."
                onChange={(event) => updateLane(lane.id, { signalId: event.target.value })}
              />
              <FormTextfield
                label="Ampelname"
                value={lane.signalName}
                infoText="Angezeigter Name der Ampel."
                onChange={(event) => updateLane(lane.id, { signalName: event.target.value })}
              />
              <FormSelect
                id={`${lane.id}-signal-model`}
                label="Ampelmodell"
                value={lane.signalModel}
                infoText="Wähle aus der Liste aus."
                onChange={(signalModel) => updateLane(lane.id, { signalModel })}
                options={signalModelOptions.map((signalModel) => ({
                  value: signalModel,
                  label: signalModel,
                }))}
              />
            </Box>
          </Stack>
          <Stack spacing={1.25}>
            <Typography variant="subtitle2">Erweiterte Einstellungen</Typography>
            <Box sx={sectionGridSx}>
              <FormTextfield
                label="Lua-Variablenname"
                value={lane.luaVariableName}
                infoText="Eindeutiger Name für Kontaktpunkte."
                onChange={(event) => updateLane(lane.id, { luaVariableName: event.target.value })}
              />
              <FormTextfield
                label="Fahrzeugmultiplikator"
                value={lane.vehicleMultiplier}
                infoText="Je höher, desto mehr Priorität."
                onChange={(event) => updateLane(lane.id, { vehicleMultiplier: event.target.value })}
              />
            </Box>
          </Stack>
        </Stack>
      </Box>
    );
  }

  return (
    <Stack spacing={2} sx={{ maxWidth: 1280 }}>
      <IconHeadline text="Fahrspuren" icon={<DirectionsCarIcon />} variant="h6" />
      <TableContainer component={Paper} variant="outlined">
        <Table
          size="small"
          aria-label="Fahrspuren mit Editor"
          sx={{
            '& tbody tr:last-of-type td': {
              borderBottom: 0,
            },
          }}
        >
          <TableHead>
            <TableRow>
              <TableCell sx={{ width: 56 }} />
              <TableCell sx={compactColumnSx}>Zufahrt aus</TableCell>
              <TableCell sx={compactColumnSx}>Abbiegerichtungen</TableCell>
              <TableCell sx={compactColumnSx}>Fahrspur</TableCell>
              <TableCell sx={compactColumnSx}>Signal</TableCell>
              <TableCell sx={compactColumnSx}>Ampel</TableCell>
              <TableCell sx={compactColumnSx}>Ampelmodell</TableCell>
              <TableCell />
              <TableCell align="right" sx={{ width: 56 }} />
            </TableRow>
          </TableHead>
          <TableBody>
            {lanes.map((lane) => (
              <ExpandableEditorTableRow
                key={lane.id}
                ariaLabel={lane.name}
                expanded={expandedLaneId === lane.id}
                dataCellCount={7}
                deletable
                editor={renderEditor(lane)}
                onDelete={() => deleteLane(lane.id)}
                onToggle={() => toggleLane(lane.id)}
              >
                <TableCell sx={compactColumnSx}>
                  <Approach approach={lane.approach} />
                </TableCell>
                <TableCell sx={compactColumnSx}>
                  <NeutralTurnToggle value={lane.turnDirections} />
                </TableCell>
                <TableCell sx={compactColumnSx}>{lane.name || '-'}</TableCell>
                <TableCell sx={compactColumnSx}>{lane.signalId || '-'}</TableCell>
                <TableCell sx={compactColumnSx}>{lane.signalName || '-'}</TableCell>
                <TableCell sx={compactColumnSx}>{lane.signalModel || '-'}</TableCell>
                <TableCell />
              </ExpandableEditorTableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
      <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
        <Button variant="contained" color="primary" onClick={addLane}>
          FAHRSPUR HINZUFÜGEN
        </Button>
      </Box>
    </Stack>
  );
}

const meta = {
  title: 'Module Elements/Road/Intersection Lane Expandable Table',
  component: IntersectionLaneExpandableTablePrototype,
} satisfies Meta<typeof IntersectionLaneExpandableTablePrototype>;

export default meta;
type Story = StoryObj<typeof meta>;

export const AccordionEditorTable: Story = {};
