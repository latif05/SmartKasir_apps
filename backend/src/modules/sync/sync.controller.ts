import type { NextFunction, Request, Response } from 'express';

import { successResponse } from '../../core/http/apiResponse';
import { SyncService } from './sync.service';

export class SyncController {
  constructor(private readonly service = new SyncService()) {}

  pull = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { lastSyncedAt } = req.query;
      const data = await this.service.pullUpdates(
        typeof lastSyncedAt === 'string' ? lastSyncedAt : undefined,
      );
      return res.json(successResponse(data, 'Data sinkronisasi siap'));
    } catch (error) {
      return next(error);
    }
  };

  push = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await this.service.pushUpdates(req.body);
      return res.json(successResponse(null, 'Data sinkronisasi diterima'));
    } catch (error) {
      return next(error);
    }
  };
}
