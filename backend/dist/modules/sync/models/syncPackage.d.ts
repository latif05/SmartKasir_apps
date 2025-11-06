export type SyncDirection = 'push' | 'pull';
export type SyncStatus = 'pending' | 'processing' | 'completed' | 'failed';
export interface SyncPackage {
    id: string;
    direction: SyncDirection;
    filePath: string | null;
    payload: unknown;
    status: SyncStatus;
    errorMessage: string | null;
    createdAt: Date;
    updatedAt: Date;
}
//# sourceMappingURL=syncPackage.d.ts.map