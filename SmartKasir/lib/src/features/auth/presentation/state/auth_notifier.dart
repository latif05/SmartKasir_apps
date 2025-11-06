import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/login_with_credentials.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/logout.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._loginWithCredentials,
    this._getCachedUser,
    this._logout,
  ) : super(const AuthState());

  final LoginWithCredentials _loginWithCredentials;
  final GetCachedUser _getCachedUser;
  final Logout _logout;

  Future<void> loadCachedUser() async {
    try {
      final cached = await _getCachedUser(const NoParams());
      if (cached != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: cached,
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Gagal memuat user cache', error, stackTrace);
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _loginWithCredentials(
        LoginParams(username: username, password: password),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } on AuthenticationException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Terjadi kesalahan saat login', error, stackTrace);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Terjadi kesalahan pada sistem',
      );
    }
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    state = const AuthState(status: AuthStatus.initial);
  }
}
