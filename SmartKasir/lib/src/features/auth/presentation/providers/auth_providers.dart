import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_credentials.dart';
import '../../domain/usecases/get_cached_user.dart';
import '../../domain/usecases/logout.dart';
import '../state/auth_notifier.dart';
import '../state/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return serviceLocator<AuthRepository>();
});

final loginWithCredentialsProvider = Provider<LoginWithCredentials>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginWithCredentials(repository);
});

final getCachedUserProvider = Provider<GetCachedUser>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCachedUser(repository);
});

final logoutProvider = Provider<Logout>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return Logout(repository);
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.read(loginWithCredentialsProvider),
    ref.read(getCachedUserProvider),
    ref.read(logoutProvider),
  );

  Future<void>.microtask(notifier.loadCachedUser);
  return notifier;
});
