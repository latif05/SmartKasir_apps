import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'category_list_state.dart';

class CategoryListNotifier extends StateNotifier<CategoryListState> {
  CategoryListNotifier({
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        super(const CategoryListState()) {
    loadCategories();
  }

  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  Future<void> loadCategories({bool? includeDeleted}) async {
    final shouldIncludeDeleted = includeDeleted ?? state.includeDeleted;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      includeDeleted: shouldIncludeDeleted,
    );
    try {
      final categories = await _getCategories(includeDeleted: shouldIncludeDeleted);
      state = state.copyWith(
        categories: categories,
        isLoading: false,
        includeDeleted: shouldIncludeDeleted,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat kategori',
      );
    }
  }

  Future<void> createCategory({required String name, String? description}) {
    return _performAction(
      () => _createCategory(name: name, description: description),
    );
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
  }) {
    return _performAction(
      () => _updateCategory(id: id, name: name, description: description),
    );
  }

  Future<void> deleteCategory(String id) {
    return _performAction(() => _deleteCategory(id));
  }

  Future<void> _performAction(Future<void> Function() runner) async {
    try {
      await runner();
      await loadCategories();
    } catch (error) {
      rethrow;
    }
  }
}
