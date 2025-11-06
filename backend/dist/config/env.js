"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
const dotenv_1 = require("dotenv");
(0, dotenv_1.config)();
exports.env = {
    appName: process.env.APP_NAME ?? 'SmartKasir Backend',
    nodeEnv: process.env.NODE_ENV ?? 'development',
    port: Number(process.env.PORT ?? 4000),
    mysql: {
        host: process.env.MYSQL_HOST ?? 'localhost',
        port: Number(process.env.MYSQL_PORT ?? 3306),
        user: process.env.MYSQL_USER ?? 'root',
        password: process.env.MYSQL_PASSWORD ?? '',
        database: process.env.MYSQL_DATABASE ?? 'smartkasir',
    },
    jwtSecret: process.env.JWT_SECRET ?? 'change-this-secret',
    seed: {
        adminUsername: process.env.SEED_ADMIN_USERNAME ?? 'admin',
        adminPassword: process.env.SEED_ADMIN_PASSWORD ?? 'admin123',
        adminDisplayName: process.env.SEED_ADMIN_DISPLAY_NAME ?? 'Administrator',
    },
};
//# sourceMappingURL=env.js.map