export class ServerStatusEvent {
  // System room for server-wide status updates.
  static readonly Room = '[Server Status Event]';
  static readonly UrlsChanged = '[Server Status Event] Urls Changed';
  static readonly CounterUpdated = '[Server Status Event] Counter Updated';
}
