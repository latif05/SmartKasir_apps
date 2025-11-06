import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env';
import { errorHandler } from './core/http/errorHandler';
import { notFoundHandler } from './core/http/notFoundHandler';
import { authRouter } from './modules/auth/http/auth.route';
import { syncRouter } from './modules/sync/sync.route';

export const createApp = () => {
  const app = express();

  app.set('trust proxy', true);
  app.use(helmet());
  app.use(
    cors({
      origin: '*',
      exposedHeaders: ['x-request-id'],
    }),
  );
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(
    morgan(env.nodeEnv === 'production' ? 'combined' : 'dev', {
      skip: () => env.nodeEnv === 'test',
    }),
  );

  app.get('/health', (_req, res) =>
    res.json({
      status: 'ok',
      service: env.appName,
      version: env.nodeEnv,
    }),
  );

  app.use('/api/auth', authRouter);
  app.use('/api/sync', syncRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
