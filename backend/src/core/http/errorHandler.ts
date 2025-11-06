import type { NextFunction, Request, Response } from 'express';

import { errorResponse } from './apiResponse';
import { HttpError } from './httpError';

export const errorHandler = (
  error: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  if (error instanceof HttpError) {
    return res
      .status(error.statusCode)
      .json(errorResponse(error.message, error.details));
  }

  // eslint-disable-next-line no-console
  console.error('[UnhandledError]', error);
  return res.status(500).json(
    errorResponse('Internal server error', {
      name: error.name,
      message: error.message,
    }),
  );
};
