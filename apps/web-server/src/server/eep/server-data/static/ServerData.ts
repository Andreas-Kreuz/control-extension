import { alphabeticalSort } from '../../../clientio/alphabeticalSort';
import * as fromEepStore from '../EepDataStore';
import { DataType } from '@ce/web-shared';

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

const serverApiEntriesName = 'server.api-entries';

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
      const roomData = state.ceTypes[roomName];
      if (!roomData) {
        continue;
      }
      data.roomToJson[roomName] = JSON.stringify(roomData);

      dataTypes.push({
        name: roomName,
        checksum: state.eventCounter.toString(),
        url: urlPrefix + roomName,
        count: Object.keys(roomData).length,
        updated: true,
      });
    }

    dataTypes.push({
      name: serverApiEntriesName,
      checksum: state.eventCounter.toString(),
      url: urlPrefix + serverApiEntriesName,
      count: dataTypes.length + 1,
      updated: true,
    });
    data.roomToJson[serverApiEntriesName] = JSON.stringify(dataTypes);

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
    const roomJsonString = this.data.roomToJson[roomName];
    if (roomJsonString === undefined) {
      throw new Error('Room not available: ' + roomName);
    }
    return roomJsonString;
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
