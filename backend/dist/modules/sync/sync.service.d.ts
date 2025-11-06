export declare class SyncService {
    pullUpdates(_lastSyncedAt?: string): Promise<{
        message: string;
    }>;
    pushUpdates(_payload: unknown): Promise<void>;
}
//# sourceMappingURL=sync.service.d.ts.map