import { RollingStockAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import Chip from '@mui/material/Chip';
import Grid from '@mui/material/Grid';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import IconHeaderCard from '../../../../shared/components/cards/IconHeaderCard';
import { trainSections } from '../trainSectionPresentation';
import RollingStockAxisPanel from './RollingStockAxisPanel';
import RollingStockInfoPanel from './RollingStockInfoPanel';
import RollingStockTexturePanel from './RollingStockTexturePanel';

export interface RollingStockDashboardCard {
  axisEntries: number[];
  onAxisCommit: (axisNumber: number, value: number) => void;
  position: number;
  rollingStock: RollingStockAppDto;
  selected: boolean;
  textureEntries: number[];
  total: number;
}

function RollingStockDashboardGrid(props: { cards: RollingStockDashboardCard[] }) {
  if (props.cards.length === 0) {
    return (
      <Typography variant="body2" color="textSecondary">
        Keine RollingStocks gefunden.
      </Typography>
    );
  }

  return (
    <>
      {props.cards.map((card) => (
        <RollingStockCards key={card.rollingStock.id} card={card} />
      ))}
    </>
  );
}

function RollingStockCards(props: { card: RollingStockDashboardCard }) {
  const { card } = props;

  return (
    <>
      <Grid size={{ xs: 12 }}>
        <RollingStockHeadline
          position={card.position}
          rollingStock={card.rollingStock}
          selected={card.selected}
          total={card.total}
        />
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <IconHeaderCard title={trainSections.rollingStockInfo.title} icon={trainSections.rollingStockInfo.icon}>
          <RollingStockInfoPanel rollingStock={card.rollingStock} />
        </IconHeaderCard>
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <IconHeaderCard title={trainSections.rollingStockTextures.title} icon={trainSections.rollingStockTextures.icon}>
          <RollingStockTexturePanel entries={card.textureEntries} rollingStock={card.rollingStock} />
        </IconHeaderCard>
      </Grid>
      <Grid size={{ xs: 12, md: 4 }} sx={{ display: 'flex' }}>
        <IconHeaderCard title={trainSections.rollingStockAxes.title} icon={trainSections.rollingStockAxes.icon}>
          <RollingStockAxisPanel
            axisEntries={card.axisEntries}
            rollingStock={card.rollingStock}
            onCommit={card.onAxisCommit}
          />
        </IconHeaderCard>
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

export default RollingStockDashboardGrid;
