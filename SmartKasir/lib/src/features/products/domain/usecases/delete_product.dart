import '../repositories/product_repository.dart';

class DeleteProduct {
  const DeleteProduct(this._repository);

  final ProductRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteProduct(id);
  }
}
