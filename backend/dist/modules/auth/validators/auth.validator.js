"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loginSchema = void 0;
const zod_1 = require("zod");
exports.loginSchema = zod_1.z.object({
    username: zod_1.z.string().min(1, 'Username wajib diisi'),
    password: zod_1.z.string().min(1, 'Kata sandi wajib diisi'),
});
//# sourceMappingURL=auth.validator.js.map