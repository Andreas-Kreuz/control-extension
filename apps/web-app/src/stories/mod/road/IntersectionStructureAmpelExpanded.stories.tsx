import type { Meta, StoryObj } from '@storybook/react';
import type { StructureAppDto } from '@ce/web-shared';
import StructureSignalInstaller from '../../../features/road/components/structure-signal-installer/StructureSignalInstaller';

const structures: StructureAppDto[] = [
  {
    id: '#3026_Straba Signal Gehäuse Mast 4',
    name: '#3026_Straba Signal Gehäuse Mast 4',
    pos_x: 10,
    pos_y: 20,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: 'F0=#5523_Straba Signal Halt,F1=#5521_Straba Signal geradeaus,F4=#5520_Straba Signal anhalten,bl=#5527_Straba Signal Gehäuse Blendschutz 4,g=#5521_Straba Signal geradeaus,p1=#5523_Straba Signal Halt,p2=#5520_Straba Signal anhalten,p3=#5521_Straba Signal geradeaus,r=#5523_Straba Signal Halt,y=#5520_Straba Signal anhalten,',
    light: false,
    smoke: false,
    fire: false,
  },
  {
    id: '#5523_Straba Signal Halt',
    name: '#5523_Straba Signal Halt',
    pos_x: 10,
    pos_y: 19.8,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: '',
    light: false,
    smoke: false,
    fire: false,
  },
  {
    id: '#5520_Straba Signal anhalten',
    name: '#5520_Straba Signal anhalten',
    pos_x: 10,
    pos_y: 19.9,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: '',
    light: false,
    smoke: false,
    fire: false,
  },
  {
    id: '#5521_Straba Signal geradeaus',
    name: '#5521_Straba Signal geradeaus',
    pos_x: 10,
    pos_y: 20.1,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: '',
    light: false,
    smoke: false,
    fire: false,
  },
  {
    id: '#5524_Straba Signal A',
    name: '#5524_Straba Signal A',
    pos_x: 10,
    pos_y: 20.2,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: '',
    light: false,
    smoke: false,
    fire: false,
  },
  {
    id: '#5527_Straba Signal Gehäuse Blendschutz 4',
    name: '#5527_Straba Signal Gehäuse Blendschutz 4',
    pos_x: 10,
    pos_y: 20.3,
    pos_z: 2,
    rot_x: 0,
    rot_y: 0,
    rot_z: 90,
    modelType: 22,
    modelTypeText: 'Immobilie',
    tag: '',
    light: false,
    smoke: false,
    fire: false,
  },
];

const meta = {
  title: 'Module Elements/Road/Intersection Structure Ampel Expanded',
  component: StructureSignalInstaller,
  args: {
    structures,
    onAlign: () => undefined,
  },
} satisfies Meta<typeof StructureSignalInstaller>;

export default meta;
type Story = StoryObj<typeof meta>;

export const ImmobilieAnforderung: Story = {
  name: 'Immobilie Anforderung',
};

export const ImmobilieRot: Story = {
  name: 'Immobilie Rot',
};

export const ImmobilieGelb: Story = {
  name: 'Immobilie Gelb',
};

export const ImmobilieGruen: Story = {
  name: 'Immobilie Grün',
};

export const ImmobilieMast: Story = {
  name: 'Immobilie Mast',
};

export const ImmobilieBlende: Story = {
  name: 'Immobilie Blende',
};
