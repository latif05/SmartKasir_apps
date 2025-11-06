import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        username: username,
        password: password,
      );
      await _localDataSource.cacheUser(result);
      return result.toEntity();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('Login gagal dieksekusi', error, stackTrace);
      throw const AuthenticationException(
        'Gagal melakukan proses login',
      );
    }
  }

  @override
  Future<void> cacheUser(User user) {
    return _localDataSource.cacheUser(UserModel.fromEntity(user));
  }

  @override
  Future<User?> getCachedUser() async {
    final cached = await _localDataSource.getCachedUser();
    return cached?.toEntity();
  }

  @override
  Future<void> clearSession() {
    return _localDataSource.clearUser();
  }
}
