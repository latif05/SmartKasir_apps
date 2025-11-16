import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/app_exception.dart';
import '../../../../core/security/password_hasher.dart';
import '../../../auth/data/datasources/user_dao.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  UserManagementRepositoryImpl(this._userDao);

  final UserDao _userDao;
  final _uuid = const Uuid();

  @override
  Future<void> createUser({
    required String username,
    required String displayName,
    required String password,
    String role = 'cashier',
  }) async {
    final existing = await _userDao.getByUsername(username);
    if (existing != null) {
      throw const ValidationException('Username sudah digunakan.');
    }

    await _userDao.insertUser(
      db.UsersCompanion.insert(
        id: _uuid.v4(),
        username: username,
        displayName: displayName,
        passwordHash: PasswordHasher.hash(password),
        role: Value(role),
      ),
    );
  }

  @override
  Future<void> updateUser({
    required String id,
    String? displayName,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    await _userDao.updateUser(
      id,
      displayName: displayName,
      role: role,
      isActive: isActive,
      passwordHash: password != null ? PasswordHasher.hash(password) : null,
    );
  }

  @override
  Future<void> deactivateUser(String id) {
    return _userDao.deactivateUser(id);
  }

  @override
  Future<List<User>> getUsers({bool includeInactive = false}) async {
    final dbUsers = await _userDao.getAllUsers(includeInactive: includeInactive);
    return dbUsers
        .map(
          (u) => User(
            id: u.id,
            username: u.username,
            displayName: u.displayName,
            role: u.role,
            isActive: u.isActive == 1,
          ),
        )
        .toList();
  }
}

