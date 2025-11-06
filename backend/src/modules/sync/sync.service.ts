export class SyncService {
  async pullUpdates(
    _lastSyncedAt?: string,
  ): Promise<{ message: string }> {
    // TODO: Implement data diffing logic for products, categories, transactions.
    return { message: 'Pull sync belum diimplementasikan' };
  }

  async pushUpdates(_payload: unknown): Promise<void> {
    // TODO: Merge incoming records into MySQL and resolve conflicts by updated_at.
  }
}
