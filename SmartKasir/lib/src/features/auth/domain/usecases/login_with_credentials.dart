import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithCredentials extends UseCase<User, LoginParams> {
  const LoginWithCredentials(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> call(LoginParams params) async {
    final user = await _repository.login(
      username: params.username,
      password: params.password,
    );

    await _repository.cacheUser(user);
    return user;
  }
}

class LoginParams {
  const LoginParams({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}
