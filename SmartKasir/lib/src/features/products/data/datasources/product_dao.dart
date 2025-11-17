import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

class ProductDao {
  ProductDao(this._database);

  final db.AppDatabase _database;

  Future<List<db.Product>> getAll({bool includeDeleted = false}) {
    final query = _database.select(_database.products);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(0));
    }
    return query.get();
  }

  Stream<List<db.Product>> watchAll({bool includeDeleted = false}) {
    final query = _database.select(_database.products);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(0));
    }
    return query.watch();
  }

  Future<db.Product?> getById(String id) {
    return (_database.select(_database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsert(db.ProductsCompanion entry) {
    return _database.into(_database.products).insertOnConflictUpdate(entry);
  }

  Future<void> updateStock({required String productId, required int newStock}) {
    return (_database.update(_database.products)
          ..where((tbl) => tbl.id.equals(productId)))
        .write(
      db.ProductsCompanion(
        stock: Value(newStock),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> softDelete(String id) {
    return (_database.update(_database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      db.ProductsCompanion(
        isDeleted: const Value(1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
