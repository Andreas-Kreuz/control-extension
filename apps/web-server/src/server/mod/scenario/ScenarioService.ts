import * as fromEepData from '../../eep/server-data/EepDataStore';
import { DynamicDataProvider } from '../../eep/server-data/dynamic/DynamicDataProvider';
import DynamicRoomService from '../../eep/server-data/dynamic/DynamicRoomService';
import ScenarioSelector from './ScenarioSelector';
import { ScenarioRoom } from '@ce/web-shared';
import { Server } from 'socket.io';

export default class ScenarioService implements DynamicRoomService {
  private roomDataProviders: DynamicDataProvider[] = [];
  private scenarioSelector = new ScenarioSelector();

  constructor(private io: Server) {
    this.roomDataProviders.push({
      roomType: ScenarioRoom,
      id: 'ScenarioRoom',
      jsonCreator: (_room: string): string => {
        return JSON.stringify(this.scenarioSelector.getScenarios());
      },
    });
  }

  getUpdaters = () => [
    {
      updateFromState: (state: Readonly<fromEepData.State>) => {
        this.scenarioSelector.updateFromState(state);
      },
    },
  ];

  getDataProviders = () => this.roomDataProviders;
}
