import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import '../state/category_list_notifier.dart';
import '../state/category_list_state.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return serviceLocator<CategoryRepository>();
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return GetCategories(repository);
});

final createCategoryProvider = Provider<CreateCategory>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return CreateCategory(repository);
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return UpdateCategory(repository);
});

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return DeleteCategory(repository);
});

final categoryListNotifierProvider =
    StateNotifierProvider<CategoryListNotifier, CategoryListState>((ref) {
  final getCategories = ref.read(getCategoriesProvider);
  final createCategory = ref.read(createCategoryProvider);
  final updateCategory = ref.read(updateCategoryProvider);
  final deleteCategory = ref.read(deleteCategoryProvider);
  return CategoryListNotifier(
    getCategories: getCategories,
    createCategory: createCategory,
    updateCategory: updateCategory,
    deleteCategory: deleteCategory,
  );
});
