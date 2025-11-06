"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const zod_1 = require("zod");
const apiResponse_1 = require("../../../core/http/apiResponse");
const httpError_1 = require("../../../core/http/httpError");
const auth_service_1 = require("../services/auth.service");
const auth_validator_1 = require("../validators/auth.validator");
class AuthController {
    constructor(authService = new auth_service_1.AuthService()) {
        this.authService = authService;
        this.login = async (req, res, next) => {
            try {
                const payload = auth_validator_1.loginSchema.parse(req.body);
                const result = await this.authService.login(payload);
                return res.json((0, apiResponse_1.successResponse)(result, 'Login berhasil'));
            }
            catch (error) {
                if (error instanceof zod_1.ZodError) {
                    return next(new httpError_1.HttpError(400, 'Input tidak valid', error.flatten().fieldErrors));
                }
                return next(error);
            }
        };
    }
}
exports.AuthController = AuthController;
//# sourceMappingURL=auth.controller.js.map