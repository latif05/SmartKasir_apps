"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SyncService = void 0;
class SyncService {
    async pullUpdates(_lastSyncedAt) {
        // TODO: Implement data diffing logic for products, categories, transactions.
        return { message: 'Pull sync belum diimplementasikan' };
    }
    async pushUpdates(_payload) {
        // TODO: Merge incoming records into MySQL and resolve conflicts by updated_at.
    }
}
exports.SyncService = SyncService;
//# sourceMappingURL=sync.service.js.map