"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SyncPackageRepository = void 0;
const knexClient_1 = require("../../../database/knexClient");
const tableName = 'sync_packages';
class SyncPackageRepository {
    async create(params) {
        const [row] = await (0, knexClient_1.knexClient)(tableName).insert({
            id: knexClient_1.knexClient.raw('UUID()'),
            direction: params.direction,
            payload: params.payload ?? null,
            file_path: params.filePath ?? null,
        }, ['id']);
        if (typeof row === 'object' && row !== null && 'id' in row) {
            return String(row.id);
        }
        const [idRow] = await (0, knexClient_1.knexClient)(tableName)
            .select('id')
            .orderBy('created_at', 'desc')
            .limit(1);
        return idRow?.id ?? '';
    }
    async updateStatus(id, status, errorMessage) {
        await (0, knexClient_1.knexClient)(tableName)
            .where({ id })
            .update({
            status,
            error_message: errorMessage ?? null,
            updated_at: knexClient_1.knexClient.fn.now(),
        });
    }
    async findPending(direction) {
        const rows = await (0, knexClient_1.knexClient)(tableName)
            .where({ direction, status: 'pending' })
            .orderBy('created_at', 'asc');
        return rows.map(this.mapRowToEntity);
    }
    mapRowToEntity(row) {
        return {
            id: row.id,
            direction: row.direction,
            filePath: row.file_path,
            payload: row.payload,
            status: row.status,
            errorMessage: row.error_message,
            createdAt: new Date(row.created_at),
            updatedAt: new Date(row.updated_at),
        };
    }
}
exports.SyncPackageRepository = SyncPackageRepository;
//# sourceMappingURL=syncPackage.repository.js.map