import '../../domain/entities/product.dart';

class ProductListState {
  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}