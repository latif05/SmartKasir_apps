import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<Category>> fetchAll() {
    return _database.select(_database.categories).get();
  }

  Stream<List<Category>> watchAll() {
    return _database.select(_database.categories).watch();
  }

  Future<void> upsertCategory(CategoriesCompanion entry) {
    return _database.into(_database.categories).insertOnConflictUpdate(entry);
  }

  Future<void> softDelete(String id) {
    return (_database.update(_database.categories)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      CategoriesCompanion(
        isDeleted: const Value(1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
