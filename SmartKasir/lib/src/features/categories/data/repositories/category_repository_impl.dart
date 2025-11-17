import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_dao.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao);

  final CategoryDao _dao;
  final _uuid = const Uuid();

  @override
  Future<void> createCategory({required String name, String? description}) {
    return _dao.upsert(
      db.CategoriesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        description: description != null ? Value(description) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    final existing = await _dao.getById(id);
    if (existing == null || existing.isDeleted == 1) {
      throw const ValidationException('Kategori tidak ditemukan');
    }

    await _dao.upsert(
      db.CategoriesCompanion(
        id: Value(id),
        name: Value(name),
        description: description != null ? Value(description) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        isDeleted: Value(existing.isDeleted),
      ),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final existing = await _dao.getById(id);
    if (existing == null || existing.isDeleted == 1) {
      throw const ValidationException('Kategori tidak ditemukan');
    }
    await _dao.softDelete(id);
  }

  @override
  Future<List<domain.Category>> getCategories({bool includeDeleted = false}) async {
    final items = await _dao.getAll(includeDeleted: includeDeleted);
    return items.map(_mapCategory).toList();
  }

  @override
  Future<domain.Category?> getCategory(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _mapCategory(row);
  }

  domain.Category _mapCategory(db.Category row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      description: row.description,
      isDeleted: row.isDeleted == 1,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
