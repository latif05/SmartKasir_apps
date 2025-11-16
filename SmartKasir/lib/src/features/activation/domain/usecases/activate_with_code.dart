import '../../../../core/usecase/usecase.dart';
import '../repositories/activation_repository.dart';

class ActivateWithCode extends UseCase<void, ActivateWithCodeParams> {
  ActivateWithCode(this._repository);

  final ActivationRepository _repository;

  @override
  Future<void> call(ActivateWithCodeParams params) {
    return _repository.activate(params.code);
  }
}

class ActivateWithCodeParams {
  const ActivateWithCodeParams(this.code);

  final String code;
}

