import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/repositories/activation_repository.dart';
import '../../domain/usecases/activate_with_code.dart';
import '../../domain/usecases/get_activation_status.dart';
import '../state/activation_notifier.dart';
import '../state/activation_state.dart';

final activationRepositoryProvider = Provider<ActivationRepository>((ref) {
  return serviceLocator<ActivationRepository>();
});

final getActivationStatusProvider = Provider<GetActivationStatus>((ref) {
  return GetActivationStatus(ref.read(activationRepositoryProvider));
});

final activateWithCodeProvider = Provider<ActivateWithCode>((ref) {
  return ActivateWithCode(ref.read(activationRepositoryProvider));
});

final activationNotifierProvider =
    StateNotifierProvider<ActivationNotifier, ActivationState>((ref) {
  return ActivationNotifier(
    ref.read(getActivationStatusProvider),
    ref.read(activateWithCodeProvider),
  );
});
