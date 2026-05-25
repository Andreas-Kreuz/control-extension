import { useEffect, useMemo, useState } from 'react';
import type { HTMLAttributes } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Paper from '@mui/material/Paper';
import Select from '@mui/material/Select';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import PhotoCameraIcon from '@mui/icons-material/PhotoCamera';
import VerticalAlignCenterIcon from '@mui/icons-material/VerticalAlignCenter';
import type {
  AlignStructureSignalInstallerCommandAppDto,
  FocusStructureSignalInstallerCameraCommandAppDto,
  StructureAppDto,
  StructureSignalInstallerHousingKind,
} from '@ce/web-shared';
import { FeedbackMessage } from '../../../../shared/components/feedback';
import {
  buildAlignStructureSignalInstallerCommand,
  buildFocusStructureSignalInstallerCameraCommand,
  housingKindOptions,
  inferHousingKind,
  installedSignalsFromTag,
  isBlendStructureName,
  isHousingStructureName,
  isSignalStructureName,
  parseInstallerTag,
  signalCountForHousingKind,
} from './structureSignalInstallerLogic';

export interface StructureSignalInstallerProps {
  onFocusCamera: (command: FocusStructureSignalInstallerCameraCommandAppDto) => void;
  onAlign: (command: AlignStructureSignalInstallerCommandAppDto) => void;
  onHousingSelectionChange?: (housingId: string) => void;
  structures: StructureAppDto[];
}

type HousingKindValue = StructureSignalInstallerHousingKind | '';

const formGridSx = {
  display: 'grid',
  gap: 2,
  gridTemplateColumns: { xs: '1fr', md: 'minmax(0, 1fr) minmax(0, 1fr)' },
  alignItems: 'start',
};

function structureSearchText(structure: StructureAppDto): string {
  return `${structure.name} ${structure.gsbname ?? ''}`;
}

function sortedStructureNames(
  structures: StructureAppDto[],
  predicate: (structure: StructureAppDto) => boolean,
): string[] {
  return Array.from(new Set(structures.filter(predicate).map((structure) => structure.name))).sort((a, b) =>
    a.localeCompare(b, undefined, { numeric: true }),
  );
}

function resizeSignals(signals: string[], signalCount: number): string[] {
  return Array.from({ length: signalCount }, (_entry, index) => signals[index] ?? '');
}

function structureDistanceLabel(
  structureName: string,
  housing: StructureAppDto | undefined,
  structureByName: Map<string, StructureAppDto>,
): string {
  const structure = structureByName.get(structureName);
  if (!housing || !structure) return structureName;
  const distance = Math.hypot(structure.pos_x - housing.pos_x, structure.pos_y - housing.pos_y);
  if (!Number.isFinite(distance)) return structureName;
  return `${structureName} (${distance.toFixed(1)} m)`;
}

function sortStructureNamesByDistance(
  structureNames: string[],
  housing: StructureAppDto | undefined,
  structureByName: Map<string, StructureAppDto>,
): string[] {
  if (!housing) return structureNames;
  return [...structureNames].sort((leftName, rightName) => {
    const left = structureByName.get(leftName);
    const right = structureByName.get(rightName);
    if (!left && !right) return leftName.localeCompare(rightName, undefined, { numeric: true });
    if (!left) return 1;
    if (!right) return -1;
    const leftDistance = Math.hypot(left.pos_x - housing.pos_x, left.pos_y - housing.pos_y);
    const rightDistance = Math.hypot(right.pos_x - housing.pos_x, right.pos_y - housing.pos_y);
    if (leftDistance !== rightDistance) return leftDistance - rightDistance;
    return leftName.localeCompare(rightName, undefined, { numeric: true });
  });
}

function StructureSignalInstaller({
  onAlign,
  onFocusCamera,
  onHousingSelectionChange,
  structures,
}: StructureSignalInstallerProps) {
  const [housingName, setHousingName] = useState('');
  const [housingKind, setHousingKind] = useState<HousingKindValue>('');
  const [blendName, setBlendName] = useState('');
  const [signals, setSignals] = useState<string[]>([]);
  const [status, setStatus] = useState('');

  const structureByName = useMemo(
    () => new Map(structures.map((structure) => [structure.name, structure])),
    [structures],
  );
  const housingOptions = useMemo(
    () => sortedStructureNames(structures, (structure) => isHousingStructureName(structureSearchText(structure))),
    [structures],
  );
  const signalOptions = useMemo(
    () => sortedStructureNames(structures, (structure) => isSignalStructureName(structureSearchText(structure))),
    [structures],
  );
  const blendOptions = useMemo(
    () => sortedStructureNames(structures, (structure) => isBlendStructureName(structureSearchText(structure))),
    [structures],
  );
  const selectedHousing = structureByName.get(housingName);
  const signalCount = signalCountForHousingKind(housingKind);
  const canAlign = Boolean(selectedHousing && housingKind && signalCount > 0);

  useEffect(() => {
    onHousingSelectionChange?.(selectedHousing?.id ?? '');
  }, [onHousingSelectionChange, selectedHousing?.id]);

  const sortedSignalOptions = useMemo(
    () => sortStructureNamesByDistance(signalOptions, selectedHousing, structureByName),
    [selectedHousing, signalOptions, structureByName],
  );
  const sortedBlendOptions = useMemo(
    () => sortStructureNamesByDistance(blendOptions, selectedHousing, structureByName),
    [blendOptions, selectedHousing, structureByName],
  );
  const renderStructureOption = (props: HTMLAttributes<HTMLLIElement>, option: string) => (
    <li {...props}>{structureDistanceLabel(option, selectedHousing, structureByName)}</li>
  );

  function applyHousingName(nextHousingName: string) {
    setHousingName(nextHousingName);
    setStatus('');
    const nextHousing = structureByName.get(nextHousingName);
    const nextHousingKind = inferHousingKind(nextHousingName);
    const resolvedHousingKind = nextHousingKind ?? housingKind;
    if (nextHousingKind) setHousingKind(nextHousingKind);
    const nextSignalCount = signalCountForHousingKind(resolvedHousingKind);
    if (nextHousing) {
      setSignals(installedSignalsFromTag(nextHousing.tag, nextSignalCount));
      setBlendName(parseInstallerTag(nextHousing.tag).bl ?? '');
      return;
    }
    setSignals((current) => resizeSignals(current, nextSignalCount));
  }

  function applyHousingKind(nextHousingKind: HousingKindValue) {
    setHousingKind(nextHousingKind);
    setSignals((current) => resizeSignals(current, signalCountForHousingKind(nextHousingKind)));
  }

  function applySignal(index: number, value: string) {
    setStatus('');
    setSignals((current) => current.map((signalName, signalIndex) => (signalIndex === index ? value : signalName)));
  }

  function alignStructures() {
    if (!selectedHousing || !housingKind) {
      setStatus('Wähle ein bekanntes Gehäuse aus der EEP-Liste.');
      return;
    }
    onAlign(buildAlignStructureSignalInstallerCommand(selectedHousing, housingKind, signals, blendName));
    setStatus('Ausrichtungsbefehl wurde an EEP gesendet.');
  }

  function focusCameraOnHousing() {
    if (!selectedHousing) {
      setStatus('Wähle ein bekanntes Gehäuse aus der EEP-Liste.');
      return;
    }
    onFocusCamera(buildFocusStructureSignalInstallerCameraCommand(selectedHousing));
    setStatus('Kamerabefehl wurde an EEP gesendet.');
  }

  return (
    <Paper variant="outlined" sx={{ p: 2, maxWidth: 1120 }}>
      <Stack spacing={2}>
        <Box sx={formGridSx}>
          <Stack spacing={1.5}>
            <Autocomplete<string, false, false, true>
              freeSolo
              options={housingOptions}
              value={housingName}
              inputValue={housingName}
              onChange={(_event, value) => applyHousingName(value ?? '')}
              onInputChange={(_event, value, reason) => {
                if (reason === 'input' || reason === 'clear') applyHousingName(value);
              }}
              renderInput={(params) => <TextField {...params} label="Gehäuse" size="small" />}
            />
            <FormControl size="small" fullWidth>
              <InputLabel id="structure-signal-installer-housing-kind-label">Gehäuseart</InputLabel>
              <Select
                labelId="structure-signal-installer-housing-kind-label"
                label="Gehäuseart"
                value={housingKind}
                onChange={(event) => applyHousingKind(event.target.value as HousingKindValue)}
              >
                <MenuItem value="" disabled>
                  Gehäuseart wählen
                </MenuItem>
                {housingKindOptions.map((option) => (
                  <MenuItem key={option.value} value={option.value}>
                    {option.label}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <Autocomplete<string, false, false, true>
              freeSolo
              options={sortedBlendOptions}
              value={blendName}
              inputValue={blendName}
              onChange={(_event, value) => setBlendName(value ?? '')}
              onInputChange={(_event, value, reason) => {
                if (reason === 'input' || reason === 'clear') setBlendName(value);
              }}
              renderOption={renderStructureOption}
              renderInput={(params) => <TextField {...params} label="Blendschutz" size="small" />}
            />
          </Stack>
          <Stack spacing={1.5}>
            {signalCount === 0 ? (
              <FeedbackMessage severity="info">Wähle ein Gehäuse aus.</FeedbackMessage>
            ) : (
              signals.map((signalName, index) => (
                <Autocomplete<string, false, false, true>
                  freeSolo
                  key={index}
                  options={sortedSignalOptions}
                  value={signalName}
                  inputValue={signalName}
                  onChange={(_event, value) => applySignal(index, value ?? '')}
                  onInputChange={(_event, value, reason) => {
                    if (reason === 'input' || reason === 'clear') applySignal(index, value);
                  }}
                  renderOption={renderStructureOption}
                  renderInput={(params) => <TextField {...params} label={`Signal ${index + 1}`} size="small" />}
                />
              ))
            )}
          </Stack>
        </Box>
        {status && <FeedbackMessage severity={canAlign ? 'success' : 'warning'}>{status}</FeedbackMessage>}
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1, flexWrap: 'wrap' }}>
          <Button
            variant="outlined"
            startIcon={<PhotoCameraIcon />}
            disabled={!selectedHousing}
            onClick={focusCameraOnHousing}
          >
            Kamera auf Gehäuse
          </Button>
          <Button
            variant="contained"
            startIcon={<VerticalAlignCenterIcon />}
            disabled={!canAlign}
            onClick={alignStructures}
          >
            An Gehäuse ausrichten
          </Button>
        </Box>
      </Stack>
    </Paper>
  );
}

export default StructureSignalInstaller;
