import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<List<Product>> call({bool includeDeleted = false}) {
    return _repository.getProducts(includeDeleted: includeDeleted);
  }
}
