"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.knexClient = void 0;
const knex_1 = __importDefault(require("knex"));
const env_1 = require("../config/env");
const config = {
    client: 'mysql2',
    connection: {
        host: env_1.env.mysql.host,
        port: env_1.env.mysql.port,
        user: env_1.env.mysql.user,
        password: env_1.env.mysql.password,
        database: env_1.env.mysql.database,
    },
    pool: {
        min: 0,
        max: 10,
    },
};
exports.knexClient = (0, knex_1.default)(config);
//# sourceMappingURL=knexClient.js.map