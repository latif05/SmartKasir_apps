import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call({bool includeDeleted = false}) {
    return _repository.getCategories(includeDeleted: includeDeleted);
  }
}
