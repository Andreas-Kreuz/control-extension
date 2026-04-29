import { CommandEvent, RollingStockAppDto, TrainAppDto } from '@ce/web-shared';
import AltRouteIcon from '@mui/icons-material/AltRoute';
import CommitIcon from '@mui/icons-material/Commit';
import DashboardIcon from '@mui/icons-material/Dashboard';
import DirectionsRailwayIcon from '@mui/icons-material/DirectionsRailway';
import HighlightIcon from '@mui/icons-material/Highlight';
import LinkIcon from '@mui/icons-material/Link';
import RouteIcon from '@mui/icons-material/Route';
import SpeedIcon from '@mui/icons-material/Speed';
import VideocamIcon from '@mui/icons-material/Videocam';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardHeader from '@mui/material/CardHeader';
import Chip from '@mui/material/Chip';
import Divider from '@mui/material/Divider';
import FormControlLabel from '@mui/material/FormControlLabel';
import Grid from '@mui/material/Grid';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Slider from '@mui/material/Slider';
import Stack from '@mui/material/Stack';
import Switch from '@mui/material/Switch';
import Typography from '@mui/material/Typography';
import { ReactNode, useEffect, useMemo, useState } from 'react';
import AppCardGridContainer from '../../../shared/layouts/AppCardGridContainer';
import AppPage from '../../../shared/layouts/AppPage';
import AppPageHeadline from '../../../shared/layouts/AppPageHeadline';
import { useSocket } from '../../../app/hooks/useSocket';
import TrainCamList from '../../trains/components/TrainCamList';
import TrainLineInformationView from '../../trains/components/TrainLineInformationView';
import useRollingStock from '../../trains/hooks/useRollingStock';
import useRollingStockDynamic from '../../trains/hooks/useRollingStockDynamic';
import useTrainDynamic from '../../trains/hooks/useTrainDynamic';
import useTrainRollingStock from '../../trains/hooks/useTrainRollingStock';
import useTransitTrain from '../../trains/hooks/useTransitTrain';
import useTransitSettings from '../../lines/hooks/useTransitSettings';
import useSelectedScenario from '../hooks/useSelectedScenario';
import useSetTrainCoupling from '../hooks/useSetTrainCoupling';
import useSetTrainLight from '../hooks/useSetTrainLight';
import useSetTrainSpeed from '../hooks/useSetTrainSpeed';

const trainLightSources = [
  { source: 0, label: 'Fahrlicht', description: 'Innenraum' },
  { source: 1, label: 'Blinker links', description: 'Links' },
  { source: 2, label: 'Blinker rechts', description: 'Rechts' },
  { source: 3, label: 'Bremslicht-Automatik', description: 'Auto' },
];

const optimisticSwitchTimeoutMs = 5000;

function SelectedTrainDashboard() {
  const scenario = useSelectedScenario();
  const activeRollingStock = useRollingStock(scenario?.activeRollingStock ?? '');
  const trainId = activeRollingStock?.trainName || scenario?.activeTrain || '';
  const train = useTrainDynamic(trainId);
  const rollingStock = useTrainRollingStock(trainId);
  const transitTrain = useTransitTrain(trainId);
  const transitSettings = useTransitSettings();
  const selectedRollingStockName = scenario?.activeRollingStock ?? '';
  const cameraRollingStockName = rollingStock?.[0]?.name ?? activeRollingStock?.name ?? train?.name ?? trainId;

  if (!scenario?.activeRollingStock && !scenario?.activeTrain) {
    return (
      <AppPage>
        <AppPageHeadline>Aktiver Zug</AppPageHeadline>
        <EmptyDashboardState />
      </AppPage>
    );
  }

  if (!train) {
    return (
      <AppPage>
        <AppPageHeadline>Aktiver Zug</AppPageHeadline>
        <Card>
          <CardContent>
            <Typography color="text.secondary">Zugdaten werden geladen.</Typography>
          </CardContent>
        </Card>
      </AppPage>
    );
  }

  return (
    <AppPage>
      <AppPageHeadline>Aktiver Zug</AppPageHeadline>
      <AppCardGridContainer>
        <Grid size={{ xs: 12, xl: 8 }}>
          <TrainStatusCard train={train} selectedRollingStockName={selectedRollingStockName} />
        </Grid>
        <Grid size={{ xs: 12, md: 6, xl: 4 }}>
          <CameraCard trainName={train.name} rollingStockName={cameraRollingStockName} />
        </Grid>
        <Grid size={{ xs: 12, md: transitSettings ? 6 : 12, xl: transitSettings ? 4 : 12 }}>
          <RouteCard train={train} showTransit={Boolean(transitSettings)} transitLine={transitTrain?.line} />
        </Grid>
        {transitSettings && (
          <Grid size={{ xs: 12, xl: 8 }}>
            <Card>
              <CardHeader avatar={<AltRouteIcon color="primary" />} title="Nächste Stationen" />
              <Divider />
              <TrainLineInformationView
                line={transitTrain?.line ?? train.line ?? '-'}
                destination={transitTrain?.destination ?? train.destination ?? '-'}
                nextStations={transitTrain?.nextStations ?? train.nextStations ?? []}
              />
            </Card>
          </Grid>
        )}
        <Grid size={{ xs: 12 }}>
          <MergedAxisCard rollingStock={rollingStock ?? []} />
        </Grid>
        <Grid size={{ xs: 12 }}>
          <RollingStockGrid rollingStock={rollingStock ?? []} selectedRollingStockName={selectedRollingStockName} />
        </Grid>
      </AppCardGridContainer>
    </AppPage>
  );
}

function EmptyDashboardState() {
  return (
    <Card>
      <CardContent>
        <Stack spacing={1}>
          <Typography variant="h6">Kein Zug in EEP ausgewählt</Typography>
          <Typography color="text.secondary">
            Wähle in EEP einen RollingStock oder Zug aus, dann folgt dieses Dashboard automatisch.
          </Typography>
        </Stack>
      </CardContent>
    </Card>
  );
}

function TrainStatusCard(props: { train: TrainAppDto; selectedRollingStockName: string }) {
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
    <Card sx={{ height: 1 }}>
      <CardHeader
        avatar={<DirectionsRailwayIcon color="primary" />}
        title={train.name}
        subheader={props.selectedRollingStockName ? `RollingStock: ${props.selectedRollingStockName}` : train.route}
      />
      <Divider />
      <CardContent>
        <Box
          sx={{
            display: 'grid',
            gridTemplateColumns: { xs: '1fr', md: 'minmax(220px, 1fr) minmax(280px, 2fr)' },
            gap: 3,
          }}
        >
          <Stack spacing={1.5}>
            <Metric icon={<SpeedIcon />} label="Ist-Geschwindigkeit" value={`${train.speed} km/h`} />
            <Metric icon={<SpeedIcon />} label="Zielgeschwindigkeit" value={`${train.targetSpeed} km/h`} />
            <Metric icon={<LinkIcon />} label="Kupplung vorne" value={formatCoupling(couplingFront)} />
            <Metric icon={<LinkIcon />} label="Kupplung hinten" value={formatCoupling(couplingRear)} />
          </Stack>
          <Stack spacing={3}>
            <SpeedSlider value={train.targetSpeed} onCommit={(value) => setSpeed(train.name, value)} />
            <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1}>
              <FormControlLabel
                control={
                  <Switch
                    checked={couplingFront === 1}
                    disabled={couplingFront === 0}
                    onChange={(event) => {
                      const value = event.target.checked ? 1 : 2;
                      setCouplingFront(value);
                      setOptimisticState((previous) => ({
                        ...previous,
                        trainName: train.name,
                        couplingFront: { value, changedAt: Date.now() },
                      }));
                      setCoupling(train.name, 'front', event.target.checked);
                    }}
                  />
                }
                label="Kupplung vorne"
              />
              <FormControlLabel
                control={
                  <Switch
                    checked={couplingRear === 1}
                    disabled={couplingRear === 0}
                    onChange={(event) => {
                      const value = event.target.checked ? 1 : 2;
                      setCouplingRear(value);
                      setOptimisticState((previous) => ({
                        ...previous,
                        trainName: train.name,
                        couplingRear: { value, changedAt: Date.now() },
                      }));
                      setCoupling(train.name, 'rear', event.target.checked);
                    }}
                  />
                }
                label="Kupplung hinten"
              />
            </Stack>
            <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr' }, gap: 1 }}>
              {trainLightSources.map((entry) => (
                <FormControlLabel
                  key={entry.source}
                  control={
                    <Switch
                      checked={lights?.[String(entry.source)] === true}
                      onChange={(event) => {
                        const source = String(entry.source);
                        const { checked } = event.target;
                        setLights((previous) => ({
                          ...previous,
                          [source]: checked,
                        }));
                        setOptimisticState((previous) => ({
                          ...previous,
                          trainName: train.name,
                          lights: {
                            ...previous.lights,
                            [source]: { value: checked, changedAt: Date.now() },
                          },
                        }));
                        setLight(train.name, entry.source, checked);
                      }}
                    />
                  }
                  label={
                    <Box>
                      <Typography variant="body2">{entry.label}</Typography>
                      <Typography variant="caption" color="text.secondary">
                        {entry.description}
                      </Typography>
                    </Box>
                  }
                />
              ))}
            </Box>
          </Stack>
        </Box>
      </CardContent>
    </Card>
  );
}

function SpeedSlider(props: { value: number; onCommit: (value: number) => void }) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <Box>
      <Typography variant="subtitle2" gutterBottom>
        Zielgeschwindigkeit
      </Typography>
      <Slider
        min={-250}
        max={250}
        step={1}
        marks={[{ value: 0, label: '0' }]}
        value={value}
        valueLabelDisplay="auto"
        onChange={(_, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
        onChangeCommitted={(_, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
      />
    </Box>
  );
}

function Metric(props: { icon: ReactNode; label: string; value: string }) {
  return (
    <Box sx={{ display: 'grid', gridTemplateColumns: '2rem minmax(0, 1fr)', gap: 1, alignItems: 'center' }}>
      <Box sx={{ color: 'text.secondary', display: 'flex' }}>{props.icon}</Box>
      <Box sx={{ minWidth: 0 }}>
        <Typography variant="caption" color="text.secondary">
          {props.label}
        </Typography>
        <Typography variant="body1" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.value}
        </Typography>
      </Box>
    </Box>
  );
}

function CameraCard(props: { trainName: string; rollingStockName: string }) {
  return (
    <Card sx={{ height: 1 }}>
      <CardHeader avatar={<VideocamIcon color="primary" />} title="Kameras" />
      <Divider />
      <TrainCamList trainName={props.trainName} rollingStockName={props.rollingStockName} />
    </Card>
  );
}

function RouteCard(props: { train: TrainAppDto; showTransit: boolean; transitLine?: string }) {
  return (
    <Card sx={{ height: 1 }}>
      <CardHeader avatar={<RouteIcon color="primary" />} title="Route" />
      <Divider />
      <CardContent>
        <Stack spacing={1.5}>
          <Metric icon={<RouteIcon />} label="EEP-Route" value={props.train.route || '-'} />
          {props.showTransit && (
            <Metric icon={<AltRouteIcon />} label="Linie" value={props.transitLine ?? props.train.line ?? '-'} />
          )}
          {props.showTransit && <Metric icon={<DashboardIcon />} label="Ziel" value={props.train.destination ?? '-'} />}
        </Stack>
      </CardContent>
    </Card>
  );
}

function MergedAxisCard(props: { rollingStock: RollingStockAppDto[] }) {
  const socket = useSocket();
  const groups = useMemo(() => groupAxisByName(props.rollingStock), [props.rollingStock]);

  return (
    <Card>
      <CardHeader avatar={<CommitIcon color="primary" />} title="Achsen im Zugverband" />
      <Divider />
      <CardContent>
        {groups.length === 0 ? (
          <Typography color="text.secondary">Keine Achsen im ausgewählten Zug gefunden.</Typography>
        ) : (
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', lg: '1fr 1fr' }, gap: 2 }}>
            {groups.map((group) => (
              <AxisSlider
                key={group.name}
                name={group.name}
                axisNumbers={uniqueAxisNumbers(group.targets)}
                value={group.value}
                mixed={group.mixed}
                detail={`${group.targets.length} RollingStock`}
                onCommit={(value) => {
                  group.targets.forEach((target) => {
                    socket.emit(CommandEvent.SetRollingStockAxis, {
                      rollingStockName: target.rollingStockName,
                      axisNumber: target.axisNumber,
                      value,
                    });
                  });
                }}
              />
            ))}
          </Box>
        )}
      </CardContent>
    </Card>
  );
}

function RollingStockGrid(props: { rollingStock: RollingStockAppDto[]; selectedRollingStockName: string }) {
  return (
    <Card>
      <CardHeader avatar={<HighlightIcon color="primary" />} title="RollingStock" />
      <Divider />
      <CardContent>
        {props.rollingStock.length === 0 ? (
          <Typography color="text.secondary">Keine RollingStocks gefunden.</Typography>
        ) : (
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', lg: '1fr 1fr' }, gap: 2 }}>
            {props.rollingStock.map((item) => (
              <RollingStockCard
                key={item.id}
                rollingStock={item}
                selected={props.selectedRollingStockName === item.id || props.selectedRollingStockName === item.name}
              />
            ))}
          </Box>
        )}
      </CardContent>
    </Card>
  );
}

function RollingStockCard(props: { rollingStock: RollingStockAppDto; selected: boolean }) {
  const dynamicRollingStock = useRollingStockDynamic(props.rollingStock.id);
  const rollingStock = mergeRollingStockModelInfo(props.rollingStock, dynamicRollingStock);
  const socket = useSocket();
  const axisEntries = sortedNumberKeys(rollingStock.axisNames, rollingStock.axisValues);
  const textureEntries = sortedNumberKeys(rollingStock.textureNames, rollingStock.surfaceTexts);
  const selected = props.selected || rollingStock.active;

  return (
    <Card variant="outlined" sx={{ outline: selected ? '2px solid' : 0, outlineColor: 'primary.main' }}>
      <CardHeader
        title={rollingStock.name}
        subheader={rollingStock.xmlModel || rollingStock.modelTypeText || undefined}
        action={selected ? <Chip size="small" color="primary" label="Ausgewählt" /> : undefined}
      />
      <Divider />
      <CardContent>
        <Stack spacing={2}>
          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr' }, gap: 1 }}>
            <Metric icon={<DashboardIcon />} label="Tag" value={rollingStock.tag || '-'} />
            <Metric icon={<LinkIcon />} label="Hakenstatus" value={formatHookStatus(rollingStock.hookStatus)} />
          </Box>
          <AxisList
            axisEntries={axisEntries}
            rollingStock={rollingStock}
            onCommit={(axisNumber, value) => {
              socket.emit(CommandEvent.SetRollingStockAxis, {
                rollingStockName: rollingStock.name,
                axisNumber,
                value,
              });
            }}
          />
          <TextureList entries={textureEntries} rollingStock={rollingStock} />
        </Stack>
      </CardContent>
    </Card>
  );
}

function AxisList(props: {
  axisEntries: number[];
  rollingStock: RollingStockAppDto;
  onCommit: (axisNumber: number, value: number) => void;
}) {
  if (props.axisEntries.length === 0) {
    return <Typography color="text.secondary">Keine Achsen.</Typography>;
  }

  return (
    <Stack spacing={1}>
      <Typography variant="subtitle2">Achsen</Typography>
      {props.axisEntries.map((axisNumber) => (
        <AxisSlider
          key={axisNumber}
          name={props.rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`}
          axisNumbers={[axisNumber]}
          value={props.rollingStock.axisValues?.[String(axisNumber)] ?? 0}
          onCommit={(value) => props.onCommit(axisNumber, value)}
        />
      ))}
    </Stack>
  );
}

function AxisSlider(props: {
  name: string;
  axisNumbers?: number[];
  value: number;
  mixed?: boolean;
  detail?: string;
  onCommit: (value: number) => void;
}) {
  const [value, setValue] = useState(props.value);

  useEffect(() => {
    setValue(props.value);
  }, [props.value]);

  return (
    <Box
      sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'minmax(120px, 1fr) minmax(180px, 2fr)' }, gap: 1 }}
    >
      <Box sx={{ minWidth: 0 }}>
        <Typography variant="body2" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {props.name}
        </Typography>
        {(props.axisNumbers?.length || props.mixed || props.detail) && (
          <Typography variant="caption" color="text.secondary">
            {[formatAxisNumbers(props.axisNumbers), props.mixed ? 'gemischt' : props.detail].filter(Boolean).join(' · ')}
          </Typography>
        )}
      </Box>
      <Slider
        min={0}
        max={100}
        value={value}
        valueLabelDisplay="auto"
        onChange={(_, nextValue) => setValue(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
        onChangeCommitted={(_, nextValue) => props.onCommit(Array.isArray(nextValue) ? nextValue[0] : nextValue)}
      />
    </Box>
  );
}

function TextureList(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
  if (props.entries.length === 0) {
    return <Typography color="text.secondary">Keine Texturen.</Typography>;
  }

  return (
    <Box>
      <Typography variant="subtitle2" gutterBottom>
        Texturen
      </Typography>
      <List dense disablePadding>
        {props.entries.map((textureNumber) => (
          <ListItem
            key={textureNumber}
            disablePadding
            sx={{ display: 'grid', gridTemplateColumns: '4ch 1fr 1fr', gap: 1 }}
          >
            <Typography variant="body2" color="text.secondary">
              {textureNumber}
            </Typography>
            <Typography variant="body2" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {props.rollingStock.textureNames?.[String(textureNumber)] ?? `TextureText ${textureNumber}`}
            </Typography>
            <Typography variant="body2" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {props.rollingStock.surfaceTexts?.[String(textureNumber)] ?? ''}
            </Typography>
          </ListItem>
        ))}
      </List>
    </Box>
  );
}

function groupAxisByName(rollingStock: RollingStockAppDto[]) {
  const groups = new Map<
    string,
    { name: string; targets: { rollingStockName: string; axisNumber: number; value: number }[] }
  >();

  rollingStock.forEach((item) => {
    sortedNumberKeys(item.axisNames, item.axisValues).forEach((axisNumber) => {
      const name = item.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`;
      const group = groups.get(name) ?? { name, targets: [] };
      group.targets.push({
        rollingStockName: item.name,
        axisNumber,
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
        mixed: values.size > 1,
      };
    })
    .sort((left, right) => left.name.localeCompare(right.name, 'de'));
}

function uniqueAxisNumbers(targets: { axisNumber: number }[]): number[] {
  return Array.from(new Set(targets.map((target) => target.axisNumber))).sort((left, right) => left - right);
}

function formatAxisNumbers(axisNumbers: number[] | undefined): string | undefined {
  if (!axisNumbers?.length) {
    return undefined;
  }
  return axisNumbers.length === 1 ? `Achse ${axisNumbers[0]}` : `Achsen ${axisNumbers.join(', ')}`;
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

function formatCoupling(value: number): string {
  if (value === 1) {
    return 'Kupplung scharf';
  }
  if (value === 2) {
    return 'Abstoßen';
  }
  return 'Unbekannt';
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

export default SelectedTrainDashboard;
