export interface DataChangePayload<T> {
  ceType: string;
  keyId: string & keyof T;
  element: T;
}
