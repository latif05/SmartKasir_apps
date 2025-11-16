import '../../../auth/domain/entities/user.dart';

abstract class UserManagementRepository {
  Future<List<User>> getUsers({bool includeInactive = false});

  Future<void> createUser({
    required String username,
    required String displayName,
    required String password,
    String role,
  });

  Future<void> updateUser({
    required String id,
    String? displayName,
    String? password,
    String? role,
    bool? isActive,
  });

  Future<void> deactivateUser(String id);
}

