import Box from '@mui/material/Box';
import type {
  IntersectionWizardSignalGroupAppDto,
  IntersectionWizardTrafficType,
  IntersectionWizardTurnDirection,
} from '@ce/web-shared';

type SignalGroupTrafficLightPreviewProps = Pick<
  IntersectionWizardSignalGroupAppDto,
  'turnDirections' | 'trafficType'
> & {
  align?: 'left' | 'center' | 'right';
  size?: 'default' | 'small';
};

type DisplayDirection = 'LEFT' | 'STRAIGHT' | 'RIGHT';

type SignalGroupDisplayItem = {
  key: string;
  signSrc?: string;
  signAlt?: string;
  trafficLightSrc: string;
  trafficLightAlt: string;
  trafficLightWidth: number;
  trafficLightHeight: number;
};

const displayDirections: DisplayDirection[] = ['LEFT', 'STRAIGHT', 'RIGHT'];
const signalWidth = 32;
const trafficLightWidth = 32;
const signalColumnGap = 1;
const signOverlap = 2;
const maxSignalGroupWidth = signalWidth * 3;
const maxSignalGroupGaps = 2;
const sizeScale = {
  default: 1,
  small: 2 / 3,
} satisfies Record<NonNullable<SignalGroupTrafficLightPreviewProps['size']>, number>;

const signByDirection = {
  LEFT: '/assets/sign-left.svg',
  STRAIGHT: '/assets/sign-straight.svg',
  RIGHT: '/assets/sign-right.svg',
} satisfies Record<DisplayDirection, string>;

const tramTrafficLightByDirection = {
  LEFT: '/assets/traffic-lights/tl-tram-f3-left-all.png',
  STRAIGHT: '/assets/traffic-lights/tl-tram-1-straight-all.png',
  RIGHT: '/assets/traffic-lights/tl-tram-f2-right-all.png',
} satisfies Record<DisplayDirection, string>;

const directionLabelByDirection = {
  LEFT: 'Links',
  STRAIGHT: 'Geradeaus',
  RIGHT: 'Rechts',
} satisfies Record<DisplayDirection, string>;

const justifyContentByAlign = {
  left: 'flex-start',
  center: 'center',
  right: 'flex-end',
} satisfies Record<NonNullable<SignalGroupTrafficLightPreviewProps['align']>, string>;

function displayDirectionFor(turnDirection: IntersectionWizardTurnDirection): DisplayDirection {
  if (turnDirection === 'LEFT' || turnDirection === 'HALF_LEFT') return 'LEFT';
  if (turnDirection === 'RIGHT' || turnDirection === 'HALF_RIGHT') return 'RIGHT';
  return 'STRAIGHT';
}

function normalizedDisplayDirections(turnDirections: IntersectionWizardTurnDirection[]) {
  const selectedDirections = new Set(turnDirections.map(displayDirectionFor));
  return displayDirections.filter((direction) => selectedDirections.has(direction));
}

function signalGroupDisplayItems(
  trafficType: IntersectionWizardTrafficType,
  turnDirections: IntersectionWizardTurnDirection[],
): SignalGroupDisplayItem[] {
  if (trafficType === 'PEDESTRIAN') {
    return [
      {
        key: 'pedestrian',
        trafficLightSrc: '/assets/traffic-lights/tl-ped-all.png',
        trafficLightAlt: 'Fußgänger-Ampel',
        trafficLightWidth,
        trafficLightHeight: 48,
      },
    ];
  }

  const directions = normalizedDisplayDirections(turnDirections);

  if (trafficType === 'CAR' && directions.length === 2 && directions.includes('STRAIGHT')) {
    const sideDirection = directions.find((direction) => direction !== 'STRAIGHT');

    if (sideDirection === 'LEFT' || sideDirection === 'RIGHT') {
      return [
        {
          key: `car-straight-${sideDirection.toLowerCase()}`,
          signSrc: sideDirection === 'LEFT' ? '/assets/sign-straight-left.svg' : '/assets/sign-straight-right.svg',
          signAlt: sideDirection === 'LEFT' ? 'Geradeaus und links' : 'Geradeaus und rechts',
          trafficLightSrc: '/assets/traffic-lights/tl-car-all.png',
          trafficLightAlt: 'Auto-Ampel',
          trafficLightWidth,
          trafficLightHeight: 64,
        },
      ];
    }
  }

  return directions.map((direction) => ({
    key: `${trafficType.toLowerCase()}-${direction.toLowerCase()}`,
    signSrc: signByDirection[direction],
    signAlt: directionLabelByDirection[direction],
    trafficLightSrc:
      trafficType === 'TRAM' ? tramTrafficLightByDirection[direction] : '/assets/traffic-lights/tl-car-all.png',
    trafficLightAlt:
      trafficType === 'TRAM'
        ? `Tram ${directionLabelByDirection[direction]}`
        : `Auto ${directionLabelByDirection[direction]}`,
    trafficLightWidth,
    trafficLightHeight: 64,
  }));
}

function SignalGroupTrafficLightPreview(props: SignalGroupTrafficLightPreviewProps) {
  const items = signalGroupDisplayItems(props.trafficType, props.turnDirections);
  const scale = sizeScale[props.size ?? 'default'];
  const scaledSignalWidth = signalWidth * scale;
  const scaledSignalGroupWidth = maxSignalGroupWidth * scale;

  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'flex-start',
        justifyContent: justifyContentByAlign[props.align ?? 'center'],
        width: (theme) => `calc(${scaledSignalGroupWidth}px + ${theme.spacing(signalColumnGap * maxSignalGroupGaps)})`,
      }}
    >
      <Box
        sx={{
          display: 'grid',
          gridAutoColumns: 'max-content',
          gridAutoFlow: 'column',
          columnGap: signalColumnGap,
          alignItems: 'start',
          width: 'fit-content',
        }}
      >
        {items.map((item) => (
          <Box
            key={item.key}
            sx={{
              display: 'grid',
              gridTemplateRows:
                item.signSrc === undefined
                  ? `${item.trafficLightHeight * scale}px`
                  : `${scaledSignalWidth}px ${item.trafficLightHeight * scale}px`,
              justifyItems: 'center',
              rowGap: 0,
              width: 'max-content',
            }}
          >
            {item.signSrc === undefined ? null : (
              <Box
                component="img"
                src={item.signSrc}
                alt={item.signAlt}
                sx={{
                  display: 'block',
                  width: scaledSignalWidth,
                  height: scaledSignalWidth,
                  objectFit: 'contain',
                  transform: `translateY(${signOverlap * scale}px)`,
                }}
              />
            )}
            <Box
              component="img"
              src={item.trafficLightSrc}
              alt={item.trafficLightAlt}
              sx={{
                display: 'block',
                width: item.trafficLightWidth * scale,
                height: item.trafficLightHeight * scale,
                objectFit: 'contain',
              }}
            />
          </Box>
        ))}
      </Box>
    </Box>
  );
}

export default SignalGroupTrafficLightPreview;
export type { SignalGroupTrafficLightPreviewProps };
