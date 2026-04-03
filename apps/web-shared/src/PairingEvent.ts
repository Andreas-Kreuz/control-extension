export enum PairingStatus {
  Connecting = 'connecting',
  Pending = 'pending',
  Approved = 'approved',
  Admin = 'admin',
}

export enum PairingEvent {
  Status = '[Pairing Event] Status',
  PendingList = '[Pairing Event] Pending List',
  ApproveClient = '[Pairing Event] Approve Client',
}

export interface PairingStatusPayload {
  status: PairingStatus;
  code?: string;
  clientKey?: string;
  isAdmin?: boolean;
}

export interface PendingPairingClient {
  clientKey: string;
  code: string;
  connectedAt: number;
  requestedPath: string;
  socketId: string;
}

export interface ApprovePairingClientPayload {
  clientKey: string;
}
