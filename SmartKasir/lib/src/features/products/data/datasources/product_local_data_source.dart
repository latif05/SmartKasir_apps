import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<Product>> fetchAll() {
    return (_database.select(_database.products)
          ..where((tbl) => tbl.isDeleted.equals(0)))
        .get();
  }

  Stream<List<Product>> watchAll() {
    return (_database.select(_database.products)
          ..where((tbl) => tbl.isDeleted.equals(0)))
        .watch();
  }

  Future<void> upsertProduct(ProductsCompanion entry) {
    return _database.into(_database.products).insertOnConflictUpdate(entry);
  }

  Future<void> updateStock({
    required String productId,
    required int newStock,
    String? syncStatus,
  }) {
    return (_database.update(_database.products)
          ..where((tbl) => tbl.id.equals(productId)))
        .write(
      ProductsCompanion(
        stock: Value(newStock),
        syncStatus: Value(syncStatus ?? 'pending'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> softDelete(String id) {
    return (_database.update(_database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      ProductsCompanion(
        isDeleted: const Value(1),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
