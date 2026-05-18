import { useState } from 'react';
import type { ReactNode } from 'react';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Stack from '@mui/material/Stack';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import type { Meta, StoryObj } from '@storybook/react';
import type { IntersectionWizardApproach, IntersectionWizardTurnDirection } from '@ce/web-shared';
import {
  Approach,
  ExpandableEditorTableRow,
  FormApproachSelect,
  FormSelect,
  FormTextfield,
  FormTurnToggle,
  NeutralTurnToggle,
} from '../../shared/components/road';

type RoadFormElementsFixture = {
  approach: IntersectionWizardApproach;
  turnDirections: IntersectionWizardTurnDirection[];
  signalId: string;
  signalModel: string;
};

const signalModelOptions = ['JS2_3er_mit_FG', 'JS2_2er_OFF_YELLOW_GREEN', 'MA1_STRAB_3er_2_gruen', 'Unsichtbar_2er'];

function ElementExample(props: { children: ReactNode; className: string; index: number; name: string }) {
  return (
    <Stack className={props.className} spacing={0.75}>
      <Typography variant="caption" color="text.secondary">
        {props.index}. {props.name} ({props.className})
      </Typography>
      {props.children}
    </Stack>
  );
}

function FormElementPair(props: {
  error: ReactNode;
  errorClassName: string;
  index: number;
  name: string;
  normal: ReactNode;
  normalClassName: string;
}) {
  return (
    <Stack spacing={1}>
      <Typography variant="subtitle2">
        {props.index}. {props.name}
      </Typography>
      <Box
        sx={{
          display: 'grid',
          gridTemplateColumns: { xs: '1fr', md: 'repeat(2, minmax(0, 1fr))' },
          gap: 2,
        }}
      >
        <ElementExample index={props.index} name={`${props.name} ohne Fehler`} className={props.normalClassName}>
          {props.normal}
        </ElementExample>
        <ElementExample index={props.index} name={`${props.name} mit Fehler`} className={props.errorClassName}>
          {props.error}
        </ElementExample>
      </Box>
    </Stack>
  );
}

function RoadFormElementsPrototype() {
  const [values, setValues] = useState<RoadFormElementsFixture>({
    approach: 'NORTH',
    turnDirections: ['STRAIGHT'],
    signalId: '',
    signalModel: 'JS2_3er_mit_FG',
  });
  const [expanded, setExpanded] = useState(true);

  return (
    <Stack spacing={3} sx={{ maxWidth: 980 }}>
      <Stack spacing={1}>
        <Typography variant="h6">Anzeigeelemente</Typography>
        <Stack direction="row" spacing={3} alignItems="center">
          <ElementExample index={1} name="Approach" className="road-element-01-approach">
            <Approach approach={values.approach} />
          </ElementExample>
          <ElementExample index={2} name="NeutralTurnToggle" className="road-element-02-neutral-turn-toggle">
            <NeutralTurnToggle value={values.turnDirections} />
          </ElementExample>
        </Stack>
      </Stack>

      <Stack spacing={2.5}>
        <Typography variant="h6">Formularelemente</Typography>
        <FormElementPair
          index={3}
          name="FormApproachSelect"
          normalClassName="road-element-03-form-approach-select"
          errorClassName="road-element-03-form-approach-select-error"
          normal={
            <FormApproachSelect
              id="road-elements-approach"
              value={values.approach}
              infoText="Aus dieser Richtung kommen Fahrzeuge."
              onChange={(approach) => setValues((current) => ({ ...current, approach }))}
            />
          }
          error={
            <FormApproachSelect
              id="road-elements-approach-error"
              value={values.approach}
              errorTexts={['Zufahrt fehlt.']}
              infoText="Aus dieser Richtung kommen Fahrzeuge."
              onChange={(approach) => setValues((current) => ({ ...current, approach }))}
            />
          }
        />
        <FormElementPair
          index={4}
          name="FormTurnToggle"
          normalClassName="road-element-04-form-turn-toggle"
          errorClassName="road-element-04-form-turn-toggle-error"
          normal={
            <FormTurnToggle
              label="Abbiegerichtungen"
              value={values.turnDirections}
              infoText="Wähle die Abbiegerichtungen."
              onChange={(turnDirections) => setValues((current) => ({ ...current, turnDirections }))}
            />
          }
          error={
            <FormTurnToggle
              label="Abbiegerichtungen"
              value={values.turnDirections}
              errorTexts={['Mindestens eine Abbiegerichtung ist erforderlich.']}
              infoText="Wähle die Abbiegerichtungen."
              onChange={(turnDirections) => setValues((current) => ({ ...current, turnDirections }))}
            />
          }
        />
        <FormElementPair
          index={5}
          name="FormTextfield"
          normalClassName="road-element-05-form-textfield"
          errorClassName="road-element-05-form-textfield-error"
          normal={
            <FormTextfield
              label="Signal-ID"
              value={values.signalId}
              infoText="Fahrspur-Signal-ID aus EEP."
              onChange={(event) => setValues((current) => ({ ...current, signalId: event.target.value }))}
            />
          }
          error={
            <FormTextfield
              label="Signal-ID"
              value={values.signalId}
              errorTexts={['Fahrspur-Signal-ID fehlt für diese Fahrspur.']}
              infoText="Fahrspur-Signal-ID aus EEP."
              onChange={(event) => setValues((current) => ({ ...current, signalId: event.target.value }))}
            />
          }
        />
        <FormElementPair
          index={6}
          name="FormSelect"
          normalClassName="road-element-06-form-select"
          errorClassName="road-element-06-form-select-error"
          normal={
            <FormSelect
              id="road-elements-signal-model"
              label="Ampelmodell"
              value={values.signalModel}
              infoText="Wähle aus der Liste aus."
              onChange={(signalModel) => setValues((current) => ({ ...current, signalModel }))}
              options={signalModelOptions.map((signalModel) => ({
                value: signalModel,
                label: signalModel,
              }))}
            />
          }
          error={
            <FormSelect
              id="road-elements-signal-model-error"
              label="Ampelmodell"
              value={values.signalModel}
              errorTexts={['Ampelmodell fehlt.']}
              infoText="Wähle aus der Liste aus."
              onChange={(signalModel) => setValues((current) => ({ ...current, signalModel }))}
              options={signalModelOptions.map((signalModel) => ({
                value: signalModel,
                label: signalModel,
              }))}
            />
          }
        />
      </Stack>

      <Stack spacing={1.5}>
        <Typography variant="h6">Tabellenzeile</Typography>
        <ElementExample
          index={7}
          name="ExpandableEditorTableRow"
          className="road-element-07-expandable-editor-table-row"
        >
          <TableContainer component={Paper} variant="outlined">
            <Table size="small" aria-label="Road form element table row">
              <TableHead>
                <TableRow>
                  <TableCell sx={{ width: 56 }} />
                  <TableCell>Zufahrt aus</TableCell>
                  <TableCell>Abbiegerichtungen</TableCell>
                  <TableCell />
                  <TableCell align="right" sx={{ width: 56 }} />
                </TableRow>
              </TableHead>
              <TableBody>
                <ExpandableEditorTableRow
                  ariaLabel="Beispiel-Fahrspur"
                  expanded={expanded}
                  dataCellCount={3}
                  deletable
                  editor={
                    <Box sx={{ py: 2 }}>
                      <Typography variant="body2">Editor-Inhalt</Typography>
                    </Box>
                  }
                  onDelete={() => setExpanded(false)}
                  onToggle={() => setExpanded((current) => !current)}
                >
                  <TableCell>
                    <Approach approach={values.approach} />
                  </TableCell>
                  <TableCell>
                    <NeutralTurnToggle value={values.turnDirections} />
                  </TableCell>
                  <TableCell />
                </ExpandableEditorTableRow>
              </TableBody>
            </Table>
          </TableContainer>
        </ElementExample>
      </Stack>
    </Stack>
  );
}

const meta = {
  title: 'Elements/Road/Form Elements',
  component: RoadFormElementsPrototype,
} satisfies Meta<typeof RoadFormElementsPrototype>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Overview: Story = {};
