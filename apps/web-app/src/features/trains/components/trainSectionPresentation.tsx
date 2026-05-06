import CarRentalIcon from '@mui/icons-material/CarRental';
import CarRepairIcon from '@mui/icons-material/CarRepair';
import DirectionsRailwayIcon from '@mui/icons-material/DirectionsRailway';
import TextFieldsIcon from '@mui/icons-material/TextFields';
import TuneIcon from '@mui/icons-material/Tune';

export const trainSections = {
  trainInfo: {
    title: 'Zug Info',
    sideSheetTitle: 'Information',
    icon: <DirectionsRailwayIcon color="primary" />,
  },
  trainControls: {
    title: 'Zug steuern',
    sideSheetTitle: 'Kameras',
    icon: <CarRentalIcon color="primary" />,
  },
  trainAxes: {
    title: 'Achsen des Zugs',
    icon: <TuneIcon color="primary" />,
  },
  trainLine: {
    sideSheetTitle: 'Linien',
    icon: <DirectionsRailwayIcon color="primary" />,
  },
  rollingStockInfo: {
    title: 'Fahrzeug Info',
    sideSheetTitle: 'RollingStock',
    icon: <CarRepairIcon color="primary" />,
  },
  rollingStockTextures: {
    title: 'Aufschriften',
    icon: <TextFieldsIcon color="primary" />,
  },
  rollingStockAxes: {
    title: 'Achsen',
    icon: <TuneIcon color="primary" />,
  },
} as const;
