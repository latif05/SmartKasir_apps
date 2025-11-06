"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthRepository = void 0;
const knexClient_1 = require("../../../database/knexClient");
class AuthRepository {
    constructor() { }
    async findByUsername(username) {
        const row = await (0, knexClient_1.knexClient)('users')
            .where({ username })
            .first();
        if (!row) {
            return null;
        }
        return this.mapRowToUser(row);
    }
    mapRowToUser(row) {
        return {
            id: row.id,
            username: row.username,
            passwordHash: row.password_hash,
            displayName: row.display_name,
            role: row.role,
            createdAt: new Date(row.created_at),
            updatedAt: new Date(row.updated_at),
        };
    }
}
exports.AuthRepository = AuthRepository;
//# sourceMappingURL=auth.repository.js.map