import { alphabeticalSort } from '../../../clientio/alphabeticalSort';
import * as fromEepStore from '../EepDataStore';
import { CeTypes, DataType } from '@ak/web-shared';

export interface ServerData {
  rooms: Record<string, unknown>;
  roomToJson: Record<string, string>;
  urls: string[];
  urlJson: string;
}

const initialData: ServerData = {
  rooms: {},
  roomToJson: {},
  urls: [],
  urlJson: JSON.stringify([]),
};

export default class JsonApiReducer {
  private data = initialData;

  setLastAnnouncedData(data: ServerData): void {
    this.data = data;
  }

  getLastAnnouncedData() {
    return this.data;
  }

  static calculateData(state: Readonly<fromEepStore.State>): ServerData {
    const urlPrefix = '/api/v1/';
    const data: ServerData = { roomToJson: {}, rooms: {}, urls: [], urlJson: '' };
    const dataTypes: DataType[] = [];
    data.rooms = { ...state.ceTypes };
    for (const roomName of Object.keys(state.ceTypes)) {
      data.roomToJson[roomName] = JSON.stringify(state.ceTypes[roomName]);

      dataTypes.push({
        name: roomName,
        checksum: state.eventCounter.toString(),
        url: urlPrefix + roomName,
        count: Object.keys(state.ceTypes[roomName]).length,
        updated: true,
      });
    }

    dataTypes.push({
      name: CeTypes.ServerStats,
      checksum: state.eventCounter.toString(),
      url: urlPrefix + CeTypes.ServerStats,
      count: 1,
      updated: true,
    });
    data.roomToJson[CeTypes.ServerStats] = JSON.stringify({
      eepDataUpToDate: dataTypes.length > 1,
      luaDataReceived: dataTypes.length > 1,
      apiEntryCount: dataTypes.length + 1,
    });

    dataTypes.push({
      name: CeTypes.ServerApiEntries,
      checksum: state.eventCounter.toString(),
      url: urlPrefix + CeTypes.ServerApiEntries,
      count: dataTypes.length + 1,
      updated: true,
    });
    data.roomToJson[CeTypes.ServerApiEntries] = JSON.stringify(dataTypes);

    data.urls = dataTypes.map((dt) => dt.name).sort(alphabeticalSort);
    data.urlJson = JSON.stringify(data.urls);

    return data;
  }

  static calcChangedRooms(roomsToCheck: string[], oldData: ServerData, data: ServerData): string[] {
    const namesOfChangedRooms: string[] = [];
    for (const room of roomsToCheck) {
      if (oldData.roomToJson[room] !== data.roomToJson[room]) namesOfChangedRooms.push(room);
    }
    return namesOfChangedRooms;
  }

  roomAvailable(roomName: string): boolean {
    return Object.prototype.hasOwnProperty.call(this.data.roomToJson, roomName);
  }

  getAllRoomNames(): string[] {
    return Object.keys(this.data.roomToJson);
  }

  getRoomJsonString(roomName: string): string {
    return this.data.roomToJson[roomName];
  }

  getRoomJson(roomName: string): unknown {
    return this.data.rooms[roomName];
  }

  getUrlJson(): string {
    return this.data.urlJson;
  }
  getUrls(): string[] {
    return this.data.urls;
  }
}
