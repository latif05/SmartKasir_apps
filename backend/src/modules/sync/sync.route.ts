import { Router } from 'express';

import { SyncController } from './sync.controller';

const router = Router();
const controller = new SyncController();

router.get('/pull', controller.pull);
router.post('/push', controller.push);

export { router as syncRouter };
