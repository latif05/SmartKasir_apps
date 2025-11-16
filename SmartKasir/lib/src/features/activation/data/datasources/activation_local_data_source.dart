import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

class ActivationLocalDataSource {
  ActivationLocalDataSource(this._database);

  final db.AppDatabase _database;

  Future<db.ActivationStatusData> getStatus() async {
    final result = await _database.select(_database.activationStatus).get();
    if (result.isEmpty) {
      await _database.into(_database.activationStatus).insert(
            db.ActivationStatusCompanion.insert(
              isPremium: const Value(0),
              activatedAt: const Value(null),
              codeUsed: const Value(null),
              note: const Value(null),
            ),
          );
      return getStatus();
    }
    return result.first;
  }

  Future<db.ActivationCode?> getCode(String code) {
    return (_database.select(_database.activationCodes)
          ..where((tbl) => tbl.code.equals(code)))
        .getSingleOrNull();
  }

  Future<void> markStatus({
    required bool isPremium,
    String? codeUsed,
    DateTime? activatedAt,
  }) {
    return (_database.update(_database.activationStatus)
          ..where((tbl) => tbl.id.equals(1)))
        .write(
      db.ActivationStatusCompanion(
        isPremium: Value(isPremium ? 1 : 0),
        codeUsed: Value(codeUsed),
        activatedAt: Value(activatedAt ?? DateTime.now()),
      ),
    );
  }

  Future<void> markCodeUsed(String code) {
    return (_database.update(_database.activationCodes)
          ..where((tbl) => tbl.code.equals(code)))
        .write(
      db.ActivationCodesCompanion(
        alreadyUsed: const Value(1),
      ),
    );
  }
}
