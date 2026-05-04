import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import OutlinedCard from '../../../shared/components/cards/OutlinedCard';

const controlExtensionSetupSnippet = `-- Laden der Control Extension
local ControlExtension = require("ce.ControlExtension")

-- Optional: Lade weitere Module fuer Verkehr und ÖPNV
ControlExtension.addModules(
    require("ce.mods.road.CeRoadModule"),
    require("ce.mods.transit.CeTransitModule")
)

-- Wichtig: ControlExtension.runTasks() muss in EEPMain() aufgerufen werden
function EEPMain()
    ControlExtension.runTasks(5)
    return 1
end`;

function ControlExtensionSetupCard() {
  return (
    <OutlinedCard
      title="Control Extension einbinden"
      description="Binde den Control Extension Code in das Lua-Skript Deiner EEP-Anlage ein"
      sx={{ bgcolor: 'background.paper' }}
    >
      <Stack spacing={1.5}>
        <List component="ol" sx={{ listStyleType: 'decimal', pl: 3, py: 0 }}>
          <ListItem sx={{ display: 'list-item', py: 0.5 }}>
            <Typography variant="body1">Öffne EEP und lade deine Anlage.</Typography>
          </ListItem>
          <ListItem sx={{ display: 'list-item', py: 0.5 }}>
            <Typography variant="body1">Öffne den Lua Editor.</Typography>
          </ListItem>
          <ListItem sx={{ display: 'list-item', py: 0.5 }}>
            <Typography variant="body1">
              Passe die vorhandene <code>EEPMain()</code> im Skript wie unten an und stelle sicher, dass
              ControlExtension.runTasks() aufgerufen wird.
            </Typography>
          </ListItem>
          <ListItem sx={{ display: 'list-item', py: 0.5 }}>
            <Typography variant="body1">Klick auf Lua-Skript neu laden.</Typography>
          </ListItem>
        </List>
        <Box
          component="pre"
          sx={{
            bgcolor: 'action.hover',
            borderRadius: 1,
            fontFamily: 'monospace',
            fontSize: '0.875rem',
            m: 0,
            overflowX: 'auto',
            p: 2,
            whiteSpace: 'pre',
          }}
        >
          <code>{controlExtensionSetupSnippet}</code>
        </Box>
      </Stack>
    </OutlinedCard>
  );
}

export default ControlExtensionSetupCard;
