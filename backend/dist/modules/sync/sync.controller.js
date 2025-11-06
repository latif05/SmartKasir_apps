"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SyncController = void 0;
const apiResponse_1 = require("../../core/http/apiResponse");
const sync_service_1 = require("./sync.service");
class SyncController {
    constructor(service = new sync_service_1.SyncService()) {
        this.service = service;
        this.pull = async (req, res, next) => {
            try {
                const { lastSyncedAt } = req.query;
                const data = await this.service.pullUpdates(typeof lastSyncedAt === 'string' ? lastSyncedAt : undefined);
                return res.json((0, apiResponse_1.successResponse)(data, 'Data sinkronisasi siap'));
            }
            catch (error) {
                return next(error);
            }
        };
        this.push = async (req, res, next) => {
            try {
                await this.service.pushUpdates(req.body);
                return res.json((0, apiResponse_1.successResponse)(null, 'Data sinkronisasi diterima'));
            }
            catch (error) {
                return next(error);
            }
        };
    }
}
exports.SyncController = SyncController;
//# sourceMappingURL=sync.controller.js.map