import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;

class UserDao {
  UserDao(this._database);

  final db.AppDatabase _database;

  Future<db.User?> getByUsername(String username) {
    return (_database.select(_database.users)
          ..where((tbl) => tbl.username.equals(username)))
        .getSingleOrNull();
  }

  Future<db.User?> getById(String id) {
    return (_database.select(_database.users)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<db.User>> getAllUsers({bool includeInactive = false}) {
    final query = _database.select(_database.users);
    if (!includeInactive) {
      query.where((tbl) => tbl.isActive.equals(1));
    }
    return query.get();
  }

  Future<void> insertUser(db.UsersCompanion entry) {
    return _database.into(_database.users).insert(entry);
  }

  Future<void> updateUser(
    String id, {
    String? displayName,
    String? role,
    bool? isActive,
    String? passwordHash,
  }) {
    return (_database.update(_database.users)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      db.UsersCompanion(
        displayName:
            displayName != null ? Value(displayName) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        isActive: isActive != null
            ? Value(isActive ? 1 : 0)
            : const Value.absent(),
        passwordHash: passwordHash != null
            ? Value(passwordHash)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateUser(String id) {
    return updateUser(id, isActive: false);
  }
}
