import { CommandEvent, RollingStockAppDto, TrainAppDto } from '@ce/web-shared';
import AssignmentIcon from '@mui/icons-material/Assignment';
import CommitIcon from '@mui/icons-material/Commit';
import CompareArrowsIcon from '@mui/icons-material/CompareArrows';
import DashboardIcon from '@mui/icons-material/Dashboard';
import DirectionsRailwayIcon from '@mui/icons-material/DirectionsRailway';
import FileUploadIcon from '@mui/icons-material/FileUpload';
import RouteIcon from '@mui/icons-material/Route';
import SpeedIcon from '@mui/icons-material/Speed';
import TextFieldsIcon from '@mui/icons-material/TextFields';
import TuneIcon from '@mui/icons-material/Tune';
import VideocamIcon from '@mui/icons-material/Videocam';
import ViewInArIcon from '@mui/icons-material/ViewInAr';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import Grid from '@mui/material/Grid';
import IconButton from '@mui/material/IconButton';
import LabelIcon from '@mui/icons-material/LabelOutlined';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Slider from '@mui/material/Slider';
import Stack from '@mui/material/Stack';
import Tooltip from '@mui/material/Tooltip';
import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';
import Typography from '@mui/material/Typography';
import { ReactNode, useEffect, useMemo, useRef, useState } from 'react';
import { AxisList, AxisSlider } from '../../../shared/components/axises';
import IconHeaderCard from '../../../shared/components/cards/IconHeaderCard';
import CardGridContainer from '../../../shared/layouts/CardGridContainer';
import PageContainer from '../../../shared/layouts/PageContainer';
import PageHeadline from '../../../shared/layouts/PageHeadline';
import { useSocket } from '../../../app/hooks/useSocket';
import useDebug from '../../../shared/socket/useDebug';
import TrainLineView from '../../trains/components/TrainLineView';
import useRollingStock from '../../trains/hooks/useRollingStock';
import useRollingStockDynamic from '../../trains/hooks/useRollingStockDynamic';
import useSetRollingStockCam from '../../trains/hooks/useSetRollingStockCam';
import useSetTrainCam from '../../trains/hooks/useSetTrainCam';
import useTrainDynamic from '../../trains/hooks/useTrainDynamic';
import useTrainRollingStock from '../../trains/hooks/useTrainRollingStock';
import useTransitTrain from '../../trains/hooks/useTransitTrain';
import useTransitSettings from '../../lines/hooks/useTransitSettings';
import useSelectedScenario from '../hooks/useSelectedScenario';
import useSetTrainCoupling from '../hooks/useSetTrainCoupling';
import useSetTrainLight from '../hooks/useSetTrainLight';
import useSetTrainSpeed from '../hooks/useSetTrainSpeed';

const trainLightSources = [
  { source: 0, label: 'Fahrlicht', enabledLabel: 'Ein' },
  { source: 3, label: 'Bremslicht', enabledLabel: 'Ein' },
  { source: 1, label: 'Blinker links', enabledLabel: 'Ein' },
  { source: 2, label: 'Blinker rechts', enabledLabel: 'Ein' },
];

const trainCameraSources = [
  { key: 3, label: 'Links oben' },
  { key: 4, label: 'Rechts oben' },
  { key: 8, label: 'Führerstand' },
  { key: -1, label: 'Front' },
  { key: -2, label: 'Front 2' },
  { key: 10, label: 'Kabine' },
];

const optimisticSwitchTimeoutMs = 5000;
type TransitInfo = {
  line: string;
  destination: string;
  nextStations: NonNullable<TrainAppDto['nextStations']>;
};

function SelectedTrainDashboard() {
  const scenario = useSelectedScenario();
  const [selectionSource, setSelectionSource] = useState<'train' | 'rollingStock' | undefined>();
  const previousSelection = useRef<{ activeTrain: string; activeRollingStock: string }>({
    activeTrain: '',
    activeRollingStock: '',
  });
  const selectedTrainName = scenario?.activeTrain ?? '';
  const selectedRollingStockName = scenario?.activeRollingStock ?? '';
  const activeRollingStock = useRollingStock(selectedRollingStockName);
  const effectiveSelectionSource =
    selectionSource ?? (selectedRollingStockName ? 'rollingStock' : selectedTrainName ? 'train' : undefined);
  const trainId =
    effectiveSelectionSource === 'rollingStock'
      ? activeRollingStock && isSelectedRollingStock(activeRollingStock, selectedRollingStockName)
        ? activeRollingStock.trainName
        : ''
      : selectedTrainName;
  const train = useTrainDynamic(trainId);
  const rollingStock = useTrainRollingStock(trainId);
  const transitTrain = useTransitTrain(trainId);
  const transitSettings = useTransitSettings();
  const cameraRollingStockName = rollingStock?.[0]?.name ?? activeRollingStock?.name ?? train?.name ?? trainId;
  const trainRollingStock = rollingStock ?? [];

  useEffect(() => {
    const currentSelection = {
      activeTrain: selectedTrainName,
      activeRollingStock: selectedRollingStockName,
    };
    const previous = previousSelection.current;
    previousSelection.current = currentSelection;

    setSelectionSource((currentSource) => {
      if (!previous.activeTrain && !previous.activeRollingStock) {
        return (
          currentSource ??
          (currentSelection.activeRollingStock ? 'rollingStock' : currentSelection.activeTrain ? 'train' : undefined)
        );
      }
      if (currentSelection.activeTrain && currentSelection.activeTrain !== previous.activeTrain) {
        return 'train';
      }
      if (currentSelection.activeRollingStock && currentSelection.activeRollingStock !== previous.activeRollingStock) {
        return 'rollingStock';
      }
      if (currentSelection.activeTrain && !currentSelection.activeRollingStock) {
        return 'train';
      }
      if (currentSelection.activeRollingStock && !currentSelection.activeTrain) {
        return 'rollingStock';
      }

      return currentSource;
    });
  }, [selectedRollingStockName, selectedTrainName]);

  if (!scenario?.activeRollingStock && !scenario?.activeTrain) {
    return (
      <PageContainer>
        <PageHeadline>Aktiver Zug</PageHeadline>
        <EmptyDashboardState />
      </PageContainer>
    );
  }

  if (!train) {
    return (
      <PageContainer>
        <PageHeadline>Aktiver Zug</PageHeadline>
        <IconHeaderCard title="Zugdaten" icon={<DashboardIcon color="primary" />}>
          <Typography variant="body2" color="textSecondary">
            Zugdaten werden geladen.
          </Typography>
        </IconHeaderCard>
      </PageContainer>
    );
  }

  const transitNextStations = transitTrain?.nextStations ?? train.nextStations ?? [];
  const showTransitSection = Boolean(
    transitSettings &&
    (transitTrain?.line ||
      train.line ||
      transitTrain?.destination ||
      train.destination ||
      transitNextStations.length > 0),
  );
  const showRollingStockSection = trainRollingStock.length > 0;

  return (
    <PageContainer>
      <PageHeadline>Aktiver Zug</PageHeadline>
      <Stack spacing={2}>
        <CardGridContainer>
          <Grid size={{ xs: 12 }}>
            <TrainHeadline
              selected={train.active || selectedTrainName === train.id || selectedTrainName === train.name}
              train={train}
            />
          </Grid>
          <TrainOverviewPanel
            cameraRollingStockName={cameraRollingStockName}
            train={train}
            rollingStock={trainRollingStock}
            selectedRollingStockName={selectedRollingStockName}
            transit={
              showTransitSection
                ? {
                    line: transitTrain?.line ?? train.line ?? '-',
                    destination: transitTrain?.destination ?? train.destination ?? '-',
                    nextStations: transitNextStations,
                  }
                : undefined
            }
          />
          {showRollingStockSection && (
            <RollingStockGrid rollingStock={trainRollingStock} selectedRollingStockName={selectedRollingStockName} />
          )}
        </CardGridContainer>
      </Stack>
    </PageContainer>
  );
}

function TrainHeadline(props: { selected: boolean; train: TrainAppDto }) {
  return (
    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0, mt: 1 }}>
      <Typography variant="h6" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
        Zug
        <Box component="span" sx={{ display: { xs: 'none', sm: 'inline' } }}>
          : {props.train.name || '-'}
        </Box>
      </Typography>
      {props.selected && <Chip size="small" color="primary" label="Ausgewählt" />}
    </Stack>
  );
}

function TrainOverviewPanel(props: {
  cameraRollingStockName: string;
  train: TrainAppDto;
  rollingStock: RollingStockAppDto[];
  selectedRollingStockName: string;
  transit?: TransitInfo;
}) {
  const { train } = props;
  const setSpeed = useSetTrainSpeed();
  const setCoupling = useSetTrainCoupling();
  const setLight = useSetTrainLight();
  const [couplingFront, setCouplingFront] = useState(train.couplingFront);
  const [couplingRear, setCouplingRear] = useState(train.couplingRear);
  const [lights, setLights] = useState(train.lights ?? {});
  const [optimisticState, setOptimisticState] = useState<{
    trainName: string;
    couplingFront?: { value: number; changedAt: number };
    couplingRear?: { value: number; changedAt: number };
    lights: Record<string, { value: boolean; changedAt: number }>;
  }>({ trainName: train.name, lights: {} });

  useEffect(() => {
    const now = Date.now();
    setOptimisticState((previous) => {
      if (previous.trainName !== train.name) {
        setCouplingFront(train.couplingFront);
        setCouplingRear(train.couplingRear);
        setLights(train.lights ?? {});
        return { trainName: train.name, lights: {} };
      }

      const nextOptimisticState = {
        trainName: train.name,
        couplingFront:
          previous.couplingFront &&
          train.couplingFront !== previous.couplingFront.value &&
          now - previous.couplingFront.changedAt < optimisticSwitchTimeoutMs
            ? previous.couplingFront
            : undefined,
        couplingRear:
          previous.couplingRear &&
          train.couplingRear !== previous.couplingRear.value &&
          now - previous.couplingRear.changedAt < optimisticSwitchTimeoutMs
            ? previous.couplingRear
            : undefined,
        lights: Object.fromEntries(
          Object.entries(previous.lights).filter(
            ([source, optimisticLight]) =>
              train.lights?.[source] !== optimisticLight.value &&
              now - optimisticLight.changedAt < optimisticSwitchTimeoutMs,
          ),
        ),
      };

      setCouplingFront(nextOptimisticState.couplingFront?.value ?? train.couplingFront);
      setCouplingRear(nextOptimisticState.couplingRear?.value ?? train.couplingRear);
      setLights({
        ...(train.lights ?? {}),
        ...Object.fromEntries(
          Object.entries(nextOptimisticState.lights).map(([source, optimisticLight]) => [
            source,
            optimisticLight.value,
          ]),
        ),
      });

      return nextOptimisticState;
    });
  }, [train.name, train.couplingFront, train.couplingRear, train.lights]);

  return (
    <>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <InfoCard train={train} transit={props.transit} onSpeedCommit={(value) => setSpeed(train.name, value)} />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <TrainAssociationCard
          couplingFront={couplingFront}
          couplingRear={couplingRear}
          lights={lights}
          rollingStockName={props.cameraRollingStockName}
          trainName={train.name}
          onCouplingChange={(side, checked) => {
            const value = checked ? 1 : 2;
            if (side === 'front') {
              setCouplingFront(value);
              setOptimisticState((previous) => ({
                ...previous,
                trainName: train.name,
                couplingFront: { value, changedAt: Date.now() },
              }));
            } else {
              setCouplingRear(value);
              setOptimisticState((previous) => ({
                ...previous,
                trainName: train.name,
                couplingRear: { value, changedAt: Date.now() },
              }));
            }
            setCoupling(train.name, side, checked);
          }}
          onLightChange={(source, checked) => {
            const sourceKey = String(source);
            setLights((previous) => ({
              ...previous,
              [sourceKey]: checked,
            }));
            setOptimisticState((previous) => ({
              ...previous,
              trainName: train.name,
              lights: {
                ...previous.lights,
                [sourceKey]: { value: checked, changedAt: Date.now() },
              },
            }));
            setLight(train.name, source, checked);
          }}
        />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <MergedAxisCard rollingStock={props.rollingStock} />
      </Grid>
    </>
  );
}

function isSelectedRollingStock(rollingStock: RollingStockAppDto, selectedRollingStockName: string): boolean {
  return rollingStock.id === selectedRollingStockName || rollingStock.name === selectedRollingStockName;
}

function EmptyDashboardState() {
  return (
    <IconHeaderCard title="Kein Zug in EEP ausgewählt" icon={<DashboardIcon color="primary" />}>
      <Typography variant="body2" color="textSecondary">
        Wähle in EEP einen RollingStock oder Zug aus, dann folgt dieses Dashboard automatisch.
      </Typography>
    </IconHeaderCard>
  );
}

function InfoCard(props: { train: TrainAppDto; transit?: TransitInfo; onSpeedCommit: (value: number) => void }) {
  const { train } = props;

  return (
    <IconHeaderCard title="Zug Info" icon={<DirectionsRailwayIcon color="primary" />}>
      <List
        dense
        sx={{
          p: 0,
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        <OverviewMetric icon={<LabelIcon />} label="Name des Zugs" value={train.name || '-'} />
        <OverviewMetric icon={<RouteIcon />} label="EEP-Route" value={train.route || '-'} />
        <OverviewMetric icon={<SpeedIcon />} label="Geschwindigkeit" value={`${train.speed} km/h`} />
        <ListItem sx={{ alignItems: 'flex-start', m: 0, p: 0 }}>
          <SpeedSlider value={train.targetSpeed} onCommit={props.onSpeedCommit} />
        </ListItem>
      </List>
      {props.transit && (
        <>
          <Divider />
          <TrainLineView
            line={props.transit.line}
            destination={props.transit.destination}
            nextStations={props.transit.nextStations}
          />
        </>
      )}
    </IconHeaderCard>
  );
}

function TrainAssociationCard(props: {
  couplingFront: number;
  couplingRear: number;
  lights: Record<string, boolean>;
  rollingStockName: string;
  trainName: string;
  onCouplingChange: (side: 'front' | 'rear', checked: boolean) => void;
  onLightChange: (source: number, checked: boolean) => void;
}) {
  return (
    <IconHeaderCard title="Zug steuern" icon={<TuneIcon color="primary" />}>
      <Stack spacing={3}>
        <ControlGrid>
          <CouplingSegmentedControl
            value={props.couplingFront}
            disabled={props.couplingFront === 0}
            label="Kupplung vorne"
            onChange={(checked) => props.onCouplingChange('front', checked)}
          />
          <CouplingSegmentedControl
            value={props.couplingRear}
            disabled={props.couplingRear === 0}
            label="Kupplung hinten"
            onChange={(checked) => props.onCouplingChange('rear', checked)}
          />
          {trainLightSources.map((entry) => (
            <LightSegmentedControl
              key={entry.source}
              checked={props.lights?.[String(entry.source)] === true}
              label={entry.label}
              enabledLabel={entry.enabledLabel}
              onChange={(checked) => props.onLightChange(entry.source, checked)}
            />
          ))}
          <CameraIconControl trainName={props.trainName} rollingStockName={props.rollingStockName} />
        </ControlGrid>
      </Stack>
    </IconHeaderCard>
  );
}

function ControlGrid(props: { children: ReactNode }) {
  return <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', gap: 1 }}>{props.children}</Box>;
}

function ControlTile(props: { children: ReactNode; sx?: object }) {
  return (
    <Box
      sx={{
        alignItems: 'center',
        display: 'flex',
        minHeight: 72,
        minWidth: 0,
        px: 1.5,
        py: 1,
        width: 1,
        ...props.sx,
      }}
    >
      {props.children}
    </Box>
  );
}

function CouplingSegmentedControl(props: {
  value: number;
  disabled?: boolean;
  label: string;
  onChange: (checked: boolean) => void;
}) {
  return (
    <ControlTile>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.label}
        </Typography>
        <ToggleButtonGroup
          disabled={props.disabled}
          exclusive
          fullWidth
          size="small"
          value={props.value === 1 ? 'on' : 'off'}
          onChange={(_event, value: 'off' | 'on' | null) => {
            if (value !== null) {
              props.onChange(value === 'on');
            }
          }}
          sx={{ mt: 1 }}
        >
          <ToggleButton value="off">Aus</ToggleButton>
          <ToggleButton value="on">Ein</ToggleButton>
        </ToggleButtonGroup>
      </Box>
    </ControlTile>
  );
}

function LightSegmentedControl(props: {
  checked: boolean;
  label: string;
  enabledLabel: string;
  onChange: (checked: boolean) => void;
}) {
  return (
    <ControlTile>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.label}
        </Typography>
        <ToggleButtonGroup
          exclusive
          fullWidth
          size="small"
          value={props.checked ? 'on' : 'off'}
          onChange={(_event, value: 'off' | 'on' | null) => {
            if (value !== null) {
              props.onChange(value === 'on');
            }
          }}
          sx={{ mt: 1 }}
        >
          <ToggleButton value="off">Aus</ToggleButton>
          <ToggleButton value="on">{props.enabledLabel}</ToggleButton>
        </ToggleButtonGroup>
      </Box>
    </ControlTile>
  );
}

function CameraIconControl(props: { trainName: string; rollingStockName: string }) {
  const rollingStock = useRollingStock(props.rollingStockName);
  const setRollingStockCam = useSetRollingStockCam();
  const setTrainCam = useSetTrainCam();
  const debug = useDebug();

  const changeCamera = (key: number) => {
    switch (key) {
      case -1:
      case -2: {
        if (debug) console.log('                 | CAM SET-', props.rollingStockName, rollingStock);
        setRollingStockCam(rollingStock, key);
        setTrainCam(props.trainName, props.rollingStockName, 9);
        break;
      }
      default: {
        setTrainCam(props.trainName, props.rollingStockName, key);
      }
    }
  };

  return (
    <ControlTile sx={{ gridColumn: '1 / -1' }}>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          Kameras
        </Typography>
        <Stack direction="row" spacing={0.5} sx={{ mt: 1, overflowX: 'auto' }}>
          {trainCameraSources.map((camera) => (
            <Tooltip key={camera.key} title={camera.label}>
              <IconButton size="small" aria-label={`Kamera ${camera.label}`} onClick={() => changeCamera(camera.key)}>
                <VideocamIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          ))}
        </Stack>
      </Box>
    </ControlTile>
  );
}

function SpeedSlider(props: { value: number; onCommit: (value: number) => void }) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <>
      <ListItemIcon sx={{ mt: 0.5 }}>
        <SpeedIcon />
      </ListItemIcon>
      <Box sx={{ minWidth: 0, width: 1 }}>
        <ListItemText primary={`${value} km/h`} secondary="Zielgeschwindigkeit" />
        <Box sx={{ px: 1 }}>
          <Slider
            min={-250}
            max={250}
            step={1}
            value={value}
            valueLabelDisplay="auto"
            onChange={(_, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
            onChangeCommitted={(_, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
          />
        </Box>
      </Box>
    </>
  );
}

function OverviewMetric(props: { icon: ReactNode; label: string; value: ReactNode }) {
  return (
    <ListItem sx={{ alignItems: 'flex-start', m: 0, p: 0 }}>
      <ListItemIcon sx={{ mt: 0.5 }}>{props.icon}</ListItemIcon>
      <ListItemText primary={props.value} secondary={props.label} />
    </ListItem>
  );
}

function BreakableModelValue(props: { value: string }) {
  const parts = props.value.split('\\');

  return (
    <>
      {parts.map((part, index) => (
        <span key={`${part}-${index}`}>
          {index > 0 && (
            <>
              {'\\'}
              <wbr />
            </>
          )}
          {part}
        </span>
      ))}
    </>
  );
}

function MergedAxisCard(props: { rollingStock: RollingStockAppDto[] }) {
  const socket = useSocket();
  const canShowTrainAxes =
    props.rollingStock.length === 1 ||
    (props.rollingStock.length > 1 && props.rollingStock.every((item) => item.axisNamesKnown === true));
  const groups = useMemo(
    () => (canShowTrainAxes ? groupAxisByName(props.rollingStock) : []),
    [canShowTrainAxes, props.rollingStock],
  );
  const content =
    !canShowTrainAxes && props.rollingStock.length > 0 ? (
      <Stack spacing={1}>
        <Typography variant="body2" color="textSecondary">
          Achsen im Zug sind erst verfügbar, wenn Achsnamen für alle RollingStocks bekannt sind.
        </Typography>
        <Typography color="textSecondary" variant="caption">
          Hinweis: Setze in den Control-Extension-Optionen den anl3path zur aktuellen Anlage, damit Achsnamen aus den
          Modellressourcen gelesen werden können.
        </Typography>
        <Box
          component="pre"
          sx={{
            bgcolor: 'action.hover',
            borderRadius: 1,
            color: 'text.secondary',
            fontFamily: 'monospace',
            fontSize: '0.75rem',
            m: 0,
            overflowWrap: 'anywhere',
            p: 1,
            whiteSpace: 'pre-wrap',
            wordBreak: 'break-word',
          }}
        >{`local ControlExtension =
require("ce.ControlExtension").setOptions({
  anl3path = "C:\\\\Spiele\\\\Trend\\\\EEP18\\\\Resourcen\\\\Anlagen\\\\meine-anlage.anl3"
})`}</Box>
      </Stack>
    ) : groups.length === 0 ? (
      <Typography variant="body2" color="textSecondary">
        Kein Fahrzeug in diesem Zug hat Achsen.
      </Typography>
    ) : (
      <Stack spacing={2}>
        {groups.map((group) => (
          <AxisSlider
            key={group.name}
            name={group.name}
            value={group.value}
            trailingLabel={`${group.targets.length}x`}
            onCommit={(value) => {
              group.targets.forEach((target) => {
                socket.emit(CommandEvent.SetRollingStockAxis, {
                  rollingStockName: target.rollingStockName,
                  axisNumber: target.axisNumber,
                  axisName: target.axisName,
                  axisNamesKnown: target.axisNamesKnown,
                  value,
                });
              });
            }}
          />
        ))}
      </Stack>
    );

  return (
    <IconHeaderCard title="Achsen des Zugs" icon={<TuneIcon color="primary" />}>
      {content}
    </IconHeaderCard>
  );
}

function RollingStockGrid(props: { rollingStock: RollingStockAppDto[]; selectedRollingStockName: string }) {
  if (props.rollingStock.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Keine RollingStocks gefunden.
      </Typography>
    );
  }

  return (
    <>
      {props.rollingStock.map((item, index) => (
        <RollingStockCards
          key={item.id}
          position={index + 1}
          rollingStock={item}
          selected={props.selectedRollingStockName === item.id || props.selectedRollingStockName === item.name}
          total={props.rollingStock.length}
        />
      ))}
    </>
  );
}

function RollingStockCards(props: {
  position: number;
  rollingStock: RollingStockAppDto;
  selected: boolean;
  total: number;
}) {
  const dynamicRollingStock = useRollingStockDynamic(props.rollingStock.id);
  const rollingStock = mergeRollingStockModelInfo(props.rollingStock, dynamicRollingStock);
  const socket = useSocket();
  const axisEntries = sortedAxisKeysByName(rollingStock.axisNames, rollingStock.axisValues);
  const selected = props.selected || rollingStock.active;
  const textureEntries = sortedNumberKeys(rollingStock.textureNames, rollingStock.surfaceTexts);

  return (
    <>
      <Grid size={{ xs: 12 }}>
        <RollingStockHeadline
          position={props.position}
          rollingStock={rollingStock}
          selected={selected}
          total={props.total}
        />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <RollingStockInfoCard rollingStock={rollingStock} />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <RollingStockTextureCard entries={textureEntries} rollingStock={rollingStock} />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <RollingStockAxisCard
          axisEntries={axisEntries}
          rollingStock={rollingStock}
          onCommit={(axisNumber, value) => {
            socket.emit(CommandEvent.SetRollingStockAxis, {
              rollingStockName: rollingStock.name,
              axisNumber,
              axisName: rollingStock.axisNames?.[String(axisNumber)],
              axisNamesKnown: rollingStock.axisNamesKnown,
              value,
            });
          }}
        />
      </Grid>
    </>
  );
}

function RollingStockHeadline(props: {
  position: number;
  rollingStock: RollingStockAppDto;
  selected: boolean;
  total: number;
}) {
  return (
    <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0, mt: 1 }}>
      <Typography variant="h6" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
        Fahrzeug ({props.position}/{props.total})
        <Box component="span" sx={{ display: { xs: 'none', sm: 'inline' } }}>
          : {props.rollingStock.name}
        </Box>
      </Typography>
      {props.selected && <Chip size="small" color="primary" label="Ausgewählt" />}
    </Stack>
  );
}

function RollingStockInfoCard(props: { rollingStock: RollingStockAppDto }) {
  return (
    <IconHeaderCard title="Fahrzeug Info" icon={<DirectionsRailwayIcon color="primary" />}>
      <List
        dense
        sx={{
          pt: 0,
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        <OverviewMetric icon={<LabelIcon />} label="Name des Fahrzeugs" value={props.rollingStock.name || '-'} />
        <OverviewMetric icon={<AssignmentIcon />} label="Tag-Text" value={props.rollingStock.tag || '-'} />
        <OverviewMetric
          icon={<FileUploadIcon />}
          label="Kranhaken"
          value={formatHookStatus(props.rollingStock.hookStatus)}
        />
        <OverviewMetric
          icon={<CommitIcon />}
          label="Position im Zug"
          value={String(props.rollingStock.positionInTrain + 1)}
        />
        <OverviewMetric
          icon={<ViewInArIcon />}
          label="Modell"
          value={<BreakableModelValue value={formatRollingStockModel(props.rollingStock)} />}
        />
        <OverviewMetric icon={<RouteIcon />} label="Länge" value={formatLength(props.rollingStock.length)} />
        <OverviewMetric icon={<SpeedIcon />} label="Antrieb" value={props.rollingStock.propelled ? 'Ja' : 'Nein'} />
        <OverviewMetric
          icon={<CompareArrowsIcon />}
          label="Ausrichtung"
          value={props.rollingStock.orientationForward ? 'Vorwärts' : 'Rückwärts'}
        />
      </List>
    </IconHeaderCard>
  );
}

function RollingStockAxisCard(props: {
  axisEntries: number[];
  rollingStock: RollingStockAppDto;
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.axisEntries.length === 0) {
    return (
      <IconHeaderCard title="Achsen" icon={<TuneIcon color="primary" />}>
        <Typography variant="body2" color="textSecondary">
          Dieses Fahrzeug hat keine Achsen.
        </Typography>
      </IconHeaderCard>
    );
  }

  return (
    <IconHeaderCard title="Achsen" icon={<TuneIcon color="primary" />}>
      <AxisList
        entries={props.axisEntries.map((axisNumber) => ({
          axisNumber,
          name: props.rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`,
          value: props.rollingStock.axisValues?.[String(axisNumber)] ?? 0,
        }))}
        onCommit={props.onCommit}
      />
    </IconHeaderCard>
  );
}

function RollingStockTextureCard(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
  return (
    <IconHeaderCard title="Aufschriften" icon={<TextFieldsIcon color="primary" />}>
      <TextureList entries={props.entries} rollingStock={props.rollingStock} />
    </IconHeaderCard>
  );
}

function TextureList(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
  if (props.entries.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Dieses Fahrzeug unterstützt keine Aufschriften.
      </Typography>
    );
  }

  return (
    <Box>
      <List
        dense
        disablePadding
        sx={{
          mt: 0,
          '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
        }}
      >
        {props.entries.map((textureNumber) => {
          const textureKey = String(textureNumber);
          const textureName = props.rollingStock.textureNames?.[textureKey] ?? `TextureText ${textureNumber}`;
          const textureContent = props.rollingStock.surfaceTexts?.[textureKey] ?? '';

          return (
            <ListItem key={textureNumber} disablePadding sx={{ display: 'block', pt: 0.25 }}>
              <ListItemText
                primary={<PreservedLineBreaks value={textureContent} />}
                secondary={`${textureNumber} · ${textureName}`}
              />
            </ListItem>
          );
        })}
      </List>
    </Box>
  );
}

function PreservedLineBreaks(props: { value: string }) {
  return (
    <>
      {props.value.split(/\r?\n/).map((line, index) => (
        <span key={index}>
          {index > 0 && <br />}
          {line}
        </span>
      ))}
    </>
  );
}

function groupAxisByName(rollingStock: RollingStockAppDto[]) {
  const groups = new Map<
    string,
    {
      name: string;
      targets: {
        rollingStockName: string;
        axisNumber: number;
        axisName: string;
        axisNamesKnown: boolean;
        value: number;
      }[];
    }
  >();

  rollingStock.forEach((item) => {
    sortedNumberKeys(item.axisNames, item.axisValues).forEach((axisNumber) => {
      const name = item.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`;
      const group = groups.get(name) ?? { name, targets: [] };
      group.targets.push({
        rollingStockName: item.name,
        axisNumber,
        axisName: name,
        axisNamesKnown: item.axisNamesKnown,
        value: item.axisValues?.[String(axisNumber)] ?? 0,
      });
      groups.set(name, group);
    });
  });

  return Array.from(groups.values())
    .map((group) => {
      const values = new Set(group.targets.map((target) => target.value));
      return {
        ...group,
        value: values.size === 1 ? group.targets[0].value : 0,
      };
    })
    .sort((left, right) => left.name.localeCompare(right.name, 'de'));
}

function mergeRollingStockModelInfo(
  staticRollingStock: RollingStockAppDto,
  dynamicRollingStock: RollingStockAppDto | undefined,
): RollingStockAppDto {
  if (!dynamicRollingStock) {
    return staticRollingStock;
  }

  return {
    ...staticRollingStock,
    ...dynamicRollingStock,
    axisNamesKnown: dynamicRollingStock.axisNamesKnown === true || staticRollingStock.axisNamesKnown === true,
    axisNames: nonEmptyRecord(dynamicRollingStock.axisNames)
      ? dynamicRollingStock.axisNames
      : staticRollingStock.axisNames,
    textureNames: nonEmptyRecord(dynamicRollingStock.textureNames)
      ? dynamicRollingStock.textureNames
      : staticRollingStock.textureNames,
    xmlModel: dynamicRollingStock.xmlModel || staticRollingStock.xmlModel,
  };
}

function nonEmptyRecord(record: Record<string, unknown> | undefined): boolean {
  return Object.keys(record ?? {}).length > 0;
}

function sortedNumberKeys(...records: Array<Record<string, unknown> | undefined>): number[] {
  const numbers = new Set<number>();
  records.forEach((record) => {
    Object.keys(record ?? {}).forEach((key) => {
      const numberKey = Number(key);
      if (Number.isFinite(numberKey)) {
        numbers.add(numberKey);
      }
    });
  });

  return Array.from(numbers).sort((left, right) => left - right);
}

function sortedAxisKeysByName(
  axisNames: Record<string, string> | undefined,
  axisValues: Record<string, unknown> | undefined,
): number[] {
  return sortedNumberKeys(axisNames, axisValues).sort((left, right) => {
    const leftName = axisNames?.[String(left)] ?? `Achse ${left}`;
    const rightName = axisNames?.[String(right)] ?? `Achse ${right}`;
    const nameComparison = leftName.localeCompare(rightName, 'de');

    return nameComparison || left - right;
  });
}

function formatHookStatus(value: number): string {
  if (value === 0) {
    return 'Haken deaktiviert';
  }
  if (value === 1) {
    return 'Haken bereit';
  }
  if (value === 3) {
    return 'Ladegut am Haken';
  }
  return `Hakenstatus ${value}`;
}

function formatRollingStockModel(rollingStock: RollingStockAppDto): string {
  return (
    rollingStock.xmlModel ||
    rollingStock.modelTypeText ||
    (rollingStock.modelType ? String(rollingStock.modelType) : '-')
  );
}

function formatLength(value: number): string {
  return value ? `${value} m` : '-';
}

export default SelectedTrainDashboard;
