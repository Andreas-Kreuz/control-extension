import List from '@mui/material/List';
import type { Meta, StoryObj } from '@storybook/react';
import BreakableModelValue from '../../features/trains/components/panels/BreakableModelValue';
import {
  HookStatusEntry,
  LengthEntry,
  LicencePlateEntry,
  ModelEntry,
  NameEntry,
  OrientationEntry,
  PropelledEntry,
  RouteEntry,
  SpeedEntry,
  TagEntry,
  TrainPositionEntry,
  VehicleNumberEntry,
} from '../../shared/components/iconlist';

function IconListEntriesOverview() {
  return (
    <List
      dense
      sx={{
        maxWidth: 520,
        '& .MuiListItemText-root': { display: 'flex', flexDirection: 'column-reverse' },
      }}
    >
      <NameEntry value="Regionalexpress 7142" />
      <RouteEntry value="Anlage Stadtverkehr" />
      <SpeedEntry value="82 km/h" />
      <TagEntry value="Doppelstockwagen | Steuerwagen" />
      <VehicleNumberEntry value="7142" />
      <LicencePlateEntry value="DD CE 42" />
      <HookStatusEntry value="Haken bereit" />
      <TrainPositionEntry value="3" />
      <ModelEntry
        value={<BreakableModelValue value="Resourcen\\Rollmaterial\\Schiene\\Personenwagen\\Dosto_Steuerwagen.xml" />}
      />
      <LengthEntry value="26.4 m" />
      <PropelledEntry value="Ja" />
      <OrientationEntry value="Vorwärts" />
    </List>
  );
}

const meta = {
  title: 'Elements/Icon List/Entries',
  component: IconListEntriesOverview,
} satisfies Meta<typeof IconListEntriesOverview>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Overview: Story = {};

export const OnMobile: Story = {
  globals: {
    viewport: { value: 'mobile1', isRotated: false },
  },
  tags: ['mobile'],
};
