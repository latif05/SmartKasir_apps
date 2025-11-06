import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCachedUser extends UseCase<User?, NoParams> {
  GetCachedUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<User?> call(NoParams params) {
    return _repository.getCachedUser();
  }
}
