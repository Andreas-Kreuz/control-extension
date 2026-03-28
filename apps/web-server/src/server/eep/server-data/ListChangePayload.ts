export interface ListChangePayload<T> {
  ceType: string;
  keyId: string & keyof T;
  list: Record<string, T>;
}
