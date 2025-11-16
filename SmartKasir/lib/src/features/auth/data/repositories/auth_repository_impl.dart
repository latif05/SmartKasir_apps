import '../../../../core/error/app_exception.dart';
import '../../../../core/security/password_hasher.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/user_dao.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required UserDao userDao,
  })  : _localDataSource = localDataSource,
        _userDao = userDao;

  final AuthLocalDataSource _localDataSource;
  final UserDao _userDao;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final dbUser = await _userDao.getByUsername(username);
      if (dbUser == null || dbUser.isActive == 0) {
        throw const AuthenticationException(
          'Pengguna tidak ditemukan atau dinonaktifkan',
        );
      }

      final isValid = PasswordHasher.verify(password, dbUser.passwordHash);
      if (!isValid) {
        throw const AuthenticationException('Username atau kata sandi salah');
      }

      final userModel = UserModel(
        id: dbUser.id,
        username: dbUser.username,
        displayName: dbUser.displayName,
        role: dbUser.role,
        isActive: dbUser.isActive == 1,
      );

      await _localDataSource.cacheUser(userModel);
      return userModel.toEntity();
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
