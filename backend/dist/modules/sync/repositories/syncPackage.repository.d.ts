import type { SyncDirection, SyncPackage, SyncStatus } from '../models/syncPackage';
export declare class SyncPackageRepository {
    create(params: {
        direction: SyncDirection;
        payload?: unknown;
        filePath?: string | null;
    }): Promise<string>;
    updateStatus(id: string, status: SyncStatus, errorMessage?: string | null): Promise<void>;
    findPending(direction: SyncDirection): Promise<SyncPackage[]>;
    private mapRowToEntity;
}
//# sourceMappingURL=syncPackage.repository.d.ts.map