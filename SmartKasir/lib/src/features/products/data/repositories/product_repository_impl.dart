import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../../categories/data/datasources/category_dao.dart';
import '../../domain/entities/product.dart' as domain;
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_dao.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._productDao, this._categoryDao);

  final ProductDao _productDao;
  final CategoryDao _categoryDao;
  final _uuid = const Uuid();

  @override
  Future<void> createProduct({
    required String categoryId,
    required String name,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? stockMin,
    String? unit,
    String? barcode,
    String? imageUrl,
  }) async {
    await _ensureCategoryExists(categoryId);

    final now = DateTime.now();
    await _productDao.upsert(
      db.ProductsCompanion(
        id: Value(_uuid.v4()),
        categoryId: Value(categoryId),
        name: Value(name),
        barcode: Value(barcode),
        purchasePrice: Value(purchasePrice ?? 0),
        sellingPrice: Value(sellingPrice ?? 0),
        stock: Value(stock ?? 0),
        stockMin: Value(stockMin ?? 0),
        unit: Value(unit),
        imageUrl: Value(imageUrl),
        isDeleted: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> updateProduct({
    required String id,
    String? categoryId,
    String? name,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? stockMin,
    String? unit,
    String? barcode,
    String? imageUrl,
  }) async {
    final existing = await _productDao.getById(id);
    if (existing == null || existing.isDeleted == 1) {
      throw const ValidationException('Produk tidak ditemukan');
    }

    if (categoryId != null) {
      await _ensureCategoryExists(categoryId);
    }

    await _productDao.upsert(
      db.ProductsCompanion(
        id: Value(id),
        categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
        name: name != null ? Value(name) : const Value.absent(),
        barcode: barcode != null ? Value(barcode) : const Value.absent(),
        purchasePrice: purchasePrice != null ? Value(purchasePrice) : const Value.absent(),
        sellingPrice: sellingPrice != null ? Value(sellingPrice) : const Value.absent(),
        stock: stock != null ? Value(stock) : const Value.absent(),
        stockMin: stockMin != null ? Value(stockMin) : const Value.absent(),
        unit: unit != null ? Value(unit) : const Value.absent(),
        imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        isDeleted: Value(existing.isDeleted),
      ),
    );
  }

  @override
  Future<void> deleteProduct(String id) async {
    final existing = await _productDao.getById(id);
    if (existing == null || existing.isDeleted == 1) {
      throw const ValidationException('Produk tidak ditemukan');
    }
    await _productDao.softDelete(id);
  }

  @override
  Future<List<domain.Product>> getProducts({bool includeDeleted = false}) async {
    final result = await _productDao.getAll(includeDeleted: includeDeleted);
    return result.map(_mapProduct).toList();
  }

  @override
  Future<domain.Product?> getProduct(String id) async {
    final row = await _productDao.getById(id);
    return row == null ? null : _mapProduct(row);
  }

  Future<void> _ensureCategoryExists(String categoryId) async {
    final category = await _categoryDao.getById(categoryId);
    if (category == null || category.isDeleted == 1) {
      throw const ValidationException('Kategori tidak ditemukan');
    }
  }

  domain.Product _mapProduct(db.Product row) {
    return domain.Product(
      id: row.id,
      categoryId: row.categoryId,
      name: row.name,
      barcode: row.barcode,
      purchasePrice: row.purchasePrice,
      sellingPrice: row.sellingPrice,
      stock: row.stock,
      stockMin: row.stockMin,
      unit: row.unit,
      imageUrl: row.imageUrl,
      isDeleted: row.isDeleted == 1,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
