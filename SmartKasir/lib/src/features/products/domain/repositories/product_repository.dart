import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool includeDeleted = false});

  Future<Product?> getProduct(String id);

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
  });

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
  });

  Future<void> deleteProduct(String id);
}
