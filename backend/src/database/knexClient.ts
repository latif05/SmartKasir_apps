import knex, { type Knex } from 'knex';

import { env } from '../config/env';

const config: Knex.Config = {
  client: 'mysql2',
  connection: {
    host: env.mysql.host,
    port: env.mysql.port,
    user: env.mysql.user,
    password: env.mysql.password,
    database: env.mysql.database,
  },
  pool: {
    min: 0,
    max: 10,
  },
};

export const knexClient = knex(config);
