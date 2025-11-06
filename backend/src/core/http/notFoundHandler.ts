import type { NextFunction, Request, Response } from 'express';

import { errorResponse } from './apiResponse';

export const notFoundHandler = (
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  res.status(404).json(errorResponse('Route not found'));
};
