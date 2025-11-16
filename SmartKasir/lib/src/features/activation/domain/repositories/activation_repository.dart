import '../entities/activation_status.dart';

abstract class ActivationRepository {
  Future<ActivationStatus> getStatus();
  Future<void> activate(String code);
}

