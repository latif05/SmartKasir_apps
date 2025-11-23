import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser extends UseCase<User, RegisterParams> {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<User> call(RegisterParams params) async {
    final user = await _repository.register(
      username: params.username,
      displayName: params.displayName,
      password: params.password,
      role: params.role,
    );
    await _repository.cacheUser(user);
    return user;
  }
}

class RegisterParams {
  const RegisterParams({
    required this.username,
    required this.displayName,
    required this.password,
    this.role = 'admin',
  });

  final String username;
  final String displayName;
  final String password;
  final String role;
}
