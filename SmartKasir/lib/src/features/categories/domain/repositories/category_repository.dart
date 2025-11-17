import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({bool includeDeleted = false});

  Future<Category?> getCategory(String id);

  Future<void> createCategory({
    required String name,
    String? description,
  });

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
  });

  Future<void> deleteCategory(String id);
}
