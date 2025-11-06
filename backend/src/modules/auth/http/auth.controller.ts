import type { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';

import { successResponse } from '../../../core/http/apiResponse';
import { HttpError } from '../../../core/http/httpError';
import { AuthService } from '../services/auth.service';
import { loginSchema } from '../validators/auth.validator';

export class AuthController {
  constructor(private readonly authService = new AuthService()) {}

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const payload = loginSchema.parse(req.body);
      const result = await this.authService.login(payload);
      return res.json(successResponse(result, 'Login berhasil'));
    } catch (error) {
      if (error instanceof ZodError) {
        return next(
          new HttpError(400, 'Input tidak valid', error.flatten().fieldErrors),
        );
      }
      return next(error);
    }
  };
}
