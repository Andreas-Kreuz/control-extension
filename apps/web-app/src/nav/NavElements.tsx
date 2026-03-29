import { useState } from 'react';

const hubCeModuleId = 'b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41'; // "ce.hub.CeHubModule"
const roadCeModuleId = 'c5a3e6d3-0f9b-4c89-a908-ed8cf8809362'; // "ce.mods.road.CeRoadModule"
const transitCeModuleId = '83ce6b42-1bda-45e0-8b4a-e8daeed047ab'; // "ce.mods.transit.CeTransitModule"

function useNavState(): {
  name: string;
  available: boolean;
  values: {
    available: boolean;
    icon: string;
    image?: string;
    title: string;
    subtitle?: string;
    link: string;
    description?: string;
    linkDescription?: string;
    requiredModuleId?: string;
  }[];
}[] {
  const [availLuaData, setAvailLuaData] = useState(false);
  const [availIntersection, setAvailIntersection] = useState(false);
  const [availTransit, setAvailTransit] = useState(false);
  const [availModules, setAvailModules] = useState(false);

  const navigation = [
    {
      name: 'Home',
      available: true,
      values: [
        {
          available: true,
          icon: 'home',
          title: 'Home',
          link: '/',
        },
      ],
    },
    {
      name: 'Verkehr',
      available: availLuaData && (availIntersection || availTransit),
      values: [
        {
          available: availIntersection,
          icon: 'gamepad',
          title: 'Ampelkreuzungen',
          subtitle: 'Steuern mit der Lua-Bibliothek',
          link: '/road',
          image: 'card-img-intersection.jpg',
          description: 'Schalte Deine Kreuzungen oder setze die passende Kamera.',
          linkDescription: 'Kreuzungen zeigen',
          requiredModuleId: roadCeModuleId,
        },
        {
          available: availTransit,
          icon: 'route',
          title: 'ÖPNV-Linien',
          subtitle: 'Nahverkehr mit der Lua-Bibliothek',
          link: '/transit',
          image: 'card-img-traffic.jpg',
          description: 'Schaue Deine Nahverkehrslinien und -Haltestellen an.',
          linkDescription: 'ÖNPV anzeigen',
          requiredModuleId: transitCeModuleId,
        },
        {
          available: availLuaData,
          icon: 'directions_car',
          title: 'Fahrzeuge',
          subtitle: 'Gekoppelte Fahrzeuge und Züge',
          link: '/trains',
          image: 'card-img-trains-all.jpg',
          description: 'Hier findest Du auch Trams, die auf der Straße fahren.',
          linkDescription: 'Fahrzeuge zeigen',
          requiredModuleId: hubCeModuleId,
        },
        // {
        //   available: availLuaData,
        //   icon: 'directions_car',
        //   title: 'Autos',
        //   subtitle: 'Straßen',
        //   link: '/trains/road',
        //   image: 'card-img-trains-road.jpg',
        //   description: 'Hier findest Du auch Trams, die auf der Straße fahren.',
        //   linkDescription: 'Autos zeigen',
        //   requiredModuleId: hubCeModuleId,
        // },
        // {
        //   available: availLuaData,
        //   icon: 'tram',
        //   title: 'Trams',
        //   subtitle: 'Straßenbahngleise',
        //   link: '/trains/tram',
        //   image: 'card-img-trains-tram.jpg',
        //   description: 'Trams, die auf der Straße fahren, findest Du unter Autos.',
        //   linkDescription: 'Trams zeigen',
        //   requiredModuleId: hubCeModuleId,
        // },
        // {
        //   available: availLuaData,
        //   icon: 'train',
        //   title: 'Züge',
        //   subtitle: 'Bahngleise',
        //   link: '/trains/rail',
        //   image: 'card-img-trains-rail.jpg',
        //   description: 'Fahrzeuge, die auf Bahngleisen unterwegs sind.',
        //   linkDescription: 'Züge zeigen',
        //   requiredModuleId: hubCeModuleId,
        // },
      ],
    },
    {
      name: 'Daten',
      available: true,
      values: [
        {
          available: true,
          icon: 'message',
          title: 'Log',
          link: '/log',
          description: 'Zeige die Log-Datei von EEP an',
          linkDescription: 'Log-Datei ansehen',
        },
        {
          available: availLuaData,
          icon: 'memory',
          title: 'Speicher',
          link: '/data',
          description: 'Mit EEPSaveData gespeicherte Felder',
          linkDescription: 'Zu den Daten',
          requiredModuleId: hubCeModuleId,
        },
        {
          available: availLuaData,
          icon: 'traffic',
          title: 'Signale',
          link: '/signals',
          description: 'Enthält Signale, Ampeln und Schranken',
          linkDescription: 'Zu den Signalen',
          requiredModuleId: hubCeModuleId,
        },
        {
          available: availModules,
          icon: 'list_alt',
          title: 'Roh-Daten',
          link: '/generic-data',
          description: 'Übersicht der Rohdaten von EEP-Web',
          linkDescription: 'Zu den Daten',
        },
      ],
    },
  ];

  return navigation;
}

export default useNavState;
