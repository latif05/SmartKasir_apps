import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../state/product_list_notifier.dart';
import '../state/product_list_state.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return serviceLocator<ProductRepository>();
});

final getProductsProvider = Provider<GetProducts>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return GetProducts(repository);
});

final createProductProvider = Provider<CreateProduct>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return CreateProduct(repository);
});

final updateProductProvider = Provider<UpdateProduct>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return UpdateProduct(repository);
});

final deleteProductProvider = Provider<DeleteProduct>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return DeleteProduct(repository);
});

final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final getProducts = ref.read(getProductsProvider);
  final createProduct = ref.read(createProductProvider);
  final updateProduct = ref.read(updateProductProvider);
  final deleteProduct = ref.read(deleteProductProvider);
  return ProductListNotifier(
    getProducts: getProducts,
    createProduct: createProduct,
    updateProduct: updateProduct,
    deleteProduct: deleteProduct,
  );
});
