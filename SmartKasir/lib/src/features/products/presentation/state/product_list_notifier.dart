import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import 'product_list_state.dart';

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({
    required GetProducts getProducts,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
  })  : _getProducts = getProducts,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        super(const ProductListState()) {
    loadProducts();
  }

  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final products = await _getProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat produk',
      );
    }
  }

  Future<void> createProduct({
    required String categoryId,
    required String name,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int stockMin,
    String? unit,
  }) {
    return _performAction(
      () => _createProduct(
        categoryId: categoryId,
        name: name,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stock: stock,
        stockMin: stockMin,
        unit: unit,
        barcode: null,
      ),
    );
  }

  Future<void> updateProduct({
    required String id,
    required String categoryId,
    required String name,
    required double purchasePrice,
    required double sellingPrice,
    required int stock,
    required int stockMin,
    String? unit,
  }) {
    return _performAction(
      () => _updateProduct(
        id: id,
        categoryId: categoryId,
        name: name,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stock: stock,
        stockMin: stockMin,
        unit: unit,
        barcode: null,
      ),
    );
  }

  Future<void> deleteProduct(String id) {
    return _performAction(() => _deleteProduct(id));
  }

  Future<void> _performAction(Future<void> Function() runner) async {
    try {
      await runner();
      await loadProducts();
    } catch (error) {
      rethrow;
    }
  }
}
