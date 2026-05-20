import Box from '@mui/material/Box';

export type DirectionTrafficLightItem = {
  signSrc: string;
  signAlt: string;
  trafficLightSrc?: string;
  trafficLightAlt?: string;
};

export type DirectionTrafficLightProps = {
  items: DirectionTrafficLightItem[];
};

function DirectionTrafficLight(props: DirectionTrafficLightProps) {
  return (
    <Box
      sx={{
        display: 'grid',
        gridAutoColumns: 64,
        gridAutoFlow: 'column',
        columnGap: 0.75,
        justifyContent: 'center',
        width: 'fit-content',
      }}
    >
      {props.items.map((item) => (
        <Box
          key={`${item.signSrc}-${item.trafficLightSrc}`}
          sx={{
            display: 'grid',
            gridTemplateRows: '32px 64px',
            justifyItems: 'center',
            rowGap: 0.5,
            width: 64,
          }}
        >
          <Box
            component="img"
            src={item.signSrc}
            alt={item.signAlt}
            sx={{ display: 'block', width: 32, height: 32, objectFit: 'contain' }}
          />
          {item.trafficLightSrc === undefined ? null : (
            <Box
              component="img"
              src={item.trafficLightSrc}
              alt={item.trafficLightAlt ?? ''}
              sx={{ display: 'block', width: 64, height: 64, objectFit: 'contain' }}
            />
          )}
        </Box>
      ))}
    </Box>
  );
}

export default DirectionTrafficLight;
