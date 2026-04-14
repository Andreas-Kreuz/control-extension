type InterestDescriptor = {
  ceType: string;
  id: string;
};

function interestKeyOf(ceType: string, id: string): string {
  return ceType + '|' + id;
}

export default class InterestSyncRegistry {
  private tokenToInterest = new Map<string, InterestDescriptor>();
  private tokenTimers = new Map<string, NodeJS.Timeout>();
  private interestCounts = new Map<string, number>();

  constructor(private queueCommand: (command: string) => void) {}

  retainToken(token: string, ceType: string, id: string): void {
    const existing = this.tokenToInterest.get(token);
    if (existing && existing.ceType === ceType && existing.id === id) {
      return;
    }

    if (existing) {
      this.releaseToken(token);
    }

    const key = interestKeyOf(ceType, id);
    const count = this.interestCounts.get(key) ?? 0;
    this.tokenToInterest.set(token, { ceType, id });
    this.interestCounts.set(key, count + 1);

    if (count === 0) {
      this.queueCommand('HubInterestSync.startSyncFor|' + ceType + '|' + id);
    }
  }

  releaseToken(token: string): void {
    const existing = this.tokenToInterest.get(token);
    if (!existing) {
      return;
    }

    const timer = this.tokenTimers.get(token);
    if (timer) {
      clearTimeout(timer);
      this.tokenTimers.delete(token);
    }

    const key = interestKeyOf(existing.ceType, existing.id);
    const count = this.interestCounts.get(key) ?? 0;
    if (count <= 1) {
      this.interestCounts.delete(key);
      this.queueCommand('HubInterestSync.stopSyncFor|' + existing.ceType + '|' + existing.id);
    } else {
      this.interestCounts.set(key, count - 1);
    }

    this.tokenToInterest.delete(token);
  }

  touchLeasedToken(token: string, ceType: string, id: string, ttlMs: number): void {
    this.retainToken(token, ceType, id);

    const oldTimer = this.tokenTimers.get(token);
    if (oldTimer) {
      clearTimeout(oldTimer);
    }

    this.tokenTimers.set(
      token,
      setTimeout(() => {
        this.releaseToken(token);
      }, ttlMs),
    );
  }
}
