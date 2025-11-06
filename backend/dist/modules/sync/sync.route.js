"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncRouter = void 0;
const express_1 = require("express");
const sync_controller_1 = require("./sync.controller");
const router = (0, express_1.Router)();
exports.syncRouter = router;
const controller = new sync_controller_1.SyncController();
router.get('/pull', controller.pull);
router.post('/push', controller.push);
//# sourceMappingURL=sync.route.js.map