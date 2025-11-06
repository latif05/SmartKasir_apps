"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserRepository = void 0;
const knexClient_1 = require("../../../database/knexClient");
class UserRepository {
    async findByUsername(username) {
        const row = await (0, knexClient_1.knexClient)('users')
            .where({ username })
            .first();
        if (!row) {
            return null;
        }
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
exports.UserRepository = UserRepository;
//# sourceMappingURL=user.repository.js.map