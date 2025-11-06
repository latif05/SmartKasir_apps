"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = require("./app");
const env_1 = require("./config/env");
const knexClient_1 = require("./database/knexClient");
const bootstrap = async () => {
    try {
        await knexClient_1.knexClient.raw('SELECT 1');
        // eslint-disable-next-line no-console
        console.log('[database] MySQL connection established');
    }
    catch (error) {
        // eslint-disable-next-line no-console
        console.error('[database] Failed to connect to MySQL', error);
        process.exit(1);
    }
    const app = (0, app_1.createApp)();
    app.listen(env_1.env.port, () => {
        // eslint-disable-next-line no-console
        console.log(`[server] ${env_1.env.appName} listening on port ${env_1.env.port} (${env_1.env.nodeEnv})`);
    });
};
void bootstrap();
//# sourceMappingURL=server.js.map