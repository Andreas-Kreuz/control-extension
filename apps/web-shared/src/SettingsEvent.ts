export enum SettingsEvent {
  // System room for settings and admin state updates.
  Room = '[Settings Event]',
  ChangeDir = '[Settings Event] Change Dir',
  ChangePairingRequired = '[Settings Event] Change Pairing Required',
  DirOk = '[Settings Event] Dir Ok',
  DirError = '[Settings Event] Dir Error',
  Host = '[Settings Event] Set Host',
  PairingRequired = '[Settings Event] Pairing Required',
}
