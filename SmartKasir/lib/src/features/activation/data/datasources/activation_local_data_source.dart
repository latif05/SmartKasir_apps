import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

class ActivationLocalDataSource {
  ActivationLocalDataSource(this._database);

  final db.AppDatabase _database;

  Future<db.ActivationStatusData> getStatus() async {
    await _seedCodesIfNeeded();

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
    return _database.into(_database.activationStatus).insertOnConflictUpdate(
          db.ActivationStatusCompanion(
            id: const Value(1),
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

  Future<void> _seedCodesIfNeeded() async {
    const codes = [
      'SKP-71A9X2M4',
      'SKP-2QF8H5ZP',
      'SKP-V93K7L1D',
      'SKP-ML2R5T8G',
      'SKP-4ZP7C1NQ',
      'SKP-9JX5E2WB',
      'SKP-Y6T3R8KD',
      'SKP-3VQ9L7AM',
      'SKP-H2C6P5ZX',
      'SKP-Q7M1D4YV',
      'SKP-58RZ1KCL',
      'SKP-K9W4T2SM',
      'SKP-C1N7V5JH',
      'SKP-R8L2Q3PX',
      'SKP-T5G9B1WV',
      'SKP-6D2Z7FQK',
      'SKP-L1C8M4RY',
      'SKP-P7X2J9HG',
      'SKP-Z4V6T1DM',
      'SKP-W9Q3K5NB',
      'SKP-2H7R1ZVM',
      'SKP-5XK8L2DQ',
      'SKP-1M9T4CJV',
      'SKP-G6P2Y7RX',
      'SKP-N3V5Q1LK',
      'SKP-J8D4W2TZ',
      'SKP-4Q9M6HCP',
      'SKP-X1T7R5LV',
      'SKP-7ZP2K9DM',
      'SKP-V5L1C8QH',
      'SKP-9W3R6TJP',
      'SKP-H2X8M4LK',
      'SKP-Q7C1V5ZR',
      'SKP-6D9P2YTX',
      'SKP-L4M7K1WV',
      'SKP-P8J2R5CN',
      'SKP-Z1T6L4QK',
      'SKP-W7V3C9MD',
      'SKP-3H5X1JRT',
      'SKP-8Q2P7LKV',
      'SKP-2T9C4MHW',
      'SKP-5R1Z8VDK',
      'SKP-1K6Q3JVP',
      'SKP-G4L9T2SM',
      'SKP-N7W1R5ZX',
      'SKP-J2M8C4TV',
      'SKP-4V6P1QKD',
      'SKP-X9T3L5HM',
      'SKP-7C2R8VDQ',
      'SKP-V1K5M9ZX',
      'SKP-9P4Q2TLH',
      'SKP-H6W1C7RV',
      'SKP-Q3J8Z5TM',
      'SKP-6L2V9PKH',
      'SKP-L5T1R7QM',
      'SKP-P9C3M6VD',
      'SKP-Z2W8K5JR',
      'SKP-W1H4T9LX',
      'SKP-3V7Q2CPM',
    ];

    final existing = await (_database.select(_database.activationCodes)
          ..where((tbl) => tbl.code.equals(codes.first)))
        .getSingleOrNull();
    if (existing != null) return;

    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.activationCodes,
        codes
            .map(
              (code) => db.ActivationCodesCompanion.insert(
                code: code,
                description: const Value('Paket Premium Rp30.000'),
                maxUse: const Value(1),
                alreadyUsed: const Value(0),
              ),
            )
            .toList(),
      );
    });
  }
}
