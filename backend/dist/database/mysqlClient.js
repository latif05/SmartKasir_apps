"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.mysqlPool = void 0;
const promise_1 = __importDefault(require("mysql2/promise"));
const env_1 = require("../config/env");
exports.mysqlPool = promise_1.default.createPool({
    host: env_1.env.mysql.host,
    port: env_1.env.mysql.port,
    user: env_1.env.mysql.user,
    password: env_1.env.mysql.password,
    database: env_1.env.mysql.database,
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true,
});
//# sourceMappingURL=mysqlClient.js.map