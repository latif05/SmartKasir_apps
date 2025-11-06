"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const apiResponse_1 = require("./apiResponse");
const httpError_1 = require("./httpError");
const errorHandler = (error, _req, res, _next) => {
    if (error instanceof httpError_1.HttpError) {
        return res
            .status(error.statusCode)
            .json((0, apiResponse_1.errorResponse)(error.message, error.details));
    }
    // eslint-disable-next-line no-console
    console.error('[UnhandledError]', error);
    return res.status(500).json((0, apiResponse_1.errorResponse)('Internal server error', {
        name: error.name,
        message: error.message,
    }));
};
exports.errorHandler = errorHandler;
//# sourceMappingURL=errorHandler.js.map