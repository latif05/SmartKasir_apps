import '../../../../core/usecase/usecase.dart';
import '../repositories/activation_repository.dart';

class ActivateFromPurchase extends UseCase<void, NoParams> {
  ActivateFromPurchase(this._repository);

  final ActivationRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.markPremiumFromPurchase();
  }
}
