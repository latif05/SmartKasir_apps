import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl();

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // TODO: Replace with real API call to Node.js backend.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return UserModel(
      id: 'demo-user',
      username: username,
      displayName: 'Demo User',
      role: 'admin',
    );
  }
}
