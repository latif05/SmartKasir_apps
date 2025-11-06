import type { NextFunction, Request, Response } from 'express';
import { SyncService } from './sync.service';
export declare class SyncController {
    private readonly service;
    constructor(service?: SyncService);
    pull: (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
    push: (req: Request, res: Response, next: NextFunction) => Promise<void | Response<any, Record<string, any>>>;
}
//# sourceMappingURL=sync.controller.d.ts.map