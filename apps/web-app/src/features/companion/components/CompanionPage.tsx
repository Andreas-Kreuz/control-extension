import { RollingStockAppDto, TrainNextStationAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Divider from '@mui/material/Divider';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Stack from '@mui/material/Stack';
import Tab from '@mui/material/Tab';
import Tabs from '@mui/material/Tabs';
import Typography from '@mui/material/Typography';
import { useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import LineAvatar from '../../../shared/components/lines/LineAvatar';
import type { LineTrafficType } from '../../../shared/components/lines/LineAvatar';
import PreservedLineBreaks from '../../trains/components/panels/PreservedLineBreaks';
import { sortedAxisKeysByName, sortedNumberKeys } from '../../trains/lib/trainDashboard';
import type { MergedAxisGroup } from '../../trains/lib/trainDashboard';
import type { TrainDashboardPanelModel } from '../../trains/lib/trainDashboardPanelModel';
import CompactAxisList from './CompactAxisList';

const rightPanelWidth = 300;
const bottomPanelHeight = 200;

function CompanionPage(props: {
  dashboard: TrainDashboardPanelModel;
  onRollingStockAxisCommit?: (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => void;
  transitTrafficType?: LineTrafficType;
}) {
  return (
    <Box
      sx={{
        bgcolor: 'background.default',
        display: 'grid',
        gridTemplateColumns: `minmax(0, 1fr) ${rightPanelWidth}px`,
        gridTemplateRows: `minmax(0, 1fr) ${bottomPanelHeight}px`,
        height: '100vh',
        overflow: 'hidden',
        width: '100vw',
      }}
    >
      <CompanionHero />
      <CompanionSidePanel
        dashboard={props.dashboard}
        onRollingStockAxisCommit={props.onRollingStockAxisCommit}
        transitTrafficType={props.transitTrafficType}
      />
      <CompanionBottomPanel />
    </Box>
  );
}

function CompanionHero() {
  return (
    <Box
      sx={{
        alignItems: 'center',
        bgcolor: 'grey.300',
        color: 'text.secondary',
        display: 'flex',
        flexDirection: 'column',
        gap: 2,
        gridColumn: '1',
        gridRow: '1',
        justifyContent: 'center',
        minHeight: 0,
        minWidth: 0,
        p: 3,
      }}
    >
      <Typography variant="h4" component="h1" sx={{ textAlign: 'center' }}>
        Platziere dein EEP-Fenster hier
      </Typography>
      <Button component={RouterLink} to="/" variant="contained">
        Zurück zur Web-App
      </Button>
    </Box>
  );
}

function CompanionSidePanel(props: {
  dashboard: TrainDashboardPanelModel;
  onRollingStockAxisCommit?: (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => void;
  transitTrafficType?: LineTrafficType;
}) {
  const [activeTab, setActiveTab] = useState(0);
  const tabs = [
    { key: 'transit', label: 'ÖPNV' },
    { key: 'axes', label: 'Achsen' },
    { key: 'textures', label: 'Aufschriften' },
  ];
  const activeKey = tabs[activeTab]?.key ?? tabs[0].key;

  return (
    <Box
      component="aside"
      sx={{
        bgcolor: 'background.paper',
        borderLeft: '1px solid',
        borderColor: 'divider',
        display: 'flex',
        flexDirection: 'column',
        gridColumn: '2',
        gridRow: '1 / span 2',
        minHeight: 0,
        minWidth: 0,
        overflowX: 'hidden',
      }}
    >
      <Tabs
        value={activeTab}
        onChange={(_event, value: number) => setActiveTab(value)}
        variant="scrollable"
        allowScrollButtonsMobile
        sx={{
          maxWidth: 1,
          minHeight: 44,
          '& .MuiTab-root': {
            minHeight: 44,
            minWidth: 'auto',
            px: 1.25,
          },
        }}
      >
        {tabs.map((tab) => (
          <Tab key={tab.key} label={tab.label} />
        ))}
      </Tabs>
      <Divider />
      <Box sx={{ flex: 1, minHeight: 0, overflowY: 'auto', overflowX: 'hidden', p: 2 }}>
        {activeKey === 'transit' && (
          <TransitPanel dashboard={props.dashboard} transitTrafficType={props.transitTrafficType} />
        )}
        {activeKey === 'axes' && (
          <AxesPanel
            dashboard={props.dashboard}
            onRollingStockAxisCommit={props.onRollingStockAxisCommit}
          />
        )}
        {activeKey === 'textures' && <TexturesPanel dashboard={props.dashboard} />}
      </Box>
    </Box>
  );
}

function TransitPanel(props: { dashboard: TrainDashboardPanelModel; transitTrafficType?: LineTrafficType }) {
  if (props.dashboard.status !== 'ready') {
    return <DashboardStatus dashboard={props.dashboard} />;
  }

  const line = props.dashboard.transit?.line ?? props.dashboard.train.line ?? '';
  const destination = props.dashboard.transit?.destination ?? props.dashboard.train.destination ?? '';
  const nextStations = props.dashboard.transit?.nextStations ?? props.dashboard.train.nextStations ?? [];
  const hasLine = line.trim().length > 0 && line.trim() !== '-';

  if (!hasLine) {
    return (
      <Typography variant="body2" color="textSecondary">
        Für den aktuell ausgewählten Zug ist keine Linie ausgewählt.
      </Typography>
    );
  }

  if (!props.transitTrafficType) {
    return (
      <Typography variant="body2" color="textSecondary">
        Linientyp wird geladen.
      </Typography>
    );
  }

  return (
    <Stack spacing={1.5}>
      <Stack direction="row" spacing={1} sx={{ alignItems: 'center', minWidth: 0 }}>
        <LineAvatar trafficType={props.transitTrafficType} sx={{ flexShrink: 0 }} />
        <Box sx={{ minWidth: 0 }}>
          <Typography variant="h6" sx={{ lineHeight: 1.1, overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {line}
          </Typography>
          <Typography variant="body2" color="textSecondary" sx={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {destination || '-'}
          </Typography>
        </Box>
      </Stack>
      <Divider />
      <CompactNextStations nextStations={nextStations} />
    </Stack>
  );
}

function AxesPanel(props: {
  dashboard: TrainDashboardPanelModel;
  onRollingStockAxisCommit?: (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => void;
}) {
  if (props.dashboard.status !== 'ready') {
    return <DashboardStatus dashboard={props.dashboard} />;
  }

  return (
    <Stack spacing={2}>
      <Typography variant="subtitle2">Train</Typography>
      <Box>
        <Typography variant="caption" color="textSecondary" sx={{ display: 'block', mb: 0.5 }}>
          Train Axises
        </Typography>
        <CompactTrainAxisPanel
          canShowTrainAxes={props.dashboard.canShowTrainAxes}
          groups={props.dashboard.mergedAxisGroups}
          rollingStockCount={props.dashboard.rollingStock.length}
          onCommit={props.dashboard.onMergedAxisCommit}
        />
      </Box>
      {props.dashboard.rollingStock.length > 1 &&
        props.dashboard.rollingStock.map((rollingStock, index) => (
          <Box key={rollingStock.id}>
            <Typography variant="subtitle2" sx={{ mb: 0.5 }}>
              RollingStock {index + 1} ({rollingStock.name})
            </Typography>
            <CompactRollingStockAxisList
              rollingStock={rollingStock}
              onCommit={props.onRollingStockAxisCommit ?? (() => undefined)}
            />
          </Box>
        ))}
    </Stack>
  );
}

function TexturesPanel(props: { dashboard: TrainDashboardPanelModel }) {
  if (props.dashboard.status !== 'ready') {
    return <DashboardStatus dashboard={props.dashboard} />;
  }

  if (props.dashboard.rollingStock.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Keine RollingStocks gefunden.
      </Typography>
    );
  }

  return (
    <Stack spacing={1}>
      {props.dashboard.rollingStock.map((rollingStock) => (
        <Box key={rollingStock.id}>
          <Typography variant="subtitle2" sx={{ mb: 0.25 }}>
            {rollingStock.name}
          </Typography>
          <CompactTextureList
            entries={sortedNumberKeys(rollingStock.textureNames, rollingStock.surfaceTexts)}
            rollingStock={rollingStock}
          />
        </Box>
      ))}
    </Stack>
  );
}

function CompactTrainAxisPanel(props: {
  canShowTrainAxes: boolean;
  groups: MergedAxisGroup[];
  rollingStockCount: number;
  onCommit: (group: MergedAxisGroup, value: number) => void;
}) {
  if (!props.canShowTrainAxes && props.rollingStockCount > 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Achsen im Zug sind erst verfügbar, wenn Achsnamen für alle RollingStocks bekannt sind.
      </Typography>
    );
  }

  return (
    <CompactAxisList
      entries={props.groups.map((group, index) => ({
        axisNumber: index,
        name: group.name,
        value: group.value,
        trailingLabel: `${group.targets.length}x`,
      }))}
      emptyMessage="Kein Fahrzeug in diesem Zug hat Achsen."
      onCommit={(index, value) => {
        const group = props.groups[index];
        if (group) {
          props.onCommit(group, value);
        }
      }}
    />
  );
}

function CompactRollingStockAxisList(props: {
  rollingStock: RollingStockAppDto;
  onCommit: (rollingStock: RollingStockAppDto, axisNumber: number, value: number) => void;
}) {
  return (
    <CompactAxisList
      entries={sortedAxisKeysByName(props.rollingStock.axisNames, props.rollingStock.axisValues).map((axisNumber) => ({
        axisNumber,
        name: props.rollingStock.axisNames?.[String(axisNumber)] ?? `Achse ${axisNumber}`,
        value: props.rollingStock.axisValues?.[String(axisNumber)] ?? 0,
        trailingLabel: `#${axisNumber}`,
      }))}
      emptyMessage="Dieses Fahrzeug hat keine Achsen."
      onCommit={(axisNumber, value) => props.onCommit(props.rollingStock, axisNumber, value)}
    />
  );
}

function CompactTextureList(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
  if (props.entries.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Dieses Fahrzeug unterstützt keine Aufschriften.
      </Typography>
    );
  }

  return (
    <List dense disablePadding>
      {props.entries.map((textureNumber) => {
        const textureKey = String(textureNumber);
        const textureName = props.rollingStock.textureNames?.[textureKey] ?? `TextureText ${textureNumber}`;
        const textureContent = props.rollingStock.surfaceTexts?.[textureKey] ?? '';

        return (
          <ListItem key={textureNumber} disablePadding sx={{ py: 0 }}>
            <ListItemText
              primary={<PreservedLineBreaks value={textureContent} />}
              secondary={`${textureNumber} · ${textureName}`}
              slotProps={{
                primary: { variant: 'body2' },
                secondary: { variant: 'caption' },
              }}
              sx={{ my: 0.125 }}
            />
          </ListItem>
        );
      })}
    </List>
  );
}

function CompactNextStations(props: { nextStations: TrainNextStationAppDto[] }) {
  if (props.nextStations.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Keine nächsten Stationen vorhanden.
      </Typography>
    );
  }

  return (
    <Stack spacing={0.75}>
      {props.nextStations.map((entry, index) => (
        <Box
          key={`${entry.station.name}-${entry.station.platform}-${index}`}
          sx={{
            columnGap: 1,
            display: 'grid',
            gridTemplateColumns: 'minmax(0, 1fr) auto',
            minWidth: 0,
          }}
        >
          <Typography variant="body2" sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {entry.station.name}
          </Typography>
          <Typography variant="caption" color="textSecondary">
            {entry.departureInMinutes <= 0 ? '0 min' : `${entry.departureInMinutes} min`}
          </Typography>
          <Typography
            variant="caption"
            color="textSecondary"
            sx={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis' }}
          >
            Steig {entry.station.platform}
          </Typography>
        </Box>
      ))}
    </Stack>
  );
}

function DashboardStatus(props: { dashboard: TrainDashboardPanelModel }) {
  if (props.dashboard.status === 'loading') {
    return (
      <Typography variant="body2" color="textSecondary">
        Zugdaten werden geladen.
      </Typography>
    );
  }

  return (
    <Typography variant="body2" color="textSecondary">
      Wähle in EEP einen RollingStock oder Zug aus, dann folgt diese Ansicht automatisch.
    </Typography>
  );
}

function CompanionBottomPanel() {
  return (
    <Box
      component="section"
      sx={{
        alignItems: 'center',
        bgcolor: 'grey.200',
        borderTop: '1px solid',
        borderColor: 'divider',
        color: 'text.secondary',
        display: 'flex',
        gridColumn: '1',
        gridRow: '2',
        justifyContent: 'center',
        minHeight: 0,
        minWidth: 0,
        p: 2,
      }}
    >
      <Typography variant="body2">Platzhalter</Typography>
    </Box>
  );
}

export default CompanionPage;
