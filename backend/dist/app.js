"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = void 0;
const cors_1 = __importDefault(require("cors"));
const express_1 = __importDefault(require("express"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const env_1 = require("./config/env");
const errorHandler_1 = require("./core/http/errorHandler");
const notFoundHandler_1 = require("./core/http/notFoundHandler");
const auth_route_1 = require("./modules/auth/http/auth.route");
const sync_route_1 = require("./modules/sync/sync.route");
const createApp = () => {
    const app = (0, express_1.default)();
    app.set('trust proxy', true);
    app.use((0, helmet_1.default)());
    app.use((0, cors_1.default)({
        origin: '*',
        exposedHeaders: ['x-request-id'],
    }));
    app.use(express_1.default.json());
    app.use(express_1.default.urlencoded({ extended: true }));
    app.use((0, morgan_1.default)(env_1.env.nodeEnv === 'production' ? 'combined' : 'dev', {
        skip: () => env_1.env.nodeEnv === 'test',
    }));
    app.get('/health', (_req, res) => res.json({
        status: 'ok',
        service: env_1.env.appName,
        version: env_1.env.nodeEnv,
    }));
    app.use('/api/auth', auth_route_1.authRouter);
    app.use('/api/sync', sync_route_1.syncRouter);
    app.use(notFoundHandler_1.notFoundHandler);
    app.use(errorHandler_1.errorHandler);
    return app;
};
exports.createApp = createApp;
//# sourceMappingURL=app.js.map