import { knexClient } from '../../../database/knexClient';
import type { User } from '../models/user';

interface UserRow {
  id: string;
  username: string;
  password_hash: string;
  display_name: string;
  role: string;
  created_at: Date;
  updated_at: Date;
}

export class UserRepository {
  async findByUsername(username: string): Promise<User | null> {
    const row = await knexClient<UserRow>('users')
      .where({ username })
      .first();

    if (!row) {
      return null;
    }

    return {
      id: row.id,
      username: row.username,
      passwordHash: row.password_hash,
      displayName: row.display_name,
      role: row.role as User['role'],
      createdAt: new Date(row.created_at),
      updatedAt: new Date(row.updated_at),
    };
  }
}
