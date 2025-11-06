import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._database);

  static const String _currentUserKey = 'current_user';

  final AppDatabase _database;

  @override
  Future<void> cacheUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _database.into(_database.settings).insertOnConflictUpdate(
          SettingsCompanion(
            key: Value(_currentUserKey),
            value: Value(json),
          ),
        );
  }

  @override
  Future<void> clearUser() async {
    await (_database.delete(_database.settings)
          ..where((tbl) => tbl.key.equals(_currentUserKey)))
        .go();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final result = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals(_currentUserKey)))
        .getSingleOrNull();

    if (result?.value == null) {
      return null;
    }

    return UserModel.fromJson(
      jsonDecode(result!.value!) as Map<String, dynamic>,
    );
  }
}
