"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const httpError_1 = require("../../../core/http/httpError");
const env_1 = require("../../../config/env");
const user_repository_1 = require("../../users/repositories/user.repository");
class AuthService {
    constructor(userRepository = new user_repository_1.UserRepository()) {
        this.userRepository = userRepository;
    }
    async login(input) {
        const user = await this.userRepository.findByUsername(input.username);
        if (!user) {
            throw new httpError_1.HttpError(401, 'Username atau kata sandi tidak valid');
        }
        const passwordMatches = await bcryptjs_1.default.compare(input.password, user.passwordHash);
        if (!passwordMatches) {
            throw new httpError_1.HttpError(401, 'Username atau kata sandi tidak valid');
        }
        const token = jsonwebtoken_1.default.sign({ sub: user.id, role: user.role }, env_1.env.jwtSecret, { expiresIn: '12h' });
        return {
            token,
            user: this.toSafeUser(user),
        };
    }
    toSafeUser(user) {
        return {
            id: user.id,
            username: user.username,
            displayName: user.displayName,
            role: user.role,
        };
    }
}
exports.AuthService = AuthService;
//# sourceMappingURL=auth.service.js.map