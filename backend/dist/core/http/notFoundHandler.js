"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.notFoundHandler = void 0;
const apiResponse_1 = require("./apiResponse");
const notFoundHandler = (_req, res, _next) => {
    res.status(404).json((0, apiResponse_1.errorResponse)('Route not found'));
};
exports.notFoundHandler = notFoundHandler;
//# sourceMappingURL=notFoundHandler.js.map