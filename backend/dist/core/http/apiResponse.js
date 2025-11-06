"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorResponse = exports.successResponse = void 0;
const successResponse = (data, message = 'OK') => {
    const response = {
        success: true,
        message,
    };
    if (typeof data !== 'undefined') {
        response.data = data;
    }
    return response;
};
exports.successResponse = successResponse;
const errorResponse = (message, errors) => {
    const response = {
        success: false,
        message,
    };
    if (typeof errors !== 'undefined') {
        response.errors = errors;
    }
    return response;
};
exports.errorResponse = errorResponse;
//# sourceMappingURL=apiResponse.js.map