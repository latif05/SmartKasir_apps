import '../../domain/entities/category.dart';

class CategoryListState {
  const CategoryListState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
    this.includeDeleted = false,
  });

  final List<Category> categories;
  final bool isLoading;
  final String? errorMessage;
  final bool includeDeleted;

  CategoryListState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? errorMessage,
    bool? includeDeleted,
    bool clearError = false,
  }) {
    return CategoryListState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}
