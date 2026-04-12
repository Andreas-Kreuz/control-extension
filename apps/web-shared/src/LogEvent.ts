export enum LogEvent {
  // System room for log streaming and log control events.
  Room = '[Log Event]',
  LinesAdded = '[Log Event] Lines Added',
  LinesCleared = '[Log Event] Lines Cleared',
  ClearLog = '[Log Event] Clear Log',
  SendTestMessage = '[Log Event] Send Test Message',
}
