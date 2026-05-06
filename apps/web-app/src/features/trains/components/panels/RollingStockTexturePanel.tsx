import { RollingStockAppDto } from '@ce/web-shared';
import Box from '@mui/material/Box';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Typography from '@mui/material/Typography';
import PreservedLineBreaks from './PreservedLineBreaks';

function RollingStockTexturePanel(props: { entries: number[]; rollingStock: RollingStockAppDto }) {
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

export default RollingStockTexturePanel;
