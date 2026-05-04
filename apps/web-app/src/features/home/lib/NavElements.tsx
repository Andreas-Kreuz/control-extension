export const hubCeModuleId = 'b9f34a2e-1c5d-4f8a-9e7b-3d0a6c8f2e41'; // "ce.hub.CeHubModule"
export const roadCeModuleId = 'c5a3e6d3-0f9b-4c89-a908-ed8cf8809362'; // "ce.mods.road.CeRoadModule"
export const transitCeModuleId = '83ce6b42-1bda-45e0-8b4a-e8daeed047ab'; // "ce.mods.transit.CeTransitModule"

export interface NavElement {
  available: boolean;
  icon: string;
  image?: string;
  title: string;
  subtitle?: string;
  link: string;
  description?: string;
  linkDescription?: string;
  requiredModuleId?: string;
}

export interface NavSection {
  name: string;
  available: boolean;
  values: NavElement[];
}

function getNavSections(isModuleAvailable: (moduleId: string) => boolean): NavSection[] {
  const availModules = false;

  const navigation: NavSection[] = [
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
      available: true,
      values: [
        {
          available: true,
          icon: 'directions_car',
          title: 'Fuhrpark',
          subtitle: 'Fahrzeugverbände und Fahrzeuge',
          link: '/trains',
          image: 'card-img-trains-all.jpg',
          description: 'Hier findest Du auch Trams, die auf der Straße fahren.',
          linkDescription: 'Fahrzeuge zeigen',
          requiredModuleId: hubCeModuleId,
        },
        {
          available: true,
          icon: 'gamepad',
          title: 'Ampeln',
          subtitle: 'Kreuzungen automatisch steuern',
          link: '/road',
          image: 'card-img-intersection.jpg',
          description: 'Schalte Deine Kreuzungen oder setze die passende Kamera.',
          linkDescription: 'Kreuzungen zeigen',
          requiredModuleId: roadCeModuleId,
        },
        {
          available: true,
          icon: 'route',
          title: 'ÖPNV',
          subtitle: 'Nahverkehrslinien verwalten',
          link: '/transit',
          image: 'card-img-traffic.jpg',
          description: 'Schaue Deine Nahverkehrslinien und -Haltestellen an.',
          linkDescription: 'ÖNPV anzeigen',
          requiredModuleId: transitCeModuleId,
        },
        // {
        //   available: true,
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
        //   available: true,
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
        //   available: true,
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
          available: true,
          icon: 'memory',
          title: 'Speicher',
          link: '/data',
          description: 'Mit EEPSaveData gespeicherte Felder',
          linkDescription: 'Zu den Daten',
          requiredModuleId: hubCeModuleId,
        },
        {
          available: true,
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

  return navigation.map((section) => {
    const values = section.values.map((value) => ({
      ...value,
      available: value.available && (value.requiredModuleId === undefined || isModuleAvailable(value.requiredModuleId)),
    }));

    return {
      ...section,
      available: section.available && values.some((value) => value.available),
      values,
    };
  });
}

export default getNavSections;
