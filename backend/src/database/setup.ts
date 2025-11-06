import { randomUUID } from 'crypto';

import bcrypt from 'bcryptjs';

import { env } from '../config/env';
import { knexClient } from './knexClient';

const ensureUsersTable = async () => {
  const exists = await knexClient.schema.hasTable('users');

  if (!exists) {
    await knexClient.schema.createTable('users', (table) => {
      table.uuid('id').primary();
      table.string('username', 255).notNullable().unique();
      table.string('password_hash', 255).notNullable();
      table.string('display_name', 255).notNullable();
      table
        .enu('role', ['admin', 'cashier'], {
          useNative: true,
          enumName: 'user_role_enum',
        })
        .notNullable()
        .defaultTo('admin');
      table
        .timestamp('created_at', { useTz: false })
        .notNullable()
        .defaultTo(knexClient.fn.now());
      table
        .timestamp('updated_at', { useTz: false })
        .notNullable()
        .defaultTo(knexClient.fn.now());
    });
  }
};

const ensureSyncPackagesTable = async () => {
  const exists = await knexClient.schema.hasTable('sync_packages');

  if (!exists) {
    await knexClient.schema.createTable('sync_packages', (table) => {
      table.uuid('id').primary();
      table
        .enu('direction', ['push', 'pull'], {
          useNative: true,
          enumName: 'sync_direction_enum',
        })
        .notNullable();
      table.string('file_path', 500).nullable();
      table.json('payload').nullable();
      table
        .enu('status', ['pending', 'processing', 'completed', 'failed'], {
          useNative: true,
          enumName: 'sync_status_enum',
        })
        .notNullable()
        .defaultTo('pending');
      table.string('error_message', 500).nullable();
      table
        .timestamp('created_at', { useTz: false })
        .notNullable()
        .defaultTo(knexClient.fn.now());
      table
        .timestamp('updated_at', { useTz: false })
        .notNullable()
        .defaultTo(knexClient.fn.now());
    });
  }
};

const seedAdminUser = async () => {
  const { adminUsername, adminPassword, adminDisplayName } = env.seed;

  const existing = await knexClient('users')
    .select('id')
    .where({ username: adminUsername })
    .first();

  if (existing) {
    // eslint-disable-next-line no-console
    console.log(
      `[seed] User "${adminUsername}" sudah tersedia, lewati proses seeding.`,
    );
    return;
  }

  const passwordHash = await bcrypt.hash(adminPassword, 10);

  await knexClient('users').insert({
    id: randomUUID(),
    username: adminUsername,
    password_hash: passwordHash,
    display_name: adminDisplayName,
    role: 'admin',
  });

  // eslint-disable-next-line no-console
  console.log(
    `[seed] Admin default "${adminUsername}" berhasil dibuat (password: ${adminPassword}).`,
  );
};

const runSetup = async () => {
  try {
    // eslint-disable-next-line no-console
    console.log('[setup] Memulai migrasi dan seeding...');
    await ensureUsersTable();
    await ensureSyncPackagesTable();
    await seedAdminUser();
    // eslint-disable-next-line no-console
    console.log('[setup] Proses selesai tanpa error.');
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[setup] Terjadi kesalahan:', error);
    process.exitCode = 1;
  } finally {
    await knexClient.destroy();
  }
};

void runSetup();
