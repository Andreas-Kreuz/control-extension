export interface ParsedCeTypeRoom {
  ceType: string;
  entryId: string;
}

export class CeTypeRoom {
  private dataPrefix: string;
  private dataPostfix: string;
  private roomPrefix: string;
  private roomPostfix: string;

  constructor(private ceType: string) {
    this.dataPrefix = '[DataChange - ' + this.ceType + ": '";
    this.dataPostfix = "']";
    this.roomPrefix = '[Room - ' + ceType + ": '";
    this.roomPostfix = "']";
  }

  roomId(entryId: string): string {
    return this.roomPrefix + entryId + this.roomPostfix;
  }

  eventId(eventId: string): string {
    return this.dataPrefix + eventId + this.dataPostfix;
  }

  matchesRoom(roomId: string) {
    return roomId.indexOf(this.roomPrefix) === 0;
  }

  idOfRoom(roomId: string): string {
    if (roomId.indexOf(this.roomPrefix) === 0) {
      return roomId.substring(this.roomPrefix.length, roomId.length - this.roomPostfix.length);
    } else {
      throw new Error('roomId does not start with prefix: ' + roomId);
    }
  }

  idOfEvent(eventId: string): string {
    if (eventId.indexOf(this.dataPrefix) === 0) {
      return eventId.substring(this.dataPrefix.length, eventId.length - this.dataPostfix.length);
    } else {
      throw new Error('eventId does not start with prefix: ' + eventId);
    }
  }

  static parseRoomId(roomId: string): ParsedCeTypeRoom | undefined {
    const roomPrefix = '[Room - ';
    const separator = ": '";
    const roomPostfix = "']";

    if (!roomId.startsWith(roomPrefix) || !roomId.endsWith(roomPostfix)) {
      return undefined;
    }

    const separatorIndex = roomId.indexOf(separator, roomPrefix.length);
    if (separatorIndex < 0) {
      return undefined;
    }

    return {
      ceType: roomId.substring(roomPrefix.length, separatorIndex),
      entryId: roomId.substring(separatorIndex + separator.length, roomId.length - roomPostfix.length),
    };
  }
}

export default CeTypeRoom;
