import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../state/user_management_notifier.dart';
import '../state/user_management_state.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((ref) {
  return serviceLocator<UserManagementRepository>();
});

final userManagementNotifierProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  final repository = ref.read(userManagementRepositoryProvider);
  return UserManagementNotifier(repository);
});

