import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> saveValue({
    required String key,
    required String? value,
  }) {
    return _database.into(_database.settings).insertOnConflictUpdate(
          SettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<String?> readValue(String key) async {
    final result = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Stream<Map<String, String?>> watchAll() {
    return _database.select(_database.settings).watch().map(
          (rows) =>
              {for (final row in rows) row.key: row.value},
        );
  }
}
