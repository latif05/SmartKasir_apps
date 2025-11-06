import { knexClient } from '../../../database/knexClient';
import type {
  SyncDirection,
  SyncPackage,
  SyncStatus,
} from '../models/syncPackage';

const tableName = 'sync_packages';

export class SyncPackageRepository {
  async create(params: {
    direction: SyncDirection;
    payload?: unknown;
    filePath?: string | null;
  }): Promise<string> {
    const [row] = await knexClient(tableName).insert(
      {
        id: knexClient.raw('UUID()'),
        direction: params.direction,
        payload: params.payload ?? null,
        file_path: params.filePath ?? null,
      },
      ['id'],
    );

    if (typeof row === 'object' && row !== null && 'id' in row) {
      return String((row as { id: string }).id);
    }

    const [idRow] = await knexClient<[{ id: string }]>(tableName)
      .select('id')
      .orderBy('created_at', 'desc')
      .limit(1);

    return idRow?.id ?? '';
  }

  async updateStatus(
    id: string,
    status: SyncStatus,
    errorMessage?: string | null,
  ): Promise<void> {
    await knexClient(tableName)
      .where({ id })
      .update({
        status,
        error_message: errorMessage ?? null,
        updated_at: knexClient.fn.now(),
      });
  }

  async findPending(direction: SyncDirection): Promise<SyncPackage[]> {
    const rows = await knexClient(tableName)
      .where({ direction, status: 'pending' })
      .orderBy('created_at', 'asc');

    return rows.map(this.mapRowToEntity);
  }

  private mapRowToEntity(row: any): SyncPackage {
    return {
      id: row.id,
      direction: row.direction,
      filePath: row.file_path,
      payload: row.payload,
      status: row.status,
      errorMessage: row.error_message,
      createdAt: new Date(row.created_at),
      updatedAt: new Date(row.updated_at),
    };
  }
}
