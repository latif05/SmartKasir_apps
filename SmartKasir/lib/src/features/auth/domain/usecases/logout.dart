import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class Logout extends UseCase<void, NoParams> {
  Logout(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.clearSession();
  }
}
