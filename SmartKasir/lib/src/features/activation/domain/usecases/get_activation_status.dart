import '../../../../core/usecase/usecase.dart';
import '../entities/activation_status.dart';
import '../repositories/activation_repository.dart';

class GetActivationStatus extends UseCase<ActivationStatus, NoParams> {
  GetActivationStatus(this._repository);

  final ActivationRepository _repository;

  @override
  Future<ActivationStatus> call(NoParams params) {
    return _repository.getStatus();
  }
}

