import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

class CategoryDao {
  CategoryDao(this._database);

  final db.AppDatabase _database;

  Future<List<db.Category>> getAll({bool includeDeleted = false}) {
    final query = _database.select(_database.categories);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(0));
    }
    return query.get();
  }

  Stream<List<db.Category>> watchAll({bool includeDeleted = false}) {
    final query = _database.select(_database.categories);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(0));
    }
    return query.watch();
  }

  Future<db.Category?> getById(String id) {
    return (_database.select(_database.categories)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(db.CategoriesCompanion entry) {
    return _database.into(_database.categories).insertOnConflictUpdate(entry);
  }

  Future<void> softDelete(String id) {
    return (_database.update(_database.categories)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      db.CategoriesCompanion(
        isDeleted: const Value(1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
