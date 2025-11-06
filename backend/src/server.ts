import { createApp } from './app';
import { env } from './config/env';
import { knexClient } from './database/knexClient';

const bootstrap = async () => {
  try {
    await knexClient.raw('SELECT 1');
    // eslint-disable-next-line no-console
    console.log('[database] MySQL connection established');
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[database] Failed to connect to MySQL', error);
    process.exit(1);
  }

  const app = createApp();
  app.listen(env.port, () => {
    // eslint-disable-next-line no-console
    console.log(
      `[server] ${env.appName} listening on port ${env.port} (${env.nodeEnv})`,
    );
  });
};

void bootstrap();
